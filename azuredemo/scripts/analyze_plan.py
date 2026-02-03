import json
import sys

def main(path):
    with open(path, "r") as f:
        plan = json.load(f)

    findings = []
    risk = "LOW"

    for rc in plan.get("resource_changes", []):
        if rc.get("type") == "azurerm_network_security_group":
            after = rc.get("change", {}).get("after", {})
            for rule in after.get("security_rule", []):
                if rule.get("access") == "Allow" and rule.get("direction") == "Inbound":
                    if rule.get("source_address_prefix") in ["0.0.0.0/0", "*"]:
                        findings.append("Public SSH access detected")
                        risk = "HIGH"

    print(json.dumps({
        "risk_level": risk,
        "findings": findings
    }, indent=2))

    if risk == "HIGH":
        sys.exit(2)

if __name__ == "__main__":
    main(sys.argv[1])
