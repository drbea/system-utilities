import subprocess
import os
import sys
import platform

"""
This Python script allows you to shut down the computer, regardless of the operating system.
It asks for user confirmation before proceeding with the shutdown.

Author: PEVE BEAVOGUI
File: shutdown_script.py
"""

def shutdown():
    """
    Asks the user if they are sure they want to shut down the computer.
    Depending on the detected operating system, the appropriate shutdown command
    is executed.

    On Windows, it uses 'shutdown /s /t 5' with a 5-second timeout.
    On Linux (including Ubuntu, Linux Mint, Kali Linux), it uses 'sudo shutdown now'.
    On macOS, it uses 'sudo shutdown -h now'.
    If the operating system is not recognized, a warning message is displayed.

    Executing the shutdown command on Linux and macOS usually requires
    administrator privileges (sudo) and may prompt for a password.

    If the user answers 'n' (no), the operation is canceled.
    If the user enters any other value, an error message is displayed.

    In case of an error during the execution of the shutdown command, an
    error message is displayed.
    """
    while True:
        entry = input("\tAre you sure you want to shut down your computer?\n\tType 'y' for Yes or 'n' for No: ")
        if entry.lower() == "y":
            print("Shutting down...")
            system = platform.system()
            try:
                if system == "Windows":
                    # Added a 5-second timeout to allow the user to cancel if needed.
                    subprocess.run(["shutdown", "/s", "/t", "5"], check=True)
                    print("See you soon!")
                    break
                elif system == "Linux":
                    subprocess.run(["sudo", "shutdown", "now"], check=True)
                    print("See you soon!")
                    break
                elif system == "Darwin":  # macOS
                    subprocess.run(["sudo", "shutdown", "-h", "now"], check=True)
                    print("See you soon!")
                    break
                else:
                    print(f"Operating system not recognized: {system}")
                    print("Unable to execute the shutdown command automatically.")
                    break
            except subprocess.CalledProcessError as e:
                print(f"Error during shutdown: {e}")
                if system == "Linux" or system == "Darwin":
                    print("Make sure you have administrator rights (sudo) to execute this command.")
                elif system == "Windows":
                    print("Verify that the 'shutdown' command is available and that you have the necessary permissions.")
                break
        elif entry.lower() == "n":
            print("Operation canceled.")
            break
        else:
            print("Invalid input. Please type 'y' or 'n'.")

if __name__ == "__main__":
    try:
        shutdown()
    except KeyboardInterrupt:
        print("\nShutdown operation interrupted by user.")
