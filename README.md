<img src="https://github.com/opa334/Dopamine/assets/52459150/ed04dd3e-d879-456d-9aa3-d4ed44819c7e" width="64" />

# Dopamine

=== ATTENTION! === <br>
Before using this repository - go and star original Dopamine because without it this project wouldnt be possible.

This repo was forked from the commit: [2cfd690ac07d35eef62f42396a9989441a47b768](https://github.com/opa334/Dopamine/commit/2cfd690ac07d35eef62f42396a9989441a47b768) so it includes spinlock fix. No bootlogos at the moment though.

A rootful semi-untethered jailbreak for iOS 15.x (arm64e) and iOS 15.0 - 15.8.6 (arm64). More details will follow here soon.

Please note that all issues related to version support will be deleted without response.<br>
Please note that all issues related to rootful copy of the original jailbreak should NOT be submitted to original repository, unless they exist even in the unmodified Dopamine jailbreak.<br>
Please note, that this project is only for the developers and should not be used by an end-user who just wants the easy one-click jailbreak. <br>
Please note that I, as well as any of the original developers are not responsible for any damage or data loss caused by this tool. So... <br>**USE AT YOUR OWN RISK!**<br>
Please note, that bootstrapping this version might be harder than original jailbreak.<br>
Please note, that this project is experimantal and:<br>
1. Should NEVER be used for malicious purposes (e.g. bypassing iCloud Lock, MDM and other services)
2. Is dedicated mostly for security researchers who want to see, how does APFS and TMPFS work under the hood.

If I will see any malicious activity with the patterns of my code used in bootstrapfs, APFSRW, Makerw, Dopamine_Rootful and Fugu15_Rootful (one love) I will immediately report it on github or on the platform where I saw it. This project **DOES NOT** contain malware. The ownere of the device can do whatever he wants with it, however - the apple guarantee can be vanished after jailbreaking. But what I would say about it - devices on ios 15 are already out-of-guarantee in most cases due to their age, but I would not recommend installing this on main or production device unless you need to fully protect your device from coruna exploit chain.

Official website / download: https://ellekit.space/dopamine/

############# <br>
====BUILD==== <br>
############# <br>

- [!] THEOS MUST BE INSTALLED!!!

- [#] In terminal: "cd /path/to/Dopamine"
- [#] In terminal: "git submodule init"
- [#] In terminal: "git submodule update" and wait for process to finish
- [## ########]
- [#] MAKE SURE TO HAVE Xcode 14-15! This is VERY important!
- [## ########]
- [#] In terminal: "cd ./BaseBin"
- [#] In terminal: "make" and wait for process to finish
- [#] In terminal: "cd ../Application/Dopamine/Resouces"
- [#] In terminal: "./download_bootstraps.sh" and wait for process to finish
- [#] In terminal: "cd ../../../"
- [#] In terminal: "cd ./Packages"
- [#] In terminal: "make" and wait for process to finish
- [#] In Xcode 15: /connect your device/
- [#] In Xcode 15: /Build and run project on YOUR device/
- [#] On your iph: Enjoy jailbreak process

- {##} Tested with Xcode 15.0.1; MacBook CPU Intel Core i5; MacOS Sonoma 14.0
- {##} IF YOU NEED MULTIPLE XCODE INSTALLATIONS USE THIS: https://xcodes.org