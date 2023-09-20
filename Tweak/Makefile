TWEAK_NAME = Ephemeral
Ephemeral_FILES = EphemeralCore.mm EphemeralObservers.m $(wildcard ViewController/*.m ViewController/ContentViewController/*.m)
Ephemeral_CFLAGS = -fobjc-arc -DTHEOS_LEAN_AND_MEAN
Ephemeral_FRAMEWORKS = UIKit
Ephemeral_PRIVATE_FRAMEWORKS = BackBoardServices GraphicsServices

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
