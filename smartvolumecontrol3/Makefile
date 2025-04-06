TARGET := ::latest:13.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SmartVolumeControl3

SmartVolumeControl3_FILES = SVCRootListController.m
# SmartVolumeControl3_FRAMEWORKS = UIKit
SmartVolumeControl3_PRIVATE_FRAMEWORKS = Preferences
SmartVolumeControl3_INSTALL_PATH = /Library/PreferenceBundles
# SmartVolumeControl3_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
