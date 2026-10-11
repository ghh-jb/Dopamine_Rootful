<img src="https://github.com/opa334/Dopamine/assets/52459150/ed04dd3e-d879-456d-9aa3-d4ed44819c7e" width="64" />

# Dopamine - Rootful Edition
Official website / download original Dopamine: https://ellekit.space/dopamine/

A rootful semi-untethered jailbreak for iOS 15.x (arm64 and arm64e). More details will follow here soon.<br>
This version includes full support for tweaks and is rootful.<br>

**Please note that all issues related to version support will be deleted without response.**<br>

# WARNING - ONLY FOR DEVELOPERS
Feel free to fix it if you want to, but note that offsets for userspace PAC.<br>
This thing might break your device, was not tested on iOS 16+<br>
On iOS 16 it will NOT work out-of-box due to missing LaunchConstraints bypass and I dont have a device to develop one. <br>

# Tested Devices and iOS Versions
- iPhone SE 2020: iOS 15.2
- iPhone SE 2016: iOS 15.8.3

# Building
1. Make sure you have Xcode installed
2. Clone this repo
3. `git submodule init`
4. `git submodule update`
5. `cd BaseBin/XPF` and run steps 3 and 4
6. Go back to BaseBin directory
7. Run `make` (note1)
8. Go to the root of the project
9. `cd Packages`
10. `make`
11. Go to the root of the project
12. Go to `Application/Dopamine/Resources`
13. Run `./download_bootstraps.sh`
14. Go to the root of the project
15. Run `make`

Note1: If bootstrapfs doesnt build - correct the sdk/ios version in Makefile

# Installing
Simply install the ipa/tipa file via Xcode or Trollstore

# Bootstrapping
It is not that trivial to bootstrap this jailbreak. To bootstrap it:
- Download Filza for Trollstore
- Download https://static.palera.in/bootstrap-1800.tar.zst rootful palera1n bootstrap for ios 15
- Extract .tar from zstd archive
- Jailbreak
- Save the bootstrap-1800.tar to some known place in Filza (/private/preboot/bootstrap-1800.tar)
- Open built-in Filza terminal and run following commands
- `cd /`
- `tar -xvf /private/preboot/bootstrap-1800.tar`
- `kill 1`
After this you will have basic jailbreak bootstrap with binaries needed for following steps.

# Fixing up dependencies
In order to install Sileo and your preferred tweak injector (libhooker and ElleKit were tested) you need to install stub packages. Those are basically:
1. cy+cpu.arm64
2. cy+cpu.arm64e
3. gsc.camera-flash
4. cy+model.iphone
5. firmware
6. libkrw0-plugin

Note: libkrw will not work in this case, build it from source if you need its features<br>
To begin using dpkg/apt normally create deb packages with these names in "Package: " field. Here is example:

`
Package: firmware
Name: system_fixes
Description: Compat package for Dopamine_Rootful jailbreak
Maintainer: ghh-jb
Author: ghh-jb
Section: System
Architecture: iphoneos-arm
Version: 15.2
`

Read about how to construct debian package `control` file at https://www.debian.org/doc/debian-policy/ch-controlfields.html<br>
I recommend extractng some other package and modifying its control file.

# Installing Sileo
To install Sileo - visit [iOS Repo Updates](https://www.ios-repo-updates.com/) and download rootful (iphoneos-arm) .deb file from there, share with filza and install the same way you did with the fixup packages<br>
After that you will be able to use it as normal, add sources and install packages.<br>

When done correctly, you should now have a rootful jailbreak which supports all Tweaks!

# Checking if everything works
Install [Amber](https://github.com/PoomSmart/Amber) tweak. It is an excellent thing to test your setup on as it injects to the SpringBoard AND into mediaserverd. If it works - the majority of tweaks will work too.

# Credits
- [Dopamine with subprojects](https://github.com/opa334/Dopamine) - without original repository this would not be possible
- [bootstrapfs](https://github.com/ghh-jb/bootstrapfs) - my tool, used for creating APFS devices and mounting volumes over read-only directories in /

# License
Dopamine: MIT. See the `LICENSE.md` file.
bootsrtapfs: GNU GENERAL PUBLIC LICENSE Version 3. See the `BaseBin/bootstrapfs/LICENSE` file.