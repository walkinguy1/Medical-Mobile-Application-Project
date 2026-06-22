import os
import re

target_dirs = [
    r"c:\Users\Acer\Documents\Projects\Coding\Minor_Projects\sixsem\Medicine-Availability-Emergency-Finder\medalert_nepal\lib\screens",
    r"c:\Users\Acer\Documents\Projects\Coding\Minor_Projects\sixsem\Medicine-Availability-Emergency-Finder\medalert_nepal\lib\widgets"
]

ignore_files = ["app_theme.dart", "availability_badge.dart"]

def fix_content(content):
    # Fix surfaceXX
    content = re.sub(r'Theme\.of\(context\)\.colorScheme\.surface(\d{2})', 
                     lambda m: f'Theme.of(context).colorScheme.surface.withValues(alpha: 0.{m.group(1)})', 
                     content)
    
    # Fix const Icon(..., color: Theme.of...) -> Icon(..., color: Theme.of...)
    content = re.sub(r'const\s+(Icon\([^)]*color:\s*Theme\.of\(context\)[^)]*\))', r'\1', content)
    
    # Fix const Divider(..., color: Theme.of...) -> Divider(..., color: Theme.of...)
    content = re.sub(r'const\s+(Divider\([^)]*color:\s*Theme\.of\(context\)[^)]*\))', r'\1', content)

    # Fix const BorderSide(..., color: Theme.of...) -> BorderSide(..., color: Theme.of...)
    content = re.sub(r'const\s+(BorderSide\([^)]*color:\s*Theme\.of\(context\)[^)]*\))', r'\1', content)

    # General fix for const Widget(..., Theme.of...)
    # This is a bit risky but let's try to remove const on lines that have Theme.of(context)
    # Actually, it's safer to just do it for lines with "const " and "Theme.of(context)"
    lines = content.split('\n')
    for i in range(len(lines)):
        if "Theme.of(context)" in lines[i] and "const " in lines[i]:
            # Carefully remove const if it applies to a widget
            lines[i] = re.sub(r'const\s+([A-Z]\w*\()', r'\1', lines[i])
    
    content = '\n'.join(lines)
    return content

for d in target_dirs:
    for root, dirs, files in os.walk(d):
        for file in files:
            if file.endswith(".dart") and file not in ignore_files:
                path = os.path.join(root, file)
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                
                new_content = fix_content(content)
                
                if new_content != content:
                    with open(path, "w", encoding="utf-8") as f:
                        f.write(new_content)
                    print(f"Fixed {file}")
