TARGET := iphone:clang:15.2:15.2

include $(THEOS)/makefiles/common.mk

TOOL_NAME = makerwapfs

makerwapfs_FILES = main.m apfs_utils.m dirutils.m
makerwapfs_CFLAGS = -fobjc-arc -Wno-unused-function -Wno-unused-variable -Wno-incompatible-pointer-types-discards-qualifiers -Wno-tautological-constant-out-of-range-compare -Wno-unused-but-set-variable -Wno-unused-label
makerwapfs_CODESIGN_FLAGS = -Sentitlements.plist
makerwapfs_FRAMEWORKS = IOKit
makerwapfs_INSTALL_PATH = /usr/local/bin

include $(THEOS_MAKE_PATH)/tool.mk
