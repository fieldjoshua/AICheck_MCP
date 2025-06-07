#!/usr/bin/env python3
"""
AICheck Router Verification Script
Ensures all FastAPI routers are properly mounted in the application
"""

import ast
import os
import sys
from pathlib import Path
from typing import List, Set, Tuple

class RouterVerifier:
    def __init__(self, project_root: Path = None):
        self.project_root = project_root or Path.cwd()
        self.routers_found: Set[str] = set()
        self.routers_mounted: Set[str] = set()
        self.errors: List[str] = []
        
    def find_router_files(self) -> List[Path]:
        """Find all Python files that might contain routers"""
        router_files = []
        
        # Common patterns for router files
        patterns = [
            "**/routers/**/*.py",
            "**/routes/**/*.py",
            "**/api/**/*.py",
            "**/endpoints/**/*.py",
            "**/*router*.py",
            "**/*route*.py"
        ]
        
        for pattern in patterns:
            router_files.extend(self.project_root.glob(pattern))
            
        # Remove duplicates and filter out __pycache__
        router_files = list(set(f for f in router_files 
                               if "__pycache__" not in str(f) 
                               and f.suffix == ".py"))
        
        return router_files
    
    def extract_routers_from_file(self, file_path: Path) -> List[str]:
        """Extract router definitions from a Python file"""
        routers = []
        
        try:
            with open(file_path, 'r') as f:
                tree = ast.parse(f.read())
                
            for node in ast.walk(tree):
                # Look for APIRouter instantiation
                if isinstance(node, ast.Assign):
                    if isinstance(node.value, ast.Call):
                        if hasattr(node.value.func, 'id') and node.value.func.id == 'APIRouter':
                            for target in node.targets:
                                if hasattr(target, 'id'):
                                    routers.append(target.id)
                        elif hasattr(node.value.func, 'attr') and node.value.func.attr == 'APIRouter':
                            for target in node.targets:
                                if hasattr(target, 'id'):
                                    routers.append(target.id)
                                    
        except Exception as e:
            self.errors.append(f"Error parsing {file_path}: {e}")
            
        return routers
    
    def find_main_app_file(self) -> Path:
        """Find the main application file"""
        # Common patterns for main app files
        candidates = [
            "main.py",
            "app.py",
            "application.py",
            "server.py",
            "api.py",
            "src/main.py",
            "src/app.py",
            "app/main.py",
            "app/app.py"
        ]
        
        for candidate in candidates:
            path = self.project_root / candidate
            if path.exists():
                return path
                
        # If not found in standard locations, search for FastAPI app
        for py_file in self.project_root.glob("**/*.py"):
            if "__pycache__" in str(py_file):
                continue
                
            try:
                with open(py_file, 'r') as f:
                    content = f.read()
                    if "FastAPI()" in content or "FastAPI(" in content:
                        return py_file
            except:
                continue
                
        return None
    
    def check_router_mounting(self, main_file: Path) -> Set[str]:
        """Check which routers are mounted in the main app file"""
        mounted = set()
        
        try:
            with open(main_file, 'r') as f:
                content = f.read()
                tree = ast.parse(content)
                
            for node in ast.walk(tree):
                # Look for app.include_router() calls
                if isinstance(node, ast.Call):
                    if hasattr(node.func, 'attr') and node.func.attr == 'include_router':
                        if len(node.args) > 0:
                            arg = node.args[0]
                            if hasattr(arg, 'id'):
                                mounted.add(arg.id)
                                
        except Exception as e:
            self.errors.append(f"Error checking router mounting in {main_file}: {e}")
            
        return mounted
    
    def verify_all_routers(self) -> Tuple[bool, List[str]]:
        """Main verification function"""
        print("Verifying router registration...")
        
        # Find all router files
        router_files = self.find_router_files()
        
        if not router_files:
            print("No router files found. This might not be a FastAPI project.")
            return True, []
        
        print(f"Found {len(router_files)} potential router files")
        
        # Extract routers from each file
        for file in router_files:
            routers = self.extract_routers_from_file(file)
            self.routers_found.update(routers)
            
        if not self.routers_found:
            print("No router definitions found.")
            return True, []
            
        print(f"Found {len(self.routers_found)} router definitions: {', '.join(self.routers_found)}")
        
        # Find main app file
        main_file = self.find_main_app_file()
        
        if not main_file:
            self.errors.append("Could not find main application file (main.py, app.py, etc.)")
            return False, self.errors
            
        print(f"Checking router mounting in: {main_file}")
        
        # Check which routers are mounted
        self.routers_mounted = self.check_router_mounting(main_file)
        
        # Find unmounted routers
        unmounted = self.routers_found - self.routers_mounted
        
        if unmounted:
            self.errors.append(f"Unmounted routers found: {', '.join(unmounted)}")
            self.errors.append(f"Please ensure all routers are included with app.include_router()")
            return False, self.errors
            
        print(f"✓ All {len(self.routers_found)} routers are properly mounted!")
        return True, []


def main():
    """Main entry point"""
    verifier = RouterVerifier()
    success, errors = verifier.verify_all_routers()
    
    if not success:
        print("\n❌ Router verification failed:")
        for error in errors:
            print(f"  - {error}")
        sys.exit(1)
    else:
        print("\n✅ Router verification passed!")
        sys.exit(0)


if __name__ == "__main__":
    main()