import json
import sys

ALLOWED_REGIONS = {"eastus", "centralus"}  # ajusta a tu demo
BLOCKED_VM_PREFIXES = ("Standard_NC", "Standard_NV")  # GPU / costosas
BLOCKED_VM_SIZES = {"Standard_D16s_v5"}  # ejemplo puntual si quieres

def walk_modules(module):
    """Yield resources from root_module and child_modules recursively."""
    if not module:
        return
    for r in module.get("resources", []) or []:
        yield r
    for child in module.get("child_modules", []) or []:
        yield from walk_modules(child)

def analyze_plan(plan_json: dict):
    findings = []
    risk = "LOW"

    planned = plan_json.get("planned_values", {}).get("root_module", {})
    for res in walk_modules(planned):
        rtype = res.get("type", "")
        values = res.get("values", {}) or {}

        # 1) Región no permitida (cubre muchos recursos)
        loc = (values.get("location") or "").lower().strip()
        if loc and loc not in ALLOWED_REGIONS:
            findings.append(f"Disallowed region detected: {rtype} in '{loc}' (allowed: {sorted(ALLOWED_REGIONS)})")
            risk = "HIGH"

        # 2) VM size no permitida (Linux + Windows VM)
        if rtype in ("azurerm_linux_virtual_machine", "azurerm_windows_virtual_machine"):
            size = (values.get("size") or "").strip()
            if size.startswith(BLOCKED_VM_PREFIXES) or size in BLOCKED_VM_SIZES:
                findings.append(f"Disallowed VM size detected: {size} on {rtype}")
                risk = "HIGH"

    return risk, findings

