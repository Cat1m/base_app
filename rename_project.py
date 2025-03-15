import os
import sys
import shutil
import subprocess
from pathlib import Path

# to use python rename_project.py new_name

def replace_in_file(file_path, old_text, new_text):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
        
        new_content = content.replace(old_text, new_text)
        
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(new_content)
            
        return True
    except Exception as e:
        print(f"Error replacing in {file_path}: {e}")
        return False

def find_and_replace_in_dir(dir_path, old_text, new_text, file_extensions=None):
    count = 0
    for root, _, files in os.walk(dir_path):
        for file in files:
            if file_extensions and not any(file.endswith(ext) for ext in file_extensions):
                continue
                
            file_path = os.path.join(root, file)
            try:
                if replace_in_file(file_path, old_text, new_text):
                    count += 1
            except (UnicodeDecodeError, IsADirectoryError):
                # Skip binary files and directories
                pass
    return count

def rename_flutter_rust_project(new_name):
    old_name = "base_app"
    old_rust_lib = f"rust_lib_{old_name}"
    new_rust_lib = f"rust_lib_{new_name}"
    old_bundle_id = f"com.example.{old_name}"
    new_bundle_id = f"com.example.{new_name}"
    
    print("=== Flutter+Rust Project Renamer ===")
    print(f"Renaming project from '{old_name}' to '{new_name}'")
    print(f"Bundle ID: {old_bundle_id} -> {new_bundle_id}")
    
    # Step 1: Use rename tool to change app name across platforms
    print("\n1. Changing app name with rename tool...")
    try:
        subprocess.run(
            ["rename", "setAppName", "--targets", "ios,android,macos,windows,linux,web", 
             "--value", new_name.replace("_", " ").title()],
            check=True
        )
        print("✅ App name changed successfully")
    except (subprocess.SubprocessError, FileNotFoundError) as e:
        print(f"⚠️ Warning: Could not run rename tool: {e}")
        print("  You may need to install it: flutter pub global activate rename")
        print("  Or change app names manually in the platform configuration files")
    
    # Step 2: Rename Kotlin package
    print("\n2. Renaming Kotlin package directory...")
    old_kotlin_dir = os.path.join("android", "app", "src", "main", "kotlin", "com", "example", old_name)
    new_kotlin_dir = os.path.join("android", "app", "src", "main", "kotlin", "com", "example", new_name)
    
    if os.path.exists(old_kotlin_dir):
        try:
            # Ensure parent directory exists
            os.makedirs(os.path.dirname(new_kotlin_dir), exist_ok=True)
            shutil.move(old_kotlin_dir, new_kotlin_dir)
            print(f"✅ Moved Kotlin directory: {old_kotlin_dir} -> {new_kotlin_dir}")
            
            # Update package name in MainActivity.kt
            kotlin_file = os.path.join(new_kotlin_dir, "MainActivity.kt")
            if os.path.exists(kotlin_file):
                replace_in_file(kotlin_file, f"package com.example.{old_name}", f"package com.example.{new_name}")
                print(f"✅ Updated package name in MainActivity.kt")
        except Exception as e:
            print(f"❌ Failed to rename Kotlin directory: {e}")
    else:
        print(f"⚠️ Kotlin directory not found: {old_kotlin_dir}")
    
    # Step 3: Rename Podspec files
    print("\n3. Renaming Podspec files...")
    for platform in ["ios", "macos"]:
        old_podspec = os.path.join("rust_builder", platform, f"{old_rust_lib}.podspec")
        new_podspec = os.path.join("rust_builder", platform, f"{new_rust_lib}.podspec")
        
        if os.path.exists(old_podspec):
            try:
                shutil.move(old_podspec, new_podspec)
                print(f"✅ Renamed podspec: {old_podspec} -> {new_podspec}")
            except Exception as e:
                print(f"❌ Failed to rename podspec {old_podspec}: {e}")
        else:
            print(f"⚠️ Podspec file not found: {old_podspec}")
    
    # Step 4: Find and replace in all files
    print("\n4. Performing find and replace across all files...")
    
    replacements = [
        (old_name, new_name),
        (old_rust_lib, new_rust_lib),
        (old_bundle_id, new_bundle_id)
    ]
    
    for old_text, new_text in replacements:
        count = find_and_replace_in_dir(".", old_text, new_text)
        print(f"✅ Replaced '{old_text}' with '{new_text}' in {count} files")
    
    print("\n=== Project rename completed! ===")
    print("\nNext steps:")
    print("1. Run 'flutter clean'")
    print("2. Run 'flutter pub get'")
    print("3. If building for iOS: Run 'cd ios && pod install && cd ..'")
    print("4. Run 'flutter run' to test your app")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python rename_project.py new_name")
        print("Example: python rename_project.py my_awesome_app")
        sys.exit(1)
        
    new_name = sys.argv[1].lower().replace(" ", "_")
    rename_flutter_rust_project(new_name)