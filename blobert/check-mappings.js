import { hash, cairo } from "starknet";
import fetch from "node-fetch"; // Assuming you're running this in Node.js

// Function to perform the GraphQL request
async function fetchGraphQL(felt, type, traitNumber, hashValue) {
  const response = await fetch("https://torii.blobarena.xyz/graphql", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      query: `query {
                itemMapModels (where: {blobert_trait_id: "${felt}"}){
                    edges {
                        node {
                            entity {
                                keys
                                models {
                                    __typename
                                    ... on ItemMap {
                                        blobert_trait_id
                                        item_id
                                    }
                                }
                            }
                        }
                    }
                }
            }`,
    }),
  });

  const data = await response.json();

  if (data.data.itemMapModels.edges.length > 0) {
    console.log(`Match found for type: ${type}, trait number: ${traitNumber}`);
    console.log(`Trait ID: ${felt}`);
    console.log(`Hash: ${hashValue}`);
    // console.log(JSON.stringify(data, null, 2));
  }
}
// Helper functions
function getFirstAndLastU128(hexStr) {
  if (!hexStr.startsWith("0x")) {
    hexStr = "0x" + hexStr;
  }

  hexStr = hexStr.slice(2);

  const segmentLength = 32;

  const firstSegment = hexStr.slice(0, segmentLength);

  const lastSegment = hexStr.slice(-segmentLength);

  const firstU128 =
    BigInt("0x" + firstSegment) & BigInt("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");
  const lastU128 =
    BigInt("0x" + lastSegment) & BigInt("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF");

  return {
    firstU128: "0x" + firstU128.toString(16).padStart(32, "0"),
    lastU128: "0x" + lastU128.toString(16).padStart(32, "0"),
  };
}

function decimalToHex(decimal) {
  return BigInt(decimal).toString(16);
}

// Main loop
async function main() {
  const types = ["mask", "armour", "jewelry", "background", "weapon"];
  const maxTraits = 30;

  for (let type of types) {
    for (let i = 0; i <= maxTraits; i++) {
      let seedFelt = cairo.felt("seed");
      let typeFelt = cairo.felt(type);
      let numberTraitFelt = cairo.felt(i);
      let arrOfFelts = [seedFelt, typeFelt, numberTraitFelt];
      let pedersanHash = hash.computePoseidonHashOnElements(
        arrOfFelts.map(BigInt)
      );
      let feltOfPedersanHash = cairo.felt(pedersanHash);

      let firstAndLastU128 = getFirstAndLastU128(
        decimalToHex(feltOfPedersanHash)
      );
      let lastU128Felt = cairo.felt(firstAndLastU128.lastU128);

      // Ensure it starts with 0x
      let lastU128FeltHex = decimalToHex(lastU128Felt);
      if (!lastU128FeltHex.startsWith("0x")) {
        lastU128FeltHex = "0x" + lastU128FeltHex;
      }

      console.log(
        `Checking type: ${type}, trait number: ${i} , hex: ${lastU128FeltHex}`
      );

      await fetchGraphQL(lastU128FeltHex, type, i, feltOfPedersanHash);
    }
  }
}

main().catch(console.error);
