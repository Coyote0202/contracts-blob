import "dotenv";
import {
  RpcProvider,
  Account,
  CairoCustomEnum,
  CallData,
  byteArray,
} from "starknet";
import seed_data from "./seed-attributes.json" with { type: "json" };
// import custom_data from "./custom-attributes.json" assert { type: "json" };
const provider = new RpcProvider({ nodeUrl: process.env.STARKNET_RPC_URL });
const account1Address = process.env.DOJO_ACCOUNT_ADDRESS;
const privateKey1 = process.env.DOJO_PRIVATE_KEY;
const account = new Account(provider, account1Address, privateKey1);
const blobertContractAddress =
  "0x1df087ac9ca9df0b642d0ee843c9c083e299f3d67c7d5aa8d49656d0fec6790";


const traitsEnum = ["background", "armour", "jewelry", "mask", "weapon",];

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
}
const makeSeedItemsMultiCall = (items) => {
  let calls = [];
  for (const [trait, n, item] of items) {
    const traitIndex = traitsEnum.indexOf(trait);
    const calldata = {
      blobert_trait: traitIndex,
      trait_id: n,
      item_name: byteArray.byteArrayFromString(item.name),
      stats: item.stats,
      attacks: makeAttacksStruct(item.attacks),
    };
    console.log(trait, n, item.name, traitIndex, calldata.blobert_trait)
    const call = {
      contractAddress: blobertContractAddress,
      entrypoint: "new_seed_item_with_attacks",
      calldata: CallData.compile(calldata),
    }
    calls.push(call);
    // console.log(calldata)
  }
  return calls;
};



let items = [];
for (const [trait, traits] of Object.entries(seed_data)) {
  for (const [n, item] of Object.entries(traits)) {
    items.push([trait, n, item]);
  }
}
const multiCallSize = 20;
for (let i = 0, x = 0; i < items.length; i += multiCallSize, x+= 1) {
  const chunk = items.slice(i, i + multiCallSize);
  const names = chunk.map(([trait, n, item]) => item.name);
  
  const calls = makeSeedItemsMultiCall(chunk);
  console.log(`Uploading items ${names}`);
  const transaction = await account.execute(calls);
  const response = await provider.waitForTransaction(transaction.transaction_hash);
  console.log(response.transaction_hash)
}

