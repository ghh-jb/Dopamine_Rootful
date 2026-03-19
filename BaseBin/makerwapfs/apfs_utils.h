enum {
    APFS_MOUNT_AS_ROOT = 0, /* mount the default snapshot */
    APFS_MOUNT_FILESYSTEM, /* mount live fs */
    APFS_MOUNT_SNAPSHOT, /* mount custom snapshot in apfs_mountarg.snapshot */
    APFS_MOUNT_FOR_CONVERSION, /* mount snapshot while suppling some representation of im4p and im4m */
    APFS_MOUNT_FOR_VERIFICATION, /* Fusion mount with tier 1 & 2, set by mount_apfs when -C is used (Conversion mount) */
    APFS_MOUNT_FOR_INVERSION, /* Fusion mount with tier 1 only, set by mount_apfs when -c is used */
    APFS_MOUNT_MODE_SIX,  /* ??????? */
    APFS_MOUNT_FOR_INVERT, /* ??? mount for invert */
    APFS_MOUNT_IMG4 /* mount live fs while suppling some representation of im4p and im4m */
};

struct apfs_mount_args {
    char* fspec; /* path to device to mount from */
    uint64_t apfs_flags; /* The standard mount flags, OR'd with apfs-specific flags (APFS_FLAGS_* above) */
    uint32_t mount_mode; /* APFS_MOUNT_* */
    uint32_t pad1; /* padding */
    uint32_t unk_flags; /* yet another type some sort of flags (bitfield), possibly volume role related */
    union {
        char snapshot[256]; /* snapshot name */
        struct {
            char tier1_dev[128]; /* Tier 1 device (Fusion mount) */
            char tier2_dev[128]; /* Tier 2 device (Fusion mount) */
        };
    };
    void* im4p_ptr;
    uint32_t im4p_size;
    uint32_t pad2; /* padding */
    void* im4m_ptr;
    uint32_t im4m_size;
    uint32_t pad3; /* padding */
    uint32_t cryptex_type; /* APFS_CRYPTEX_TYPE_* */
    int32_t auth_mode; /* APFS_AUTH_ENV_* */
    uid_t uid;
    gid_t gid;
}__attribute__((packed, aligned(4)));

typedef struct apfs_mount_args apfs_mount_args_t;

int initialize_calls(void);
char* getName(char* volume);
int mount_apfs(const char *dir, int flags, char *device);

