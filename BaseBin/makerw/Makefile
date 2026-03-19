TARGET := iphone:clang:14.5:15.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TOOL_NAME = makerw

makerw_FILES = main.m
makerw_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-incompatible-pointer-types-discards-qualifiers
makerw_CODESIGN_FLAGS = -S./entitlements.xml


include $(THEOS_MAKE_PATH)/tool.mk
