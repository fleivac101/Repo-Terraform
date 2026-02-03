import json
import sys

ALLOWED_REGIONS = ["eastus", "westus2"]
BLOCKED_VM_SIZES = ["Standard_NC6_v3", "Standard_ND6s"]

def walk_modules(module):
    if not module:
        return
    for r in module.get("resources", []):
        yield r
    for child in module.get("child_modules", []):
        yield from walk_modules(child)

def analyze_plan(plan_json):
    findings = []
    risk = "LOW"

    planned = plan_json.get("planned_values", {}).get("root_module", {})
    for res in walk_modules(planned):
        rtype = res.get("type", "")
        values = res.get("values", {}) or {}

        # 1️⃣ Región no permitida
        location = (values.get("location") or "").lower()
        if location and location not in ALLOWED_REGIONS:
            findings.append(
                f"❌ Disallowed region → {rtype} in '{location}' (allowed: {ALLOWED_REGIONS})"
            )
            risk = "HIGH"

        # 2️⃣ VM size no permitida
        if rtype in ["azurerm_linux_virtual_machine", "azurerm_windows_virtual_machine"]:
            size = values.get("size", "")
            if size in BLOCKED_VM_SIZES:
                findings.append(
                    f"❌ Disallowed VM size → {size} on {rtype}"
                )
                risk = "HIGH"

    return risk, findings

def main():
    with open(sys.argv[1]) as f:
        plan = json.load(f)

    risk, findings = analyze_plan(plan)

    print("\n================ IaC GOVERNANCE RESULT ================\n")
    print(f"🔐 Risk level: {risk}\n")

    if findings:
        print("🚨 Policy violations detected:\n")
        for f in findings:
            print(f" - {f}")
        print("\n❌ Terraform Plan BLOCKED by governance policy\n")
        sys.exit(2)

    print("✅ No policy violations found")
    print("✅ Terraform Plan APPROVED\n")

if __name__ == "__main__":
    main()

