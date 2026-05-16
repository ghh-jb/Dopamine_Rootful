//
//  main.m
//  makerw_apfs
//
//  Created by untether
//

#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <copyfile.h>
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mount.h>
#include <sys/param.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/sysctl.h>
#include <dlfcn.h>
#include "dirutils.h"
#include <sys/param.h>
#include "apfs_utils.h"

/*
Idea:
1) Create new APFS partition
2) Mount it to /var/mnt/<name_of_volume>/
3) Copy staff recursively from provided path to /var/mnt/<name_of_volume>/
4) Unmount /var/mnt/<name_of_volume>/
5) Mount partition over provided path
Profit?
*/

void printf_error(char *format, ...) {
    printf("\x1b[1;31m");
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
    printf("\x1b[0m");
    return;
}

void printf_success(char* format, ...) {
    printf("\x1b[1;32m");
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
    printf("\x1b[0m");
    return;
}

char* walkPartitions(char* volumeNameIn) {
    char device[256] = "/dev/";
    bool foundPartition = false;

    char* partitions[17];

    if (@available(iOS 16.0, *)) {
        
        partitions[0] = "disk1s1";
        partitions[1] = "disk1s2";
        partitions[2] = "disk1s3";
        partitions[3] = "disk1s4";
        partitions[4] = "disk1s5";
        partitions[5] = "disk1s6";
        partitions[6] = "disk1s7";
        partitions[7] = "disk1s8";
        partitions[8] = "disk1s9";
        partitions[9] = "disk1s10";
        partitions[10] = "disk1s11";
        partitions[11] = "disk1s12";
        partitions[12] = "disk1s13";
        partitions[13] = "disk1s14";
        partitions[14] = "disk1s15";
        partitions[15] = "disk1s16";
        partitions[16] = "disk1s17";

    } else {
        partitions[0] = "disk0s1s1";
        partitions[1] = "disk0s1s2";
        partitions[2] = "disk0s1s3";
        partitions[3] = "disk0s1s4";
        partitions[4] = "disk0s1s5";
        partitions[5] = "disk0s1s6";
        partitions[6] = "disk0s1s7";
        partitions[7] = "disk0s1s8";
        partitions[8] = "disk0s1s9";
        partitions[9] = "disk0s1s10";
        partitions[10] = "disk0s1s11";
        partitions[11] = "disk0s1s12";
        partitions[12] = "disk0s1s13";
        partitions[13] = "disk0s1s14";
        partitions[14] = "disk0s1s15";
        partitions[15] = "disk0s1s16";
        partitions[16] = "disk0s1s17";
    }
    
    for (int part = 0; part < 17; part++) {
        char* volumeName = getName(partitions[part]);
        if (!volumeName) {
            debug("Reached the end of volumes, exiting\n");
            return "";
        }
        printf("%s -> %s\n", partitions[part], volumeName);

        if (strcmp(volumeNameIn, volumeName) == 0) {
            strcat(device, partitions[part]);
            debug("Found partition: %s\n", device);
            foundPartition = true;
            char* ptr = device;
            return ptr;
        }
    }
    debug("FAIL: something went wrong\n");
    return "";
}

bool check_partition(char* path) {
    char path_internal[512] = {0};
    strcpy(path_internal, path);
    strcat(path_internal, "/.Dopamine_Rootful/fsPrepared");
    debug("Checking partition at path: %s\n", &path_internal);
    if (access(path_internal, F_OK) == 0) {
        debug("Partition ok\n");
        return true;
    } else {
        debug("Partition corrupted\n");
        return false;
    }
    return true; // ???
}

int prepare_dopamine_partition(char* path, char* volumeNameIn) {
    // path - where to mount, volumeNameIn - name of device to mount
    int ret;
    char device[256];
    char* ptr = walkPartitions(volumeNameIn);
    strcpy(device, ptr);

    char tempMount[256] = "/var/mnt/";
    char prepared_flag[512] = {0};
    
    strcat(tempMount, volumeNameIn);
    ret = ensure_directory_exists(tempMount);


    debug("preparing partition: %s\n", tempMount);
    debug("going to mount %s device over %s tempdir\n", ptr, tempMount);


    ret = mount_apfs(tempMount, 0, device);
    debug("tempdir APFS ret: %i\n", ret);

    strcpy(prepared_flag, tempMount);
    strcat(prepared_flag, "/.Dopamine_Rootful");
    debug(".Dopamine_Rootful at: %s\n", prepared_flag);

    ret = ensure_directory_exists(prepared_flag);

    strcat(prepared_flag, "/fsPrepared");
    debug("fsPrepared at: %s\n", prepared_flag);

    int fd = open(prepared_flag, O_RDWR | O_CREAT);
    dprintf(fd, "Hello untether");
    close(fd);

    ret = copy_dir_recursive(path, tempMount); // copy all direcory from <path> to tempMount
    debug("copy dir recursive returned %i\n", ret);

    return 0;
}


