TARGET := iphone:clang:15.2:13.0

include $(THEOS)/makefiles/common.mk

TOOL_NAME = bootstrapfs

bootstrapfs_FILES = main.m apfs_utils.m dirutils.m
bootstrapfs_CFLAGS = -fobjc-arc -Wno-unused-function -Wno-unused-variable -Wno-incompatible-pointer-types-discards-qualifiers -Wno-tautological-constant-out-of-range-compare -Wno-unused-but-set-variable -Wno-unused-label
bootstrapfs_CODESIGN_FLAGS = -Sentitlements.plist
bootstrapfs_FRAMEWORKS = IOKit
bootstrapfs_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
