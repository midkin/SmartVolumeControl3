THEOS_DEVICE_IP=//your ip here

PACKAGE_VERSION=$(THEOS_PACKAGE_BASE_VERSION)

TARGET := ::latest:13.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SmartVolumeControl3

SmartVolumeControl3_FILES = SmartVolumeControl3.x SVCController.m SVCHelperController.m
# SmartVolumeControl3_CFLAGS = -fobjc-arc
# SmartVolumeControl3_CFLAGS = -fno-objc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += smartvolumecontrol3
include $(THEOS_MAKE_PATH)/aggregate.mk
