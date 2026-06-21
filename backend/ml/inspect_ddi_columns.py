"""
Run ONLY the first code cell of drug_interaction_checker.ipynb
to discover the CSV's real columns. Prints columns and sample rows, then stops.
"""
import json
import sys
from pathlib import Path

# Load the notebook
nb_path = Path(__file__).parent / "notebooks" / "drug_interaction_checker.ipynb"
with open(nb_path, "r", encoding="utf-8") as f:
    nb = json.load(f)

# Collect the first two code cells (imports + load/inspect)
code_cells = [c for c in nb["cells"] if c["cell_type"] == "code"]

if len(code_cells) < 2:
    print("ERROR: Expected at least 2 code cells, found", len(code_cells))
    sys.exit(1)

# Run cells 0 (imports) and 1 (load + inspect)
combined_code = ""
for i, cell in enumerate(code_cells[:2]):
    source = "".join(cell["source"])
    combined_code += f"\n# --- Cell {i} ---\n{source}\n"

print("=" * 60)
print("Running first 2 code cells of drug_interaction_checker.ipynb")
print("=" * 60)
print()

exec(combined_code)
