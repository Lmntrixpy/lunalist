#!/usr/bin/env python3

import platform
import subprocess
import sys
import os


def run_command(command: list[str]):
    try:
        print(f"Running: {' '.join(command)}")
        subprocess.run(command, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Build failed with exit code {e.returncode}")
        sys.exit(e.returncode)


def is_macos() -> bool:
    return platform.system() == "Darwin"


def is_windows() -> bool:
    return platform.system() == "Windows"


def is_linux() -> bool:
    return platform.system() == "Linux"


def main():
    if len(sys.argv) < 2:
        print("Usage: python build.py [ios|macos|windows|android|linux]")
        sys.exit(1)

    for i in range(1, len(sys.argv) - 1):
        target = sys.argv[i].lower()
        version_number = sys.argv[len(sys.argv) - 1]

        host_os = platform.system()
        print(f"Host OS: {host_os}")
        print(f"Target: {target}")

        if target == "android":
            run_command(["flutter", "build", "apk", "--release"])
            destination = os.path.expanduser(f"~/Downloads/lunalist-{version_number}.apk ")
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

        elif target == "windows":
            if not is_windows():
                print("Windows builds are only supported on Windows.")
                sys.exit(1)
            run_command(["flutter", "build", "windows", "--release"])

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