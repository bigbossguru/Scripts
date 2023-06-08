#!/bin/bash

########################################################
# Script which generates C++ Project Structure with additional libs.
# Author: Eldar
# Date: 08.06.2023
########################################################

set -e

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Script which generates C++ Project Structure with additional libs"
   echo
   echo "Syntax: ./CPP_startProject.sh [--boost|--help]"
   echo "options:"
   echo "   --boost [-b]        Download and Install Boost lib"
   echo "   --help [-h]         Display all possible functions"
   echo
}

if [[ "$1" = "-h" || "$1" = "--help" ]]; then
    Help
    exit 0
fi

echo "Start Generating C++ Project"
mkdir cpp_project
cd cpp_project/
mkdir src include lib
mkdir src/utils

echo "[Script] Generate README.md"
printf "# Folder name description
\`\`\`
src/ - This is where the c++ source files are kept. When you open a c++ project you would most likely want to go inside this directory and work with the code present here or add your own code here. This contains Private source files(.h and .cpp files). 
include/ - Inside this folder the header files which have the .h extension are kept. These header files are Public and any other application which depends on these header files outside of this application can also use them.
lib/ - This folder can contain third-party libraries(.lib files) or your own library on which the project depends.
doc/ - If you have this folder in your project then this basically consists of the documentation of the project or some library written by the developers and maintainers of the project.
build/ - This folder mainly consist of the build files such as object files and executable files. Build files can be the intermediate files or the final output files which are created when the application is being built.
test/ - When the application is huge and there are thousands of people using it, testing is as crucial as the development of the application. In this folder, the test files are kept. Test files are used to run unit tests on the application.
bin/ - This folder contains the executable code required for the project. These are in binary format. This folder can contain files with extension .exe(for application) and .dll(for library).
\`\`\`" > README.md

printf "\n\n# Manually Download and Install Boost library
\`\`\`\n- Download zip file with source code: https://www.boost.org/doc/libs/1_82_0/more/getting_started/windows.html
- Copy to the root project folder and unzipped
- Run pre-build boost: bootstrap.bat gcc
- Run build and compile dynamic lib: b2 toolset=gcc --prefix=<root_project_folder/boost_**_**>
- Run build and compile static lib: b2 link=static runtime-link=static --prefix=<root_project_folder/lib/boost> install\n\`\`\`" >> README.md

echo "[Script] Generate simple C++ program"
printf "#include <iostream>
#include \"utils/common.h\"

int main()
{
    std::cout << \"Hello World!\" << std::endl;
    double tax_result = common::tax_convert(0.1, common::PI + 101.1);
    std::cout << tax_result << std::endl;
    return 0;
}" > src/main.cpp

printf "#include \"common.h\"

double common::tax_convert(double tax_rate, double price)
{
    return price * tax_rate;
}" > src/utils/common.cpp

printf "#pragma once
#ifndef COMMON_H
#define COMMON_H

namespace common
{
    constexpr double PI{3.14};
    double tax_convert(double, double);
}

#endif" > src/utils/common.h

if [ "$1" = "--boost" ]; then
    echo "[Script] Download and Install Boost library"
    mkdir lib/boost
    echo "[Script] Generate CMakeList.txt file with Boost lib for building C++ project"
    printf "cmake_minimum_required(VERSION 3.20)    # CMake version check
project(CPP_PROJECT)                    # Create project name \"CPP_PROJECT\"

# Static compiled third boost library you should move to lib folder
# set(BOOST_ROOT lib/boost/)
# set(BOOST_INCLUDEDIR lib/boost/include/boost-1_82/)
# set(BOOST_LIBRARYDIR lib/boost/lib/)

# Dynamic using boost library
set(BOOST_ROOT \"lib/boost/boost_1_82_0\")

# Extra special env variables uncomment if you have warning or errors
# set(Boost_USE_STATIC_LIBS ON)
# set(Boost_USE_MULTITHREADED ON)
# set(Boost_USE_STATIC_RUNTIME ON)
# set(Boost_NO_WARN_NEW_VERSIONS 1)

# Add main.cpp file of project root directory as source file
set(SRC_FILES src/main.cpp src/utils/common.cpp)

# Uncomment if you have problem with winsock winapi
# if(MINGW)
#     link_libraries(ws2_32 wsock32)
# endif()

# Looking for Boost library on the your system
find_package(
    Boost \${BOOST_MIN_VERSION} REQUIRED
    COMPONENTS \${BOOST_REQUIRED_COMPONENTS}
)

# Add executable target with source files listed in SRC_FILES variable
add_executable(CPP_PROJECT \${SRC_FILES})

if(Boost_FOUND)
    target_include_directories(\${PROJECT_NAME} PUBLIC \${Boost_INCLUDE_DIR})
    target_link_libraries(\${PROJECT_NAME} \${Boost_LIBRARIES})
    message(STATUS \"Found BOOST \${Boost_VERSION_STRING}\")
else()
    message(STATUS \"BOOST Not Found\")
endif()
" > CMakeLists.txt
    echo "[Script] Downloading Boost library"
    curl -LO https://boostorg.jfrog.io/artifactory/main/release/1.82.0/source/boost_1_82_0.zip
    echo "[Script] Unzipping Boost library"
    unzip boost_1_82_0.zip -d lib/boost/
    cd lib/boost/boost_1_82_0/
    mkdir boost_build
    echo "[Script] Building and Installing Boost library"
    ./bootstrap.sh
    ./b2 --prefix=lib/boost/boost_1_82_0/boost_build
    cd ../../..
    rm -rf boost_1_82_0.zip
else
    echo "[Script] Generate CMakeList.txt file for building C++ project"
    printf "cmake_minimum_required(VERSION 3.20)    # CMake version check
project(CPP_PROJECT)                    # Create project name \"CPP_PROJECT\"

# Add main.cpp file of project root directory as source file
set(SRC_FILES src/main.cpp src/utils/common.cpp)

# Add executable target with source files listed in SRC_FILES variable
add_executable(CPP_PROJECT \${SRC_FILES})
" > CMakeLists.txt
fi

echo "[Script] Generate .gitignore file"
printf "# Prerequisites
*.d

# Compiled Object files
*.slo
*.lo
*.o
*.obj

# Precompiled Headers
*.gch
*.pch

# Compiled Dynamic libraries
*.so
*.dylib
*.dll

# Fortran module files
*.mod
*.smod

# Compiled Static libraries
*.lai
*.la
*.a
*.lib

# Executables
*.exe
*.out
*.app" > .gitignore

echo "Finished Successfully"