BUILD=./.build

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    TCLVERSION=8.6
    CCFLAGS += -D LINUX
    TCLLIBPATH=/usr/lib
    TCLINCPATH=/usr/include
    EXTRA_SWIFTLINK=
    TARGET=$(BUILD)
endif

ifeq ($(UNAME_S),Darwin)
    TCLVERSION=8.6.6_2
    BREWROOT=/usr/local/Cellar
    CCFLAGS += -D OSX
    TCLLIBPATH=$(BREWROOT)/tcl-tk/$(TCLVERSION)/lib
    TCLINCPATH=$(BREWROOT)/tcl-tk/$(TCLVERSION)/include
    EXTRA_SWIFTLINK=-Xlinker -L/usr/local/lib
    TARGET=SwiftTclDemo.xcodeproj
endif

default: $(TARGET)

build: $(BUILD)

$(BUILD): Package.swift Makefile
	swift build $(EXTRA_SWIFTLINK) -Xlinker -L$(TCLLIBPATH) -Xlinker -ltcl8.6 -Xlinker -ltclstub8.6 -Xlinker -lz -Xcc -I$(TCLINCPATH)

SwiftTclDemo.xcodeproj: Package.swift Makefile build
	@echo Generating Xcode project
	swift package -Xlinker -L/usr/local/lib -Xlinker -L$(TCLLIBPATH) -Xlinker -ltcl8.6 -Xlinker -ltclstub8.6 generate-xcodeproj
	@echo "NOTE: You will need to manually set the working directory for the SwiftTclDemo scheme to the root directory of this tree."
	@echo "Thanks Apple"

clean:
	rm -rf Package.pins .build SwiftTclDemo.xcodeproj

test: build
	.build/debug/SwiftTclDemo
