ARCHS = armv7 arm64
TARGET = iphone:clang::
include theos/makefiles/common.mk

BUNDLE_NAME = BacklightSwitch
BacklightSwitch_FILES = Switch.x
BacklightSwitch_FRAMEWORKS = UIKit
BacklightSwitch_LIBRARIES = flipswitch
BacklightSwitch_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
