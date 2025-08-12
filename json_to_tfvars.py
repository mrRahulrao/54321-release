import argparse, json, os, sys

if __name__ == "__main__":
  ap = argparse.ArgumentParser()
  ap.add_argument("--json", required=True)
  ap.add_argument("--out", required=True)
  args = ap.parse_args()
  data = json.load(open(args.json))
  # For simplicity we only emit VM section into tfvars for MVP
  tfvars = {
    "subscription_id": "SUBSCRIPTION_ID_DEV",
    "location": "southeastasia"
  }
  # Also persist the full prompt JSON in env to be read by locals
  os.makedirs(os.path.dirname(args.out), exist_ok=True)
  with open(args.out, "w") as f:
    json.dump(data, f, indent=2)
  print(f"Wrote {args.out}")
