import sys
import os
import subprocess
from pathlib import Path
import dotenv
import json

CONTRACT_PATH = Path(__file__).parent

dotenv.load_dotenv(CONTRACT_PATH / ".env.mainnet")

print(os.environ["STARKNET_RPC_URL"])
print(os.environ["DOJO_ACCOUNT_ADDRESS"])
print(os.environ["DOJO_PRIVATE_KEY"])


def get_name(string):
    return string.rsplit("::", 1)[-1]


def get_world(data):
    return data["world"]["address"]


def get_contracts_addresses(data):
    return {get_name(c["name"]): c["address"] for c in data["contracts"]}


def get_model_name(model):
    return next(
        get_name(s["name"]) for s in reversed(model["abi"]) if s["type"] == "struct"
    )


def get_models(data):
    return {get_model_name(m): m["name"] for m in data["models"]}


def run_cmd(cmd):
    # os.environ["SYSTEMD_COLORS"] = "1"
    print(cmd)
    # if type(cmd) is str:
    #     cmd = cmd.split(" ")
    # process = subprocess.Popen(cmd, cwd=cwd, stdout=subprocess.PIPE, encoding="utf-8")
    # for c in iter(lambda: process.stdout.read(1), ""):
    #     sys.stdout.write(c)


def make_authorisations_string(data: dict[str, list[str]], contract_addresses):
    return " ".join(
        [
            f"{m},{contract_addresses[contract]}"
            for contract, models in data.items()
            for m in models
        ]
    )
def parse_manifest(data):
    return " ".join([f"model:{w.split('-')[1]},{c['address']}" for c in data["contracts"] for w in c['writes']])
        

def main():
    manifest_path = CONTRACT_PATH / f"manifests/release/deployment/manifest.json"
    manifest = json.load(manifest_path.open())

    world_address = get_world(manifest)
    
    run_cmd(
        f"sozo --profile release auth grant writer --world {world_address} --private-key {os.environ['DOJO_PRIVATE_KEY']} {parse_manifest(manifest)}"
    )


main()
