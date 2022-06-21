.phony: clean allclean

SRC := \
	$(wildcard *.cpp) \
	$(wildcard auth/*.cpp) \
	$(wildcard server/*.cpp) \
	$(wildcard api/*/*.cpp) \
	lib/tinyprocess/process.cpp \
	lib/easylogging/easylogging++.cc \
	lib/platformfolders/platform_folders.cpp \
	lib/clip/clip.cpp \
	lib/clip/image.cpp \
	lib/tinyprocess/process_unix.cpp \
	lib/clip/clip_osx.mm

VPATH:=${VPATH}:server:auth:lib/tinyprocess:lib/easylogging:lib/platformfolders:lib/clip:api/filesystem:api/os:api/computer:api/debug:api/storage:api/app:api/window:api/events:api/extensions:api/clipboard

INC := . lib lib/asio/include /opt/homebrew/Cellar/boost/1.78.0_1/include

DEF := \
	NL_VERSION=\"4.5.0\" \
	NL_COMMIT=\"deadbeefabadcafe\" \
	ELPP_NO_DEFAULT_LOG_FILE=1 \
	ASIO_STANDALONE \
	WEBVIEW_COCOA=1 \
	TRAY_APPKIT=1 \
	OBJC_OLD_DISPATCH_PROTOTYPES=1

# Try to get the arch right
ifeq (${ARCH},x64)
	AFLAG:=-arch x86_64
	ADIR:=x64
else ifeq (${ARCH},x86_64)
	AFLAG:=-arch x86_64
	ADIR:=x64
else ifeq (${ARCH},amd64)
	AFLAG:=-arch x86_64
	ADIR:=x64
else ifeq (${ARCH},arm64)
	AFLAG:=-arch arm64
	ADIR:=arm64
else ifeq (${ARCH},arm)
	AFLAG:=-arch arm64
	ADIR:=arm64
else ifeq ($(shell uname -p),arm)
	AFLAG:=-arch arm64
	ADIR:=arm64
else ifeq ($(shell uname -p),arm64)
	AFLAG:=-arch arm64
	ADIR:=arm64
else ifeq ($(shell uname -p),i386)
	AFLAG:=-arch x86_64
	ADIR:=x64
else ifeq ($(shell uname -p),x86_64)
	AFLAG:=-arch x86_64
	ADIR:=x64
endif

COMPFLAGS := -std=c++17 ${AFLAG} -Wno-deprecated-declarations -MMD -Os $(addprefix -D, ${DEF}) $(addprefix -I, ${INC})

LINKFLAGS := ${AFLAG} -framework WebKit -framework Cocoa

OBJDIR := bin/.tmp/${ADIR}

OBJS := $(addprefix ${OBJDIR}/, \
					$(patsubst %.cpp, %.cpp.o, \
						$(patsubst %.cc, %.cc.o, \
							$(patsubst %.mm, %.mm.o, \
								$(notdir ${SRC})))))

default: bin/neutralino-mac_${ADIR}

${OBJDIR}:
	-mkdir -p ${OBJDIR}

bin:
	-mkdir bin

clean:
	-rm -rf ${OBJS} bin/neutralino-mac_${ARCH}

allclean:
	-rm -rf ${OBJDIR} $(wildcard bin/neutralino-mac_*)

-include $(OBJS:.o=.d)

${OBJDIR}/%.cpp.o : %.cpp
	${CXX} ${COMPFLAGS} -c "$<" -o "$@"

${OBJDIR}/%.cc.o : %.cc
	${CXX} ${COMPFLAGS} -c "$<" -o "$@"

${OBJDIR}/%.mm.o : %.mm
	${CXX} -ObjC++ ${COMPFLAGS} -c "$<" -o "$@"

bin/neutralino-mac_${ADIR}: bin ${OBJDIR} ${OBJS}
	${CXX} ${LINKFLAGS} ${OBJS} -o "$@"