int create_apfs_partition(char* path, char* volumeNameIn) {
    // put code in here
    uint64_t credBackup = 0;
    int ret = 0;
    int loopcount = 0;
    char device[256];
    char* ptr = NULL;
    start:

    if (loopcount > 6) {
        printf_error("[-] FAIL: Something went wrong, deadloop detected\n");
        printf_error("[-] EXITING\n");
        return 1;
    } 
    ptr = walkPartitions(volumeNameIn);
    strcpy(device, ptr);
    // char->ptr->char wtf

    if (strcmp(device, "") != 0) { // did find correct partition
        printf("Mounting %s over %s\n", device, path);

        debug("Going to mount partition %s -> %s path\n", device, path);
        debug("MOUNT!\n");
        ret = mount_apfs(path, MNT_FORCE, device);
        if (ret == KERN_SUCCESS) {
            printf("[+] mount_apfs returned %i\n", ret);
        } else {
            printf("[-] FAIL: mount_apfs returned %i\n", ret);
        }
        // need to check, if partition has dopamine flags.
        bool is_prepared = check_partition(path);

        if (!is_prepared) {
            printf("Partition invalid, killing it\n");

            debug("Giving kernel privileges\n");
            jbclient_root_steal_ucred(0, &credBackup);
            ret = unmount(path, MNT_FORCE);
            jbclient_root_steal_ucred(credBackup, NULL);
            debug("Dropping kernel privileges\n");
            printf("[+] unmount ret %i\n", ret);

            ret = _APFSVolumeDelete(device);
            printf("[+] volume %s deleted, recreating\n", device);
            goto start;
        }

    } else {
        char* rootDiskDevice = "disk0s1";
        debug("No partition found with name %s -> calling _APFSVolumeCreate\n", volumeNameIn);
        if (@available(iOS 16.0, *)) {
            rootDiskDevice = "disk1";
        }
        debug("rootDiskDevice: %s\n", rootDiskDevice);
        NSDictionary *createDict = @{@"com.apple.apfs.volume.name": [[NSString alloc] initWithUTF8String:volumeNameIn]};

		CFMutableDictionaryRef createDictMut = CFDictionaryCreateMutableCopy(NULL, 0, (__bridge CFDictionaryRef)createDict);

        _APFSVolumeCreate(rootDiskDevice, createDictMut);


        int partitionPrepared = prepare_dopamine_partition(path, volumeNameIn);
        // 0. At this point we have a new empty APFS device in /dev. The strategy is:
        // 1. Mount it over /var/mnt/<volumeNameIn>
        // 2. Copy all from real <path> to /var/mnt/<volumeNameIn>
        // 3. unmount /var/mnt/<volumeNameIn>
        // 4. mount over real <path>

        // Do it right now
        printf("Partition prepared for %s, unmounting tempdir\n", volumeNameIn);
        char tempMount[256] = "/var/mnt/";
        strcat(tempMount, volumeNameIn);

        debug("Giving kernel privileges\n");
        jbclient_root_steal_ucred(0, &credBackup);
        ret = unmount(tempMount, MNT_FORCE);
        printf("[+] unmount ret %i\n", ret);
        jbclient_root_steal_ucred(credBackup, NULL);
        debug("Dropping kernel privileges\n");
        printf("[+] Remounting to real directory.\n");
        goto start;
    }
    return 0;
}

int main(int argc, char *argv[]) {
    int ret = 0;
    if (getuid() != 0) {
        printf("FAIL: run as root");
        return -1;
    }

    int calls = initialize_calls();
    debug("Calls initialized ret %i\n", calls);
    
    if (argc < 2) {
        printf_success("Usage:\n");
        printf("  %s create <path> <volName>\n", argv[0]);
        return 1;
    }
    
    if (strcmp(argv[1], "create") == 0) {
        if (argc < 3) {
            printf_error("[-] Missing path argument.\n");
            return 1;
        }
        if (argc < 4) {
            printf_error("[-] Missing volume name.\n");
            return 1;
        }
        const char *path = argv[2];
        const char *volumeNameIn = argv[3];
        int ret = create_apfs_partition(path, volumeNameIn);
        if (ret == 0) {
            printf_success("[+] APFS partition is now on %s\n", path);
        }
        else {
            printf_error("[-] Failed to mount APFS partition over %s\n", path);
        }
    }
    else {
        printf_error("[-] Unknown command.\n");
    }

    return ret;
}