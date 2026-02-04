import json
import sys

# =======================
# CONFIGURACIÓN POLICIES
# =======================

ALLOWED_REGIONS = ["eastus", "westus2"]
BLOCKED_VM_SIZES = ["Standard_NC6_v3", "Standard_ND6s"]

MANDATORY_TAGS = [
    "owner",
    "costCenter",
    "environment",
    "application"
]

# Solo recursos Azure que REALMENTE soportan tags
TAGGABLE_TYPES = {
    "azurerm_resource_group",
    "azurerm_virtual_network",
    "azurerm_network_interface",
    "azurerm_linux_virtual_machine",
    "azurerm_windows_virtual_machine",
    "azurerm_network_security_group",
    "azurerm_public_ip",
}

# =======================
# HELPERS
# =======================

def walk_modules(module):
    if not module:
        return
    for r in module.get("resources", []):
        yield r
    for child in module.get("child_modules", []):
        yield from walk_modules(child)

def validate_mandatory_tags(resource_name, tags, findings):
    if not tags:
        findings.append(
            f"❌ {resource_name} has NO tags defined (mandatory: {MANDATORY_TAGS})"
        )
        return False

    missing = [
        tag for tag in MANDATORY_TAGS
        if tag not in tags or not tags[tag]
    ]

    if missing:
        findings.append(
            f"❌ {resource_name} is missing mandatory tags: {missing}"
        )
        return False

    return True

# =======================
# MAIN ANALYSIS
# =======================

def analyze_plan(plan_json):
    findings = []
    risk = "LOW"

    planned = plan_json.get("planned_values", {}).get("root_module", {})

    for res in walk_modules(planned):
        address = res.get("address", "")
        rtype = res.get("type", "")
        values = res.get("values", {}) or {}

        # 1️⃣ REGIÓN PERMITIDA
        location = (values.get("location") or "").lower()
        if location and location not in ALLOWED_REGIONS:
            findings.append(
                f"❌ Disallowed region → {address} in '{location}' "
                f"(allowed: {ALLOWED_REGIONS})"
            )
            risk = "HIGH"

        # 2️⃣ VM SIZE BLOQUEADA
        if rtype in ["azurerm_linux_virtual_machine", "azurerm_windows_virtual_machine"]:
            size = values.get("size", "")
            if size in BLOCKED_VM_SIZES:
                findings.append(
                    f"❌ Disallowed VM size → {size} on {address}"
                )
                risk = "HIGH"

        # 3️⃣ TAGS OBLIGATORIOS (IaC Governance)
        if rtype in TAGGABLE_TYPES:
            tags = values.get("tags")
            if not validate_mandatory_tags(address, tags, findings):
                risk = "HIGH"

        # 4️⃣ DEVSECOPS — Bloquear Public IP en NIC
        if rtype == "azurerm_network_interface":
            ip_configs = values.get("ip_configuration") or []
            for cfg in ip_configs:
                if cfg.get("public_ip_address_id"):
                    findings.append(
                        f"❌ Public IP not allowed → {address} has public_ip_address_id"
                    )
                    risk = "HIGH"

    return risk, findings

# =======================
# ENTRYPOINT
# =======================

def main():
    with open(sys.argv[1]) as f:
        plan = json.load(f)

    risk, findings = analyze_plan(plan)

    print("\n================ RESULTADO IaC GOVERNANCE ================\n")
    print(f"🔐 Risk level: {risk}\n")

    if findings:
        print("🚨 Policy violations detected:\n")
        for f in findings:
            print(f" - {f}")
        print("\n❌ Terraform Plan BLOCKED by governance policies\n")
        sys.exit(2)

    print("✅ No policy violations found")
    print("✅ Terraform Plan APPROVED\n")

if __name__ == "__main__":
    main()
