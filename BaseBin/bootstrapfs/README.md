# bootstrapfs
APFS volume creator/bootstrapper/mounter

**DO NOT DELETE .DOPAMINE_ROOTFUL DIRECTORY, IT IS A FLAG THAT PARTITION IS NOT CORRUPTED**

# Tested Devices and iOS Versions
Special thanks to @Sergey5588 for testing this thing for me.
- iPhone 11: iOS 16.3.1 (20D67)
- iPhone SE 2020: iOS 15.2 (19C56)
- iPhone SE 2016: iOS 15.8.4 (19H390)

# Usage
`makerwapfs create {path} {volName}`

**path**: A directory, where you want to mount APFS partition with r/w. <br>
**volName**: Any string to identify the volume. This is needed to stay far away from entering path to disk device manually.

# Safety tips
(Accidents hurt, safety doesn't) 

1. **UIcache**
Especially important if you mount a partition over /Applications

Do never install applications with same bundle identifiers in different places of the system. For example, if you have Filza installed via trollstore and then you copy Filza to /Applications, after running uicache -a you may (or may not?) corrupt your icon cache, after that SpringBoard will stop loading, crashing on startup and you will get a bootloop. 

2. **More to be added??**

# Building 
Prerequisites:
- Make sure you have theos installed
- Make sure you have specified your sdks in Makefile
Now you can simply run `make package` or `make package THEOS_PACKAGE_SCHEME=rootless` depending on your jailbreak environment.
After that install it via sileo/cydia/zebra/ssh.

# License
GNU GENERAL PUBLIC LICENSE Version 3. See the `LICENSE` file.