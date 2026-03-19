#include <stdio.h>
#include <Foundation/Foundation.h>
#include <dlfcn.h>
#include <dirent.h>
#include <unistd.h>
#include <stdlib.h>
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/IOReturn.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include "dirutils.h"
#include "apfs_utils.h"

int (*jbclient_root_steal_ucred)(uint64_t ucredToSteal, uint64_t *orgUcred);
int64_t (*_APFSVolumeCreate)(char* device, CFMutableDictionaryRef args);
uint64_t (*_APFSVolumeDelete)(char* arg1);
uint64_t credBackup_local = 0;



// main apfs mount function
int mount_apfs(const char *dir, int flags, char *device) {
	apfs_mount_args_t args = 
	{
		device, // /dev/disk0s1s8
		flags, // MNT_FORCE MNT_RDONLY MNT_UPDATE etc
		APFS_MOUNT_FILESYSTEM, // default
		0,
		0,
		{ "" },
		NULL,
		0,
		0,
		NULL,
		0,
		0,
		0,
		0,
		0,
		0
	};

	// set kernel credentials
	debug("Giving kernel privileges\n");
	jbclient_root_steal_ucred(0, &credBackup_local);
	int ret = mount("apfs", dir, flags, &args);
	jbclient_root_steal_ucred(credBackup_local, NULL);
	debug("Dropping kernel privileges\n");
	// drop kernel credentials

	debug("mount apfs returned: %i\n", ret);
	return ret;
}

// Utility function to create apfs devices
int initialize_calls(void) {
	void* APFSHandler = dlopen("/System/Library/PrivateFrameworks/APFS.framework/APFS", RTLD_NOW);
	if (!APFSHandler) {
		printf("[-] FAIL: unable to dlopen APFS, cannot continue\n");
		dlclose(APFSHandler);
		exit(-1);
	}
	_APFSVolumeCreate = dlsym(APFSHandler, "APFSVolumeCreate");
	_APFSVolumeDelete = dlsym(APFSHandler, "APFSVolumeDelete");
	dlclose(APFSHandler);

	debug("APFS calls initialized:\nAPFSVolumeCreate: %p\nAPFSVolumeDelete: %p\n", _APFSVolumeCreate, _APFSVolumeDelete);
	
	void* LJBHandler = dlopen(getItemInJBROOT("/basebin/libjailbreak.dylib"), RTLD_NOW);
	if (!LJBHandler) {
		printf("[-] FAIL: unable to dlopen libjailbreak, cannot continue");
		dlclose(LJBHandler);
		exit(-1);
	}
	jbclient_root_steal_ucred = dlsym(LJBHandler, "jbclient_root_steal_ucred");
	dlclose(LJBHandler);
	debug("libjailbreak calls initialized:\njbclient_root_steal_ucred: %p\n", jbclient_root_steal_ucred);
	
	return 0;
}


// Utility function to get name of device
// Pass only disk0s1s8 (without /dev)
// For example: disk0s1s7 -> Preboot; /dev/disk0s1s1 -> System
char* getName(char* volume) {
	if (!volume) {
		debug("FAULT in volume name\n");
		return "";
	}
	CFMutableDictionaryRef matching = IOServiceMatching("AppleAPFSVolume");
	io_iterator_t iter = 0;
	uint64_t kr = IOServiceGetMatchingServices(0, matching, &iter);

	debug("kr: %lli\n", kr);

	if (kr != KERN_SUCCESS) {
		debug("FAULT in getName in IOServiceGetMatchingServices\n");
		return "";
	}

	io_object_t service = IOIteratorNext(iter);
	NSString* result = nil;

	while (service != 0) {
		CFStringRef dev = IORegistryEntrySearchCFProperty(service, kIOServicePlane, CFSTR("BSD Name"), nil, 0);
		if (dev) {
			NSString *devStr = (__bridge NSString *)dev;

			if ([devStr isEqualToString:[[NSString alloc] initWithUTF8String:volume]]) {
				CFStringRef name = IORegistryEntrySearchCFProperty(service, kIOServicePlane, CFSTR("FullName"), nil, 0);
				if (name) {
					result = [(__bridge NSString *)name copy];
					CFRelease(name);
				}
			}
		}
		IOObjectRelease(service);
		service = IOIteratorNext(iter);
	}
	IOObjectRelease(iter);
	return [result UTF8String];

}