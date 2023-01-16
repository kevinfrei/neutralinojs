cmake_minimum_required(VERSION 3.22.0)
cmake_policy(SET CMP0074 NEW)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(NL_VERSION 4.7.0)

# Get the current git commit hash
# This isn't perfect, but it's better than nothing and simple
execute_process(
  COMMAND
  git log -1 --format=%h
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  OUTPUT_VARIABLE NL_COMMIT
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

project(
  neutralinojs
  VERSION ${NL_VERSION}
  DESCRIPTION "NeutralinoJS"
  LANGUAGES CXX
)

# This isn't a great way to collect source files, but it's straight out of
# the buildzri thing (who decides to make a new C++ build system in 2022?)
# so let's just do it for now, I guess
file(GLOB
  SRC_MOST
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
file(GLOB_RECURSE
  SRC_RECURSE
  "api/*.cpp"
  "lib/infoware/src/*.cpp"
)
set(SRC
  ${SRC_MOST}
  ${SRC_SPECIFIC}
  ${SRC_RECURSE}
)

if(WIN32)
  set(OS_INCLUDE "lib/webview/windows")
  set(OS_SRC
    "lib/tinyprocess/process_win.cpp"
    "lib/clip/clip_win.cpp"
  )
  set(OS_DEFINES
    "_WEBSOCKET_CPP11_STL_"
    "_WEBSOCKETPP_CPP11_TYPE_TRAITS_"
    "_HAS_STD_BYTE=0"
    "TRAY_WINAPI=1"
  )
  # I don't know if this level of complexity is actually necessary
  set(OS_LIBS "${CMAKE_CURRENT_LIST_DIR}\\lib\\webview\\windows\\WebView2Loader.dll.lib" gdi32 version ole32 oleaut32 wbemuuid ntdll)
  add_executable(neutralinojs WIN32 ${SRC} ${OS_SRC})
elseif(APPLE)
  set(OS_SRC
    "lib/tinyprocess/process_unix.cpp"
    "lib/clip/clip_osx.mm"
  )
  set(OS_DEFINES
    "WEBVIEW_COCOA=1"
    "TRAY_APPKIT=1"
  )
  set(OS_LIBS
    "-framework WebKit"
    "-framework Cocoa"
  )
  add_executable(neutralinojs MACOSX_BUNDLE ${SRC} ${OS_SRC})
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
  find_package(PkgConfig REQUIRED)
  pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)
  pkg_check_modules(WEBKIT REQUIRED IMPORTED_TARGET webkit2gtk-4.0)
  add_executable(neutralinojs ${SRC} ${OS_SRC})
  set(
    OS_LIBS
    PkgConfig::GTK
    PkgConfig::WEBKIT
    xcb
    X11
    Xrandr
  )
endif()


target_link_libraries(neutralinojs PRIVATE ${OS_LIBS})
target_compile_definitions(
  neutralinojs
  PRIVATE
  "NL_VERSION=\"${NL_VERSION}\""
  "NL_COMMIT=\"${NL_COMMIT}\""
  "ELELPP_NO_DEFAULT_LOG_FILE=1"
  "ASIO_STANDALONE"
  "INFOWARE_VERSION=\"0.6.0\""
  "INFOWARE_USE_X11"
  ${OS_DEFINES}
)
target_include_directories(
  neutralinojs
  PRIVATE
  "."
  "lib"
  "lib/asio/include"
  "lib/infoware/include"
  ${OS_INCLUDE}
)
