from conan import ConanFile
# I prefer the VS Layout over the default layout
from conan.tools.microsoft import vs_layout

import os
from typing import NamedTuple, Optional, List


class CMakeInfo(NamedTuple):
    # Name of the package to find with find_package
    package: str
    # CMake target to use with target_link_libraries, if needed
    target: str
    # CMake variable to use in CMakeLists, defaults to ucase "${package}_LIB"
    var: Optional[str] = None


class Library(NamedTuple):
    # Name of library from conan-center
    name: str
    # Version of package from conan-center
    version: str
    # CMake package info
    info: Optional[List[CMakeInfo]] = None


libraries = [
    Library("boost", "1.83.0", [CMakeInfo("Boost", "boost::boost")]),
    Library("nlohmann_json", "3.11.3", [CMakeInfo("nlohmann_json", "nlohmann_json::nlohmann_json", "JSON_LIB")]),
    Library("platformfolders", "4.2.0", [CMakeInfo("platform_folders", "sago::platform_folders")]),
    Library("dacap-clip", "1.9", [CMakeInfo("clip", "clip::clip")]),
    Library("easyloggingpp", "9.97.1", [CMakeInfo("easyloggingpp", "easyloggingpp::easyloggingpp")]),
    Library("efsw", "1.4.1", [CMakeInfo("efsw", "efsw::efsw")]),
    Library("portable-file-dialogs", "0.1.0", [CMakeInfo("portable-file-dialogs", "portable-file-dialogs::portable-file-dialogs", "PFD_LIB")]),
    Library("websocketpp", "0.8.2", [CMakeInfo("websocketpp", "websocketpp::websocketpp")]),
]


class KnottyYogaRecipe(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    def init(self):
        # emit the find_package calls in the conanbuildinfo.cmake,
        # along with the variables for later use in the CMakeLists
        with open(os.path.join(self.recipe_folder, "ConanLibImports.cmake"), "w") as f:
            f.write('# Generated file: DO NOT EDIT or COMMIT!\n')
            f.write('# Add your library to the conanfile.py libraries list\n\n')
            for library in libraries:
                if library.info:
                  for info in library.info:
                    f.write(f'find_package({info.package} REQUIRED)\n')
                    var_name = info.var if info.var else f'{info.package.upper()}_LIB'
                    f.write(f'set({var_name} {info.target})\n\n')
                
    def requirements(self):
        for requirement in libraries:
            self.requires(requirement.name+"/"+requirement.version)

    def layout(self):
        vs_layout(self)
