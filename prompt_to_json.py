import argparse, json, re, sys

SCHEMA = {
  "subscription": "dev",  # dev|stage|prod
  "vm": {
    "count": 1,
    "name": "vm-app-001",
    "vm_size": "Standard_E8s_v5",
    "admin_username": "azureuser",
    "ssh_public_key": "ssh-ed25519 AAAA...",
    "os_disk_type": "Premium_LRS",
    "os_disk_size_gb": 64,
    "data_disks": [],
    "public_ip": False,
    "resource_group": "rg-54321-appraps-dev",
    "image": { "publisher": "Canonical", "offer": "0001-com-ubuntu-server-jammy", "sku": "22_04-lts" }
  },
  "aks": { "create": False },
  "network": { "create": False }
}

def parse(prompt: str):
  p = prompt.lower()
  out = {"subscription": "dev", "vm": SCHEMA["vm"], "aks": {"create": False}, "network": {"create": False}}
  # naive parsing just for starter MVP
  if p.startswith("prod:"): out["subscription"] = "prod"
  elif p.startswith("stage:"): out["subscription"] = "stage"
  # vm count
  m = re.search(r"(\d+)\s*linux\s*vm", p)
  if m:
    out["vm"]["count"] = int(m.group(1))
  # cpu/ram
  m = re.search(r"(\d+)\s*vcpu.*?(\d+)\s*gb", p)
  if m:
    vcpu, mem = int(m.group(1)), int(m.group(2))
    # very simple mapping for demo
    if vcpu <= 8 and mem <= 64:
      out["vm"]["vm_size"] = "Standard_E8s_v5"
    elif vcpu <= 16 and mem <= 128:
      out["vm"]["vm_size"] = "Standard_E16s_v5"
  # disk
  m = re.search(r"(\d+)\s*gb\s*disk", p)
  if m:
    out["vm"]["data_disks"] = [{"size_gb": int(m.group(1)), "type": "Premium_LRS"}]
  # public ip
  if "no-public-ip" in p:
    out["vm"]["public_ip"] = False
  return out

if __name__ == "__main__":
  ap = argparse.ArgumentParser()
  ap.add_argument("--prompt", required=True)
  ap.add_argument("--out", required=True)
  args = ap.parse_args()
  parsed = parse(args.prompt)
  with open(args.out, "w") as f:
    json.dump(parsed, f, indent=2)
  print(f"Wrote {args.out}")
