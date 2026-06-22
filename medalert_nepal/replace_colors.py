import os

replacements = {
    "Colors.white": "Theme.of(context).colorScheme.surface",
    "Colors.black": "Theme.of(context).colorScheme.onSurface",
    "const Color(0xFF0F172A)": "Theme.of(context).colorScheme.onSurface",
    "Color(0xFF0F172A)": "Theme.of(context).colorScheme.onSurface",
    "const Color(0xFFF8FAFC)": "Theme.of(context).colorScheme.surfaceContainerLowest",
    "Color(0xFFF8FAFC)": "Theme.of(context).colorScheme.surfaceContainerLowest",
    "const Color(0xFFF1F5F9)": "Theme.of(context).colorScheme.surfaceContainer",
    "Color(0xFFF1F5F9)": "Theme.of(context).colorScheme.surfaceContainer",
    "const Color(0xFFE2E8F0)": "Theme.of(context).colorScheme.outlineVariant",
    "Color(0xFFE2E8F0)": "Theme.of(context).colorScheme.outlineVariant",
    "const Color(0xFF334155)": "Theme.of(context).colorScheme.outlineVariant",
    "Color(0xFF334155)": "Theme.of(context).colorScheme.outlineVariant",
    "const Color(0xFF64748B)": "Theme.of(context).colorScheme.onSurfaceVariant",
    "Color(0xFF64748B)": "Theme.of(context).colorScheme.onSurfaceVariant",
    "const Color(0xFF94A3B8)": "Theme.of(context).colorScheme.onSurfaceVariant",
    "Color(0xFF94A3B8)": "Theme.of(context).colorScheme.onSurfaceVariant",
    "AppTheme.primaryColor": "Theme.of(context).colorScheme.primary"
}

target_dirs = [
    r"c:\Users\Acer\Documents\Projects\Coding\Minor_Projects\sixsem\Medicine-Availability-Emergency-Finder\medalert_nepal\lib\screens",
    r"c:\Users\Acer\Documents\Projects\Coding\Minor_Projects\sixsem\Medicine-Availability-Emergency-Finder\medalert_nepal\lib\widgets"
]

ignore_files = ["app_theme.dart", "availability_badge.dart"]

for d in target_dirs:
    for root, dirs, files in os.walk(d):
        for file in files:
            if file.endswith(".dart") and file not in ignore_files:
                path = os.path.join(root, file)
                with open(path, "r", encoding="utf-8") as f:
                    content = f.read()
                
                new_content = content
                for old, new in replacements.items():
                    new_content = new_content.replace(old, new)
                
                # Special cases for .withValues(alpha: ...) or .withOpacity
                new_content = new_content.replace(
                    "Theme.of(context).colorScheme.surface.withValues(alpha:", 
                    "Theme.of(context).colorScheme.surface.withValues(alpha:"
                )
                
                if new_content != content:
                    with open(path, "w", encoding="utf-8") as f:
                        f.write(new_content)
                    print(f"Updated {file}")
