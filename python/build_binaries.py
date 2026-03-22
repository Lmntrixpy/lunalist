#!/usr/bin/env python3

import platform
import subprocess
import sys
import os
import yaml
import shutil
from pathlib import Path


def run_command(command: list[str]):
    try:
        executable = shutil.which(command[0])

        if executable is None:
            print(f"Command not found: {command[0]}")
            sys.exit(1)

        resolved_command = [executable, *command[1:]]

        print(f"Running: {' '.join(resolved_command)}")
        subprocess.run(resolved_command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Build failed with exit code {e.returncode}")
        sys.exit(e.returncode)


def is_macos() -> bool:
    return platform.system() == "Darwin"


def is_windows() -> bool:
    return platform.system() == "Windows"


def is_linux() -> bool:
    return platform.system() == "Linux"


def get_version():
    yml_path = "pubspec.yaml"
    with open(yml_path, "r") as f:
        data = yaml.full_load(f)
        version = data.get("version")
    return version

def main():
    if len(sys.argv) < 2:
        print("Usage: python build.py [ios|macos|windows|android|linux & version]")
        sys.exit(1)

    for i in range(1, len(sys.argv)):
        target = sys.argv[i].lower()
        version_number = get_version()

        host_os = platform.system()
        print(f"Host OS: {host_os}")
        print(f"Target: {target}")

        if target == "android":
            run_command(["flutter", "build", "apk", "--release"])
            destination = os.path.expanduser(f"~/Downloads/lunalist-{version_number}.apk")
            run_command(["cp",  "build/app/outputs/flutter-apk/app-release.apk", destination])

        elif target == "ios":
            if not is_macos():
                print("iOS builds are only supported on macOS.")
                sys.exit(1)
            run_command(["flutter", "build", "ipa", "--no-codesign"])

            destination = os.path.expanduser(f"~/Downloads/lunalist-{version_number}.xcarchive")

            run_command(["cp", "-r", "build/ios/archive/Runner.xcarchive", destination])

        elif target == "macos":
            if not is_macos():
                print("macOS builds are only supported on macOS.")
                sys.exit(1)
            run_command(["flutter", "build", "macos", "--release"])
            destination = os.path.expanduser("~/Downloads")
            run_command(["cp", "-r", "build/macos/Build/Products/Release/lunalist.app", destination])
            run_command(["create-dmg", f"{destination}/lunalist.app", destination])
            run_command(["rm", "-r", f"{destination}/lunalist.app"])

        elif target == "windows":
            if not is_windows():
                print("Windows builds are only supported on Windows.")
                sys.exit(1)

            project_root = Path(__file__).resolve().parent.parent
            env_file = project_root / ".env"
            windows_env = project_root / ".env.windows"
            backup_env = project_root / ".env.backup"

            if not windows_env.exists():
                print(f"Windows env file not found: {windows_env}")
                sys.exit(1)

            had_original_env = env_file.exists()

            try:
                if had_original_env:
                    if backup_env.exists():
                        backup_env.unlink()
                    os.replace(env_file, backup_env)

                shutil.copy2(windows_env, env_file)
                print(f"Using Windows env: {windows_env}")

                run_command(["dart", "run", "inno_bundle"])

            finally:
                try:
                    if env_file.exists():
                        env_file.unlink()
                except PermissionError:
                    print(f"Could not remove temporary env file: {env_file}")

                if backup_env.exists():
                    os.replace(backup_env, env_file)
                    print("Original .env restored")
                elif not had_original_env:
                    print("Temporary .env removed")

            build_dir = project_root / "build" / "windows" / "x64" / "installer" / "Release"
            downloads = Path.home() / "Downloads"

            exe_files = sorted(
                build_dir.glob("*.exe"),
                key=lambda f: f.stat().st_mtime,
                reverse=True
            )

            if not exe_files:
                print("No installer EXE found.")
                sys.exit(1)

            installer = exe_files[0]
            destination = downloads / installer.name

            shutil.copy2(installer, destination)
            print(f"Copied installer to: {destination}")

        elif target == "linux":
            if not is_linux():
                print("Linux builds are only supported on Linux.")
                sys.exit(1)
            run_command(["flutter", "build", "linux", "--release"])

        else:
            print("Unknown target. Use one of: ios, macos, windows, android, linux")
            sys.exit(1)


if __name__ == "__main__":
    main()