import {
  RpcProvider,
  Account,
  CallData,
  byteArray,
  CairoCustomEnum,
  Contract,
} from "starknet";

import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";
import { dirname } from "path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const loadJson = (rpath) => {
  return JSON.parse(fs.readFileSync(path.resolve(__dirname, rpath)));
};

const getContractAddress = (mainfest, contractName) => {
  for (const contract of mainfest.contracts) {
    if (contract.tag === contractName) {
      return contract.address;
    }
  }
  return null;
};

const seed_data = loadJson("./seed-attributes.json");
const custom_data = loadJson("./custom-attributes.json");
const amma_data = loadJson("./amma-attributes.json");
const manifest = loadJson(
  `../manifests/${process.argv[2]}/deployment/manifest.json`
);

const blobertContractTag = "blob_arena-blobert_actions";
const arcadeBlobertTag = "blob_arena-arcade_blobert_actions";
const seedEntrypoint = "new_seed_item_with_attacks";
const customEntrypoint = "new_custom_item_with_attacks";

const amma_offset = 50;

const provider = new RpcProvider({ nodeUrl: process.env.STARKNET_RPC_URL });
const account1Address = process.env.DOJO_ACCOUNT_ADDRESS;
const privateKey1 = process.env.DOJO_PRIVATE_KEY;
const account = new Account(provider, account1Address, privateKey1);

const blobertContractAddress = getContractAddress(manifest, blobertContractTag);
const arcadeBlobertAddress = getContractAddress(manifest, arcadeBlobertTag);

const { abi: abi } = await provider.getClassAt(blobertContractAddress);
const blobertContract = new Contract(abi, blobertContractAddress, provider);

const TRAITS_ENUM = ["Background", "Armour", "Jewelry", "Mask", "Weapon"];
const TARGET_ENUM = ["Player", "Opponent"];
const STAT_TYPES_ENUM = ["Strength", "Vitality", "Dexterity", "Luck"];
const AFFECTS_ENUM = ["Stats", "Stat", "Damage", "Stun", "Health"];
const STAT_KEYS = ["strength", "vitality", "dexterity", "luck"];

const toSigned = (x) => {
  if (x >= 0) {
    return { sign: false, value: x };
  } else {
    return { sign: true, value: -x };
  }
};

function parseNestedSignedStruct(obj) {
  for (let key in obj) {
    if (typeof obj[key] === "number") {
      obj[key] = toSigned(obj[key]);
    } else if (typeof obj[key] === "object" && obj[key] !== null) {
      parseNestedSignedStruct(obj[key]);
    }
  }
  return obj;
}

const makeCairoEnum = (enumArray, option) => {
  let struct = {};
  enumArray.forEach((x) => {
    struct[x] = undefined;
  });
  let [key, value] = parseEnumObject(option);
  struct[key] = value;
  return new CairoCustomEnum(struct);
};

const parseEnumObject = (obj) => {
  if (["string"].includes(typeof obj)) {
    return [obj, {}];
  } else {
    for (const o in obj) {
      return [o, obj[o]];
    }
  }
};

const makeEffectStruct = (effect) => {
  let [key, affect] = parseEnumObject(effect.affect);

  if (key == "Stat") {
    effect.affect.Stat = parseNestedSignedStruct(
      makeCairoEnum([], value.stats)
    );
  } else if (["Health", "Stats"].includes(key)) {
    effect.affect = parseNestedSignedStruct(effect.affect);
  } else if (key == "Stats") {
    effect.affect = parseNestedSignedStruct(effect.affect);
  }
  return {
    target: makeCairoEnum([], effect.target),
    affect: makeCairoEnum([], effect.affect),
  };
};

const makeEffectsArray = (effects) => {
  let effectsArray = [];
  effects.forEach((effect) => {
    effectsArray.push(makeEffectStruct(effect));
  });
  return effectsArray;
};

const makeAttacksStruct = (attacks) => {
  let attacksStructs = [];
  for (const attack of attacks) {
    attacksStructs.push({
      name: attack.name,
      // name: byteArray.byteArrayFromString(attack.name),
      speed: attack.speed,
      accuracy: attack.accuracy,
      cooldown: attack.cooldown,
      hit: makeEffectsArray(attack.hit),
      miss: makeEffectsArray(attack.miss),
    });
  }
  return attacksStructs;
};

const makeItemCallData = (trait, n, item) => {
  const trait_str = trait.charAt(0).toUpperCase() + trait.slice(1);
  return {
    blobert_trait: makeCairoEnum([], trait_str),
    trait_id: Number(n),
    // item_name: byteArray.byteArrayFromString(item.name),
    item_name: item.name,
    stats: item.stats,
    attacks: makeAttacksStruct(item.attacks),
  };
};

const makeCall = (address, entrypoint, calldata) => {
  return blobertContract.populate(entrypoint, calldata);
  // return {
  //   contractAddress: address,
  //   entrypoint: ,
  //   calldata: CallData.compile(calldata),
  // };
};

let calls = [];
// for (const [trait, traits] of Object.entries(seed_data)) {
//   for (const [n, item] of Object.entries(traits)) {
//     console.log(`seed: ${item.name}`);
//     calls.push([
//       `seed: ${item.name}`,
//       makeCall(
//         blobertContractAddress,
//         seedEntrypoint,
//         makeItemCallData(trait, n, item)
//       ),
//     ]);
//   }
// }

// for (const [n, traits] of Object.entries(custom_data)) {
//   for (const [trait, item] of Object.entries(traits)) {
//     calls.push([
//       `custom: ${item.name}`,
//       makeCall(
//         blobertContractAddress,
//         customEntrypoint,
//         makeItemCallData(trait, n, item)
//       ),
//     ]);
//   }
// }

for (const [n, fighter] of Object.entries(amma_data)) {
  let custom_id = Number(n) + amma_offset;
  calls.push([
    `fighter ${fighter.name}`,
    makeCall(arcadeBlobertAddress, "set_amma_fighter", {
      fighter_id: n,
      name: byteArray.byteArrayFromString(fighter.name),
      custom_id: custom_id,
    }),
  ]);
  for (const [trait, item] of Object.entries(fighter.traits)) {
    calls.push([
      `custom: ${item.name}`,
      makeCall(
        blobertContractAddress,
        customEntrypoint,
        makeItemCallData(trait, custom_id, item)
      ),
    ]);
  }
}

const multiCallSize = 20;
for (let i = 0, x = 0; i < calls.length; i += multiCallSize, x += 1) {
  const chunk = calls.slice(i, i + multiCallSize);
  const names = chunk.map(([name, call]) => name);
  const multicall = chunk.map(([name, call]) => call);
  console.log(names);
  const transaction = await account.execute(multicall);
  const response = await provider.waitForTransaction(
    transaction.transaction_hash
  );
  console.log(response.transaction_hash);
}
