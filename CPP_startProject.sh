#! /bin/bash

#cd ~/Desktop/
mkdir cpp_project
cd cpp_project/
mkdir src include lib
mkdir src/utils
touch CMakeLists.txt

printf "src/ – This is where the c++ source files are kept. When you open a c++ project you would most likely want to go inside this directory and work with the code present here or add your own code here. This contains Private source files(.h and .cpp files). 
include/ – Inside this folder the header files which have the .h extension are kept. These header files are Public and any other application which depends on these header files outside of this application can also use them.
lib/ – This folder can contain third-party libraries(.lib files) or your own library on which the project depends.
doc/ – If you have this folder in your project then this basically consists of the documentation of the project or some library written by the developers and maintainers of the project.
build/ – This folder mainly consist of the build files such as object files and executable files. Build files can be the intermediate files or the final output files which are created when the application is being built.
test/ – When the application is huge and there are thousands of people using it, testing is as crucial as the development of the application. In this folder, the test files are kept. Test files are used to run unit tests on the application.
bin/ – This folder contains the executable code required for the project. These are in binary format. This folder can contain files with extension .exe(for application) and .dll(for library)." > info.md

printf "cmake_minimum_required(VERSION 3.13)    # CMake version check
project(cpp_project)                    # Create project \"cpp_project\"
set(CMAKE_CXX_STANDARD 14)              # Enable c++14 standard

# Add main.cpp file of project root directory as source file
set(SOURCE_FILES src/main.cpp src/utils/common.cpp)

# Add executable target with source files listed in SOURCE_FILES variable
add_executable(cpp_project \${SOURCE_FILES})
target_include_directories(cpp_project PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)" > CMakeLists.txt

printf "#include <iostream>
#include \"utils/common.h\"

int main()
{
    std::cout << \"Hello World!\" << std::endl;
    double tax_result = common::tax_convert(0.1, common::PI + 101.1);
    std::cout << tax_result << std::endl;
    std::system(\"pause\");
    return 0;
}" > src/main.cpp

printf "#include \"common.h\"

double common::tax_convert(double tax_rate, double price)
{
    return price * tax_rate;
}" > src/utils/common.cpp

printf "#pragma once

namespace common
{
	constexpr double PI{3.14};
    double tax_convert(double, double);
}" > src/utils/common.h

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
