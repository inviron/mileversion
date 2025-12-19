PROJECT (mileversion)
cmake_minimum_required(VERSION 2.8)

# Require C++17 for the project
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_TOOLCHAIN_FILE "" CACHE FILEPATH "Path to CMake toolchain file (e.g., Android NDK toolchain)")

if(ANDROID)
    set(ANDROID_ABI "" CACHE STRING "Android ABI (arm64-v8a, armeabi-v7a, x86)")
    set_property(CACHE ANDROID_ABI PROPERTY STRINGS "arm64-v8a" "armeabi-v7a" "x86")
    
    set(ANDROID_PLATFORM "24" CACHE STRING "Android minimum API level")
endif()

SET (EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)

SET (LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
LINK_DIRECTORIES(${LIBRARY_OUTPUT_PATH})

set(CMAKE_DEBUG_POSTFIX "d")

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)
include_directories(${CMAKE_SOURCE_DIR}/include)

add_subdirectory(src)
add_subdirectory(sample)
