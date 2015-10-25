ARCHS = armv7 arm64
GO_EASY_ON_ME = 1
TARGET = iphone:clang:latest:latest
THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

TWEAK_NAME = Popcorn
Popcorn_FILES = Tweak.xm
Popcorn_FILES += CDTContextHostProvider.mm
Popcorn_FILES += POPCloseButton.mm
Popcorn_FILES += POPCloseBox.mm
Popcorn_FILES += POPContentView.mm
Popcorn_FRAMEWORKS = UIKit
Popcorn_FRAMEWORKS += CoreGraphics
Popcorn_FRAMEWORKS += QuartzCore
Popcorn_PRIVATE_FRAMEWORKS = BackboardServices
Popcorn_CFLAGS = -fobjc-arc
Popcorn_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
