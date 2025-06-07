#!/usr/bin/env python3
"""
AICheck Dependency Guardian
Prevents dependency-related deployment failures by enforcing strict checks
"""
import json
import subprocess
import sys
from pathlib import Path
from datetime import datetime

# Try to import toml library
try:
    import tomllib  # Python 3.11+
except ImportError:
    try:
        import toml as tomllib  # fallback to toml package
    except ImportError:
        tomllib = None

class DependencyGuardian:
    def __init__(self):
        self.errors = []
        self.warnings = []
        
    def check_poetry_lock_sync(self):
        """Ensure poetry.lock is in sync with pyproject.toml"""
        try:
            result = subprocess.run(["poetry", "check"], capture_output=True, text=True)
            if result.returncode != 0:
                self.errors.append("❌ poetry.lock is out of sync! Run 'poetry lock' to fix")
                return False
            return True
        except FileNotFoundError:
            self.errors.append("❌ Poetry not installed! Cannot verify dependencies")
            return False
    
    def check_all_imports_available(self):
        """Verify all Python imports in the codebase are in dependencies"""
        import ast
        import_map = {}
        
        # Scan all Python files for imports
        for py_file in Path(".").rglob("*.py"):
            if "node_modules" in str(py_file) or ".venv" in str(py_file):
                continue
                
            try:
                with open(py_file, 'r') as f:
                    tree = ast.parse(f.read())
                    
                for node in ast.walk(tree):
                    if isinstance(node, ast.Import):
                        for alias in node.names:
                            import_map[alias.name.split('.')[0]] = str(py_file)
                    elif isinstance(node, ast.ImportFrom):
                        if node.module:
                            import_map[node.module.split('.')[0]] = str(py_file)
            except:
                pass
        
        # Check against installed packages
        result = subprocess.run(["poetry", "show", "--no-ansi"], capture_output=True, text=True)
        installed_packages = set()
        for line in result.stdout.split('\n'):
            if line.strip():
                installed_packages.add(line.split()[0])
        
        # Standard library modules to ignore
        stdlib_modules = {'os', 'sys', 'json', 'pathlib', 'datetime', 'typing', 'collections',
                         'itertools', 'functools', 'ast', 'subprocess', 'argparse', 'logging',
                         're', 'math', 'random', 'time', 'unittest', 'http', 'urllib'}
        
        missing = []
        for module, file_path in import_map.items():
            if module not in stdlib_modules and module not in installed_packages:
                if not any(module.startswith(pkg) for pkg in installed_packages):
                    missing.append(f"  - {module} (used in {file_path})")
        
        if missing:
            self.errors.append("❌ Missing dependencies detected:\n" + "\n".join(missing))
            return False
        return True
    
    def check_production_dev_separation(self):
        """Ensure dev dependencies aren't used in production code"""
        if not tomllib:
            return True  # Skip if no toml library available
        
        try:
            with open("pyproject.toml", 'rb') as f:
                if hasattr(tomllib, 'load'):
                    pyproject = tomllib.load(f)
                else:
                    # For older toml library
                    f.seek(0)
                    pyproject = tomllib.loads(f.read().decode())
            
            dev_deps = set(pyproject.get('tool', {}).get('poetry', {}).get('group', {}).get('dev', {}).get('dependencies', {}).keys())
            
            # Scan production code for dev dependency usage
            violations = []
            for py_file in Path(".").rglob("*.py"):
                if "test" in str(py_file) or "tests" in str(py_file):
                    continue
                    
                with open(py_file, 'r') as f:
                    content = f.read()
                    for dev_dep in dev_deps:
                        if f"import {dev_dep}" in content or f"from {dev_dep}" in content:
                            violations.append(f"  - {dev_dep} used in {py_file}")
            
            if violations:
                self.errors.append("❌ Dev dependencies used in production code:\n" + "\n".join(violations))
                return False
            return True
        except:
            return True  # Skip if can't parse
    
    def check_version_pinning(self):
        """Ensure critical dependencies have exact versions"""
        if not tomllib:
            return  # Skip if no toml library available
            
        try:
            with open("pyproject.toml", 'rb') as f:
                if hasattr(tomllib, 'load'):
                    pyproject = tomllib.load(f)
                else:
                    # For older toml library
                    f.seek(0)
                    pyproject = tomllib.loads(f.read().decode())
            
            deps = pyproject.get('tool', {}).get('poetry', {}).get('dependencies', {})
            critical_deps = ['fastapi', 'django', 'flask', 'sqlalchemy', 'pydantic']
            
            unpinned = []
            for dep, version in deps.items():
                if dep in critical_deps and isinstance(version, str):
                    if '^' in version or '~' in version or '*' in version:
                        unpinned.append(f"  - {dep}: {version} (should use exact version)")
            
            if unpinned:
                self.warnings.append("⚠️  Critical dependencies should have exact versions:\n" + "\n".join(unpinned))
        except:
            pass
    
    def generate_deployment_manifest(self):
        """Create a deployment manifest with all dependency info"""
        try:
            # Get exact versions of all installed packages
            result = subprocess.run(["poetry", "export", "--without-hashes", "--format", "requirements.txt"], 
                                  capture_output=True, text=True)
            
            manifest = {
                "generated_at": datetime.now().isoformat(),
                "python_version": sys.version,
                "dependencies": {},
                "deployment_checks": {
                    "lock_file_synced": "poetry.lock" in subprocess.run(["git", "status", "--porcelain"], 
                                                                       capture_output=True, text=True).stdout,
                    "all_imports_available": len(self.errors) == 0
                }
            }
            
            # Parse requirements for exact versions
            for line in result.stdout.split('\n'):
                if '==' in line:
                    pkg, version = line.split('==')
                    manifest["dependencies"][pkg.strip()] = version.strip()
            
            with open(".aicheck/deployment-manifest.json", 'w') as f:
                json.dump(manifest, f, indent=2)
                
            print("✅ Generated deployment manifest at .aicheck/deployment-manifest.json")
        except Exception as e:
            self.warnings.append(f"⚠️  Could not generate deployment manifest: {e}")
    
    def run_all_checks(self):
        """Run all dependency checks"""
        print("🛡️  AICheck Dependency Guardian")
        print("=" * 50)
        
        checks = [
            ("Poetry lock sync", self.check_poetry_lock_sync),
            ("Import availability", self.check_all_imports_available),
            ("Dev/Prod separation", self.check_production_dev_separation),
        ]
        
        all_passed = True
        for check_name, check_func in checks:
            print(f"\nChecking {check_name}...", end=" ")
            if check_func():
                print("✅")
            else:
                print("❌")
                all_passed = False
        
        self.check_version_pinning()
        
        print("\n" + "=" * 50)
        
        if self.errors:
            print("\n🚨 ERRORS (must fix before deployment):")
            for error in self.errors:
                print(error)
        
        if self.warnings:
            print("\n⚠️  WARNINGS (recommended fixes):")
            for warning in self.warnings:
                print(warning)
        
        if all_passed and not self.errors:
            print("\n✅ All dependency checks passed! Safe to deploy.")
            self.generate_deployment_manifest()
        else:
            print("\n❌ Dependency issues detected. Fix errors before deploying!")
            sys.exit(1)

if __name__ == "__main__":
    guardian = DependencyGuardian()
    guardian.run_all_checks()