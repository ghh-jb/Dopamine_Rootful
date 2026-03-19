#import <Foundation/Foundation.h>
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
#include <sys/param.h>
#include <mach/arm/kern_return.h>

#define DEBUG_BUILD 1

void debug(char *format, ...) {
    if (!DEBUG_BUILD) return;
    va_list args;
    va_start(args, format);
    printf("[DEBUG] ");
    vprintf(format, args);
    va_end(args);
    return;
}

// Some functions useful for directories manipulation

char* toRealpath(const char *path) {
    char targetPath[PATH_MAX];
    char absPath[PATH_MAX];
    char *resolvedPath = NULL;
    
    ssize_t len = readlink(path, targetPath, sizeof(targetPath) - 1);
    if (len == -1) {
        printf("FAIL: readlink failed");
        return NULL;
    }
    targetPath[len] = '\0';
    
    if (targetPath[0] == '/') {
        return strdup(targetPath);
    }
    
    char symlinkDir[PATH_MAX];
    strncpy(symlinkDir, path, sizeof(symlinkDir));
    char *lastSlash = strrchr(symlinkDir, '/');
    if (lastSlash) {
        *lastSlash = '\0';
    } else {
        strcpy(symlinkDir, "."); 
    }
    
    if (snprintf(absPath, sizeof(absPath), "%s/%s", symlinkDir, targetPath) >= sizeof(absPath)) {
        printf("FAIL: Path too long\n");
        return NULL;
    }
    
    char *normal = realpath(absPath, NULL);
    if (!normal) {
        printf("FAIL: realpath failed");
        return NULL;
    }
    
    struct stat st;
    if (lstat(normal, &st) == 0 && S_ISLNK(st.st_mode)) {
        // Is this a symlink?
        char *finalPath = toRealpath(normal); // Recursive call until we hit the bottom
        free(normal);
        return finalPath;
    }
    
    return normal;
}

kern_return_t ensure_directory_exists(const char *path) {
    if (path == NULL) {
        return -1;
    }
    
    char tmp[PATH_MAX];
    if (snprintf(tmp, sizeof(tmp), "%s", path) >= sizeof(tmp)) {
        fprintf(stderr, "Path too long: %s\n", path);
        return -1;
    }
    
    for (char *p = tmp + 1; *p; p++) {
        if (*p == '/') {
            *p = '\0';
            mkdir(tmp, 0755);
            *p = '/';
        }
    }
    
    if (mkdir(tmp, 0755) != 0 && errno != EEXIST) {
        fprintf(stderr, "Failed to mkdir %s: %s\n", tmp, strerror(errno));
        return -1;
    }
    
    return 0;
}

kern_return_t copy_dir_recursive(const char *src, const char *dst) {
    // TODO:
    // Handle relative symlinks correctly
    
    if (src == NULL || dst == NULL) {
        return -1;
    }
    
    DIR *dir = opendir(src);
    if (dir == NULL) {
        fprintf(stderr, "Failed to opendir('%s'): %s\n", src, strerror(errno));
        return -1;
    }
    
    kern_return_t ret = ensure_directory_exists(dst);
    if (ret != 0) {
        closedir(dir);
        return ret;
    }
    
    struct dirent *ent;
    while ((ent = readdir(dir)) != NULL) {
        if (strcmp(ent->d_name, ".") == 0 || strcmp(ent->d_name, "..") == 0) {
            continue;
        }
        
        if (strcmp(ent->d_name, ".fseventsd") == 0) {
            continue;
        }
        
        char src_path[PATH_MAX];
        if (snprintf(src_path, sizeof(src_path), "%s/%s", src, ent->d_name) >= sizeof(src_path)) {
            fprintf(stderr, "Path too long: %s/%s\n", src, ent->d_name);
            closedir(dir);
            return -1;
        }
        
        char dst_path[PATH_MAX];
        if (snprintf(dst_path, sizeof(dst_path), "%s/%s", dst, ent->d_name) >= sizeof(dst_path)) {
            fprintf(stderr, "Path too long: %s/%s\n", dst, ent->d_name);
            closedir(dir);
            return -1;
        }
        
        struct stat st;
        if (lstat(src_path, &st) != 0) {
            fprintf(stderr, "Failed to lstat('%s'): %s\n", src_path, strerror(errno));
            closedir(dir);
            return -1;
        }
        
        if (S_ISDIR(st.st_mode) && !S_ISLNK(st.st_mode)) {
            ret = copy_dir_recursive(src_path, dst_path);
            if (ret != 0) {
                closedir(dir);
                return ret;
            }
        }
        if (S_ISLNK(st.st_mode)) {
            // Handle absolute symbolic links
            // To handle relative - convert to absolute, then fallback

            char* real_path = toRealpath(src_path);
            debug("[+] realpath: %s\n", real_path);
            
            unlink(dst_path);

            if (symlink(real_path, dst_path) != 0) {
                fprintf(stderr,"Failed to create symlink\n");
            }
        }
        else {
            copyfile_state_t cst = copyfile_state_alloc();
            if (cst == NULL) {
                fprintf(stderr, "Failed to allocate copyfile state\n");
                closedir(dir);
                return -1;
            }
            
            if (copyfile(src_path, dst_path, cst, COPYFILE_ALL) != 0) {
                fprintf(stderr, "Failed copy '%s' -> '%s': %s, continuing\n", src_path, dst_path, strerror(errno));
                copyfile_state_free(cst);
                closedir(dir);
                return -1; // Is this needed? Maybe continue copying?
            }
            copyfile_state_free(cst);
        }
    }
    
    closedir(dir);
    return 0;
}

char* jbrootpath() {
    NSString* preboot = @"/private/preboot/";
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:preboot error:NULL];
    for (NSString *sub in dirs) {
        if ([sub length] > 20) {
            NSString* bootUUID = [preboot stringByAppendingString:sub];
            bootUUID = [bootUUID stringByAppendingString:@"/"];

            NSArray* bootUUIDManager = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bootUUID error:NULL];

            for (NSString *inBoot in bootUUIDManager) {
                if ([inBoot hasPrefix:@"dopamine-"]) {

                    NSString* dopamine = [bootUUID stringByAppendingString:inBoot];
                    NSString* jbroot = [dopamine stringByAppendingString:@"/procursus"];
                    return [jbroot UTF8String];
                }
            }
            break;
        }
    }
    return "";
}

char* getItemInJBROOT(char* item) {
    char* jbroot = jbrootpath();
    strcat(jbroot, item);
    return jbroot;
}