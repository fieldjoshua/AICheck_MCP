#!/usr/bin/env python3
"""
Simple dependency checker that doesn't require external libraries
"""
import subprocess
import sys
import json
from pathlib import Path

def check_poetry_lock():
    """Check if poetry.lock exists and is committed"""
    if not Path("poetry.lock").exists():
        print("❌ No poetry.lock file found")
        return False
    
    # Check if it's committed
    result = subprocess.run(["git", "status", "--porcelain", "poetry.lock"], 
                          capture_output=True, text=True)
    if result.stdout.strip():
        print("❌ poetry.lock has uncommitted changes")
        return False
    
    print("✅ poetry.lock is committed")
    return True

def check_package_lock():
    """Check if package-lock.json or yarn.lock exists and is committed"""
    for lock_file in ["package-lock.json", "yarn.lock"]:
        if Path(lock_file).exists():
            result = subprocess.run(["git", "status", "--porcelain", lock_file], 
                                  capture_output=True, text=True)
            if result.stdout.strip():
                print(f"❌ {lock_file} has uncommitted changes")
                return False
            print(f"✅ {lock_file} is committed")
            return True
    return True

def check_tests():
    """Run tests"""
    if Path("pyproject.toml").exists():
        print("Running Python tests...")
        result = subprocess.run(["poetry", "run", "pytest", "-q"], 
                              capture_output=True, text=True)
        if result.returncode != 0:
            print("❌ Python tests failed")
            return False
        print("✅ Python tests passed")
        return True
    elif Path("package.json").exists():
        print("Running Node.js tests...")
        result = subprocess.run(["npm", "test"], 
                              capture_output=True, text=True)
        if result.returncode != 0:
            print("❌ Node.js tests failed")
            return False
        print("✅ Node.js tests passed")
        return True
    return True

def main():
    print("🛡️  Simple Dependency Check")
    print("=" * 30)
    
    all_good = True
    
    if Path("pyproject.toml").exists():
        if not check_poetry_lock():
            all_good = False
    elif Path("package.json").exists():
        if not check_package_lock():
            all_good = False
    
    if not check_tests():
        all_good = False
    
    if all_good:
        print("\n✅ All checks passed!")
        sys.exit(0)
    else:
        print("\n❌ Some checks failed")
        sys.exit(1)

if __name__ == "__main__":
    main()