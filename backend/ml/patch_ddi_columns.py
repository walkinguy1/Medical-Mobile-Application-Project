"""
Patch the drug_interaction_checker notebook's column_rename_map cell
with the actual column names from db_drug_interactions.csv, then run it.
"""
import json
from pathlib import Path

nb_path = Path(__file__).parent / "notebooks" / "drug_interaction_checker.ipynb"

with open(nb_path, "r", encoding="utf-8") as f:
    nb = json.load(f)

# Find the cell containing column_rename_map and replace the commented-out map
# with the real mapping
old_map = """column_rename_map = {
    # "your_real_column_name": "drug_a",
    # "your_real_column_name": "drug_b",
    # "your_real_column_name": "interaction_text",
    # "your_real_column_name": "severity_raw",
}"""

new_map = """column_rename_map = {
    "Drug 1": "drug_a",
    "Drug 2": "drug_b",
    "Interaction Description": "interaction_text",
}"""

patched = False
for cell in nb["cells"]:
    if cell["cell_type"] == "code":
        source = "".join(cell["source"])
        if "column_rename_map" in source and "your_real_column_name" in source:
            new_source = source.replace(old_map, new_map)
            if new_source != source:
                cell["source"] = [new_source]
                patched = True
                print("Patched column_rename_map cell successfully.")
                break

if not patched:
    print("WARNING: Could not find the column_rename_map cell to patch!")
else:
    with open(nb_path, "w", encoding="utf-8") as f:
        json.dump(nb, f, indent=1, ensure_ascii=False)
    print("Notebook saved.")
