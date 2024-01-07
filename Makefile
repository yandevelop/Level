TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Camera
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Level

Level_FILES = Tweak.x
Level_CFLAGS = -fobjc-arc
Level_FRAMEWORKS += UIKit CoreMotion AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk
