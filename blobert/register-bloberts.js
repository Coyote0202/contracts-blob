import "dotenv";
import { RpcProvider, Contract, Account, CairoCustomEnum } from "starknet";
import seed_data from "./seed-attributes.json" assert { type: "json" };
import custom_data from "./custom-attributes.json" assert { type: "json" };

const provider = new RpcProvider({ nodeUrl: process.env.STARKNET_RPC_URL });
const account1Address = process.env.DOJO_ACCOUNT_ADDRESS;
const privateKey1 = process.env.DOJO_PRIVATE_KEY;
const account = new Account(provider, account1Address, privateKey1);
const blobertContractAddress =
  "0x299968317ad9c2c2f3d8a8063b1881468aa9e3a1eaa58754f006f375b719562";
const itemsContractAddress =
  "0x760d529b82b05c099e0ee1e6dc10bdf0825eaefdb603e0315c6f4747d60f53a";

const { abi: blobertContractAbi } = await provider.getClassAt(
  blobertContractAddress
);
const { abi: itemsContractAbi } = await provider.getClassAt(
  itemsContractAddress
);
const blobertContract = new Contract(
  blobertContractAbi,
  blobertContractAddress,
  provider
);
const itemsContract = new Contract(
  itemsContractAbi,
  itemsContractAddress,
  provider
);

blobertContract.connect(account);
itemsContract.connect(account);

const newItem = async (provider, contract, item) => {
  const res = await contract.new_item_with_attacks(
    item.name,
    item.stats,
    item.attacks
  );
  await provider.waitForTransaction(res.transaction_hash);
  console.log(res.transaction_hash);
  const events = (await provider.getTransactionReceipt(res.transaction_hash))
    .events;
  return events[events.length - 2].data[2];
};

const setSeedItemId = async (provider, contract, trait, n, item_id) => {
  const enumString = trait.charAt(0).toUpperCase() + trait.slice(1);
  const res = await contract.set_seed_item_id(
    new CairoCustomEnum({ [enumString]: null }),
    n,
    item_id
  );
  console.log(res.transaction_hash);
  await provider.waitForTransaction(res.transaction_hash);
};

const setCustomItem = async (provider, contract, trait, n, item_id) => {
  const enumString = trait.charAt(0).toUpperCase() + trait.slice(1);
  const res = await contract.set_custom_item_id(
    new CairoCustomEnum({ [enumString]: null }),
    n,
    item_id
  );
  console.log(res.transaction_hash);
  await provider.waitForTransaction(res.transaction_hash);
};

const setupSeedItem = async (
  provider,
  itemsContract,
  blobertContract,
  trait,
  n,
  item
) => {
  console.log(trait, n, item.name);
  const item_id = await newItem(provider, itemsContract, item);
  console.log(item_id);
  await setSeedItemId(provider, blobertContract, trait, n, item_id);
};

const setupCustomItem = async (
  provider,
  itemsContract,
  blobertContract,
  trait,
  n,
  item
) => {
  console.log(trait, n, item.name);
  const item_id = await newItem(provider, itemsContract, item);
  console.log(item_id);
  await setCustomItem(provider, blobertContract, trait, n, item_id);
};

for (const [trait, traits] of Object.entries(seed_data)) {
  for (const [n, item] of Object.entries(traits)) {
    await setupSeedItem(
      provider,
      itemsContract,
      blobertContract,
      trait,
      Number(n),
      item
    );
  }
}

for (const [n, traits] of Object.entries(custom_data)) {
  for (const [trait, item] of Object.entries(traits)) {
    await setCustomItem(
      provider,
      itemsContract,
      blobertContract,
      trait,
      Number(n),
      item
    );
  }
}
