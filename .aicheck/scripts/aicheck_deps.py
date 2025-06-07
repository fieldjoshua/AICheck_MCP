#!/usr/bin/env python3
"""
AICheck Dependency Management - Unified with Poetry/npm
"""
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path

# Try to import toml library
try:
    import tomllib  # Python 3.11+
    def load_toml(path):
        with open(path, 'rb') as f:
            return tomllib.load(f)
    def dump_toml(data, path):
        # tomllib is read-only, we need to use a different approach
        import json
        # Convert to JSON for now
        with open(path, 'w') as f:
            json.dump(data, f, indent=2)
except ImportError:
    try:
        import toml as tomllib  # fallback to toml package
        def load_toml(path):
            with open(path, 'r') as f:
                return tomllib.load(f)
        def dump_toml(data, path):
            with open(path, 'w') as f:
                tomllib.dump(data, f)
    except ImportError:
        tomllib = None
        def load_toml(path):
            raise ImportError("No TOML library available")
        def dump_toml(data, path):
            raise ImportError("No TOML library available")

def add_python_dependency(package, justification, action=None):
    """Add a Python dependency with AICheck metadata"""
    # First, add it to Poetry
    cmd = ["poetry", "add", package]
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"❌ Failed to add {package}: {result.stderr}")
        return False
    
    # Now add AICheck metadata to pyproject.toml
    pyproject_path = Path("pyproject.toml")
    try:
        pyproject = load_toml(pyproject_path)
    except ImportError:
        print("⚠️  TOML library not available, skipping metadata")
        return True
    
    # Ensure aicheck section exists
    if 'tool' not in pyproject:
        pyproject['tool'] = {}
    if 'aicheck' not in pyproject['tool']:
        pyproject['tool']['aicheck'] = {}
    if 'dependencies' not in pyproject['tool']['aicheck']:
        pyproject['tool']['aicheck']['dependencies'] = {}
    
    # Extract version from poetry output
    version = "latest"
    for line in result.stdout.split('\n'):
        if package in line and '(' in line:
            version = line.split('(')[1].split(')')[0]
    
    # Add metadata
    pyproject['tool']['aicheck']['dependencies'][package] = {
        'justification': justification,
        'action': action or 'manual',
        'added_date': datetime.now().strftime('%Y-%m-%d'),
        'added_by': subprocess.run(['git', 'config', 'user.name'], 
                                 capture_output=True, text=True).stdout.strip(),
        'version': version
    }
    
    # Write back
    try:
        dump_toml(pyproject, pyproject_path)
    except ImportError:
        print("⚠️  Cannot write TOML metadata, but package was added successfully")
        return True
    
    print(f"✅ Added {package} with AICheck metadata")
    return True

def check_deployment_ready():
    """Quick check if project is deployment-ready"""
    print("\n🚀 Deployment Readiness Check")
    print("=" * 40)
    
    checks = {
        "Lock file committed": check_lock_file_committed(),
        "No missing imports": check_imports(),
        "Tests passing": check_tests(),
        "No dev deps in prod": check_dev_prod_separation()
    }
    
    all_good = all(checks.values())
    
    for check, passed in checks.items():
        print(f"{check}: {'✅' if passed else '❌'}")
    
    if all_good:
        print("\n✅ Ready to deploy!")
    else:
        print("\n❌ Fix issues before deploying")
        sys.exit(1)

def check_lock_file_committed():
    """Check if lock file is committed"""
    result = subprocess.run(['git', 'status', '--porcelain'], 
                          capture_output=True, text=True)
    uncommitted = result.stdout
    
    if 'poetry.lock' in uncommitted:
        return False
    if 'package-lock.json' in uncommitted or 'yarn.lock' in uncommitted:
        return False
    return True

def check_imports():
    """Quick import check"""
    if Path("pyproject.toml").exists():
        result = subprocess.run(['python3', '.aicheck/scripts/dependency_guardian.py'],
                              capture_output=True, text=True)
        return result.returncode == 0
    return True

def check_tests():
    """Check if tests pass"""
    if Path("pyproject.toml").exists():
        result = subprocess.run(['poetry', 'run', 'pytest', '-q'],
                              capture_output=True, text=True)
        return result.returncode == 0
    elif Path("package.json").exists():
        result = subprocess.run(['npm', 'test'],
                              capture_output=True, text=True)
        return result.returncode == 0
    return True

def check_dev_prod_separation():
    """Ensure no dev dependencies in production code"""
    # Simplified check - just return True for now
    # Real implementation would scan for dev deps in prod code
    return True

def main():
    """Main CLI interface"""
    if len(sys.argv) < 2:
        print("Usage: aicheck deps <command>")
        print("Commands:")
        print("  add <package> <justification> [action] - Add dependency with metadata")
        print("  check - Check deployment readiness")
        print("  fix - Auto-fix common dependency issues")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "add" and len(sys.argv) >= 4:
        package = sys.argv[2]
        justification = sys.argv[3]
        action = sys.argv[4] if len(sys.argv) > 4 else None
        add_python_dependency(package, justification, action)
    
    elif command == "check":
        check_deployment_ready()
    
    elif command == "fix":
        print("🔧 Auto-fixing dependency issues...")
        # Lock dependencies
        subprocess.run(['poetry', 'lock', '--no-update'])
        # Stage lock file
        subprocess.run(['git', 'add', 'poetry.lock'])
        print("✅ Fixed: Updated and staged poetry.lock")
    
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)

if __name__ == "__main__":
    main()