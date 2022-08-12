cmake_minimum_required(VERSION 3.23.0)
cmake_policy(SET CMP0074 NEW)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(NL_VERSION 4.7.0)

# TODO: Make this figure things out automatically, eventually
set(NL_COMMIT "DEADBEEF01")

project(neutralinojs
  VERSION ${NL_VERSION}
  DESCRIPTION "NeutralinoJS"
  LANGUAGES CXX
)

if(WIN32)
  set(OS_INCLUDE "lib/webview/windows")
  set(OS_SRC
    "lib/tinyprocess/process_win.cpp"
    "lib/clip/clip_win.cpp"
  )
  set(OS_DEFINES
    "_WEBSOCKET_CPP11_STL_"
    "_HAS_STD_BYTE=0"
    "TRAY_WINAPI=1"
  )
  add_library(winwebview SHARED IMPORTED)
  set_target_properties(winwebview PROPERTIES IMPORTED_LOCATION
    "lib/webview/windows/WebView2Loader.dll.lib")

  # gdi32.lib version.lib Ole32.lib OleAut32.lib wbemuuid.lib ntdll.lib
  set(OS_LIBS winwebview)
elseif(APPLE)
  set(OS_SRC
    "lib/tinyprocess/process_unix.cpp"
    "lib/clip/clip_osx.mm"
  )
  set(OS_DEFINES
    "WEBVIEW_COCOA=1"
    "TRAY_APPKIT=1"
    "OBJC_OLD_DISPATCH_PROTOTYPES=1"
  )
  set(OS_LIBS
    "-framework WebKit"
    "-framework Cocoa"
  )
elseif(UNIX)
  set(OS_SRC
    "lib/tinyprocess/process_unix.cpp"
    "lib/clip/clip_x11.cpp"
  )
  set(OS_DEFINES
    "HAVE_XCB_XLIB_H"
    "WEBVIEW_GTK=1"
    "TRAY_APPINDICATOR=1"
  )

  # There's some stuff here: https://gist.github.com/fracek/3323924
  # find_package(PkgConfig REQUIRED)
  # pkg_check_modules(GTK REQUIRED gtk+-3.0)
endif()

# This isn't a great way to collect source files
# But they awful build system someone who's never used a good build system designed
# does this, so let's just do it for now...
file(GLOB SRC_MOST
  "*.cpp"
  "auth/*.cpp"
  "server/*.cpp"
)
set(SRC_SPECIFIC
  "lib/tinyprocess/process.cpp"
  "lib/easylogging/easylogging++.cc"
  "lib/platformfolders/platform_folders.cpp"
  "lib/clip/clip.cpp"
  "lib/clip/image.cpp"
)
file(GLOB_RECURSE SRC_RECURSE
  "api/*.cpp"
  "lib/infoware/src/*.cpp"
)
set(SRC
  ${SRC_MOST}
  ${SRC_SPECIFIC}
  ${SRC_RECURSE}
)

add_executable(neutralinojs ${SRC} ${OS_SRC})
target_link_libraries(neutralinojs PRIVATE ${OS_LIBS})
target_compile_definitions(neutralinojs
  PRIVATE
  "NL_VERSION=\"${NL_VERSION}\""
  "NL_COMMIT=\"${NL_COMMIT}\""
  "ELELPP_NO_DEFAULT_LOG_FILE=1"
  "ASIO_STANDALONE"
  "INFOWARE_VERSION=\"0.6.0\""
  "INFOWARE_USE_X11"
  ${OS_DEFINES}
)
target_include_directories(neutralinojs
  PRIVATE
  "."
  "lib"
  "lib/asio/include"
  "lib/infoware/include"
  ${OS_INCLUDE}
)
