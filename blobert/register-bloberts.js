import { RpcProvider, Account, CallData, byteArray } from "starknet";

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
    console.log(contract.tag);
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

const traitsEnum = ["background", "armour", "jewelry", "mask", "weapon"];
const amma_offset = 50;

const provider = new RpcProvider({ nodeUrl: process.env.STARKNET_RPC_URL });
const account1Address = process.env.DOJO_ACCOUNT_ADDRESS;
const privateKey1 = process.env.DOJO_PRIVATE_KEY;
const account = new Account(provider, account1Address, privateKey1);

const blobertContractAddress = getContractAddress(manifest, blobertContractTag);
const arcadeBlobertAddress = getContractAddress(manifest, arcadeBlobertTag);

const makeAttacksStruct = (attacks) => {
  let attacksStructs = [];
  for (const attack of attacks) {
    attacksStructs.push({
      name: byteArray.byteArrayFromString(attack.name),
      damage: attack.damage,
      speed: attack.speed,
      accuracy: attack.accuracy,
      critical: attack.critical,
      stun: attack.stun,
      cooldown: attack.cooldown,
    });
  }
  return attacksStructs;
};

const makeItemCallData = (trait, n, item) => {
  return {
    blobert_trait: traitsEnum.indexOf(trait),
    trait_id: Number(n),
    item_name: byteArray.byteArrayFromString(item.name),
    stats: item.stats,
    attacks: makeAttacksStruct(item.attacks),
  };
};

const makeCall = (address, entrypoint, calldata) => {
  return {
    contractAddress: address,
    entrypoint: entrypoint,
    calldata: CallData.compile(calldata),
  };
};

let calls = [];
for (const [trait, traits] of Object.entries(seed_data)) {
  for (const [n, item] of Object.entries(traits)) {
    calls.push([
      `seed: ${item.name}`,
      makeCall(
        blobertContractAddress,
        seedEntrypoint,
        makeItemCallData(trait, n, item)
      ),
    ]);
  }
}

for (const [n, traits] of Object.entries(custom_data)) {
  for (const [trait, item] of Object.entries(traits)) {
    calls.push([
      `custom: ${item.name}`,
      makeCall(
        blobertContractAddress,
        customEntrypoint,
        makeItemCallData(trait, n, item)
      ),
    ]);
  }
}

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
