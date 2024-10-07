import mainfest from "../manifests/sepolia/deployment/manifest.json" with { type: "json" };


const getContractAddress = (mainfest, contractName) => {
  for (const contract of mainfest.contracts) {
    console.log(contract.tag)
    if (contract.tag === contractName) {
      return contract.address;
    }
  }
  return null;
}
console.log(getContractAddress(mainfest, "blob_arena-arcade_blobert_actions"));