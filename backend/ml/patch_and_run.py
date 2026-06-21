"""
Patch notebook paths and run them.
Fixes:
  - DATA_DIR: ./data -> ../datasets  (data lives in backend/ml/datasets/)
  - OUTPUT_DIR: ./models -> ../models (output to backend/ml/models/)
  - DDI notebook: drug_drug_interactions.csv -> db_drug_interactions.csv
"""
import json
import sys
from pathlib import Path

NOTEBOOKS_DIR = Path(__file__).parent / "notebooks"

def patch_cell_source(cell, replacements):
    """Replace strings in a cell's source lines."""
    new_source = []
    changed = False
    for line in cell["source"]:
        for old, new in replacements:
            if old in line:
                line = line.replace(old, new)
                changed = True
        new_source.append(line)
    cell["source"] = new_source
    return changed

def patch_notebook(nb_path, replacements):
    with open(nb_path, "r", encoding="utf-8") as f:
        nb = json.load(f)
    
    total_changes = 0
    for cell in nb["cells"]:
        if cell["cell_type"] == "code":
            if patch_cell_source(cell, replacements):
                total_changes += 1
    
    with open(nb_path, "w", encoding="utf-8") as f:
        json.dump(nb, f, indent=1, ensure_ascii=False)
    
    print(f"  Patched {nb_path.name}: {total_changes} cell(s) modified")

def main():
    # Common path fixes for all notebooks
    common_replacements = [
        ('Path("./data")', 'Path("../datasets")'),
        ('Path("./models")', 'Path("../models")'),
    ]
    
    # Patch drug_review_sentiment.ipynb
    patch_notebook(
        NOTEBOOKS_DIR / "drug_review_sentiment.ipynb",
        common_replacements
    )
    
    # Patch symptom_checker.ipynb
    patch_notebook(
        NOTEBOOKS_DIR / "symptom_checker.ipynb",
        common_replacements
    )
    
    # Patch drug_interaction_checker.ipynb — also fix CSV filename
    patch_notebook(
        NOTEBOOKS_DIR / "drug_interaction_checker.ipynb",
        common_replacements + [
            ('drug_drug_interactions.csv', 'db_drug_interactions.csv'),
        ]
    )
    
    print("\nAll notebooks patched successfully.")

if __name__ == "__main__":
    main()
