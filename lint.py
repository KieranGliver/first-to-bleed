import subprocess
import os

def lint_all_gd_scripts(root_dir):
    for dirpath, _, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith(".gd"):
                filepath = os.path.join(dirpath, filename)
                print(f"Linting {filepath}...")
                subprocess.run(["gdlint", filepath])

if __name__ == "__main__":
    lint_all_gd_scripts(".")
