#!/bin/bash

# Set your Android NDK path
export NDK_PATH=${ANDROID_NDK_HOME}

if [ !  -d "$NDK_PATH" ]; then
    echo "Error: Android NDK not found at $NDK_PATH"
    echo "Please set ANDROID_NDK_HOME or edit this script"
    exit 1
fi

# Set minimum Android API level
ANDROID_API=21

# Array of architectures to build
ABIS=("arm64-v8a" "armeabi-v7a" "x86")

# Array of build types
BUILD_TYPES=("Release" "Debug")

# Parse command line arguments
if [ "$1" == "--debug-only" ]; then
    BUILD_TYPES=("Debug")
elif [ "$1" == "--release-only" ]; then
    BUILD_TYPES=("Release")
fi

# Build for each architecture and build type
for BUILD_TYPE in "${BUILD_TYPES[@]}"
do
    for ABI in "${ABIS[@]}"
    do
        echo "=========================================="
        echo "Building $BUILD_TYPE for $ABI..."
        echo "=========================================="
        
        # Set build directory name based on type
        if [ "$BUILD_TYPE" == "Debug" ]; then
            BUILD_DIR="build-$ABI"
        else
            BUILD_DIR="buildrel-$ABI"
        fi
        
        mkdir -p $BUILD_DIR
        cd $BUILD_DIR
        
        cmake .. \
            -DCMAKE_TOOLCHAIN_FILE=$NDK_PATH/build/cmake/android.toolchain.cmake \
            -DANDROID_ABI=$ABI \
            -DANDROID_PLATFORM=android-$ANDROID_API \
            -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        
        if [ $? -ne 0 ]; then
            echo "CMake configuration failed for $ABI ($BUILD_TYPE)"
            cd ..
            exit 1
        fi
        
        make -j$(nproc)
        
        if [ $? -ne 0 ]; then
            echo "Build failed for $ABI ($BUILD_TYPE)"
            cd ..
            exit 1
        fi
        
        make install
        
        cd ..  
        
        echo "Finished building $BUILD_TYPE for $ABI"
        echo ""
    done
done

echo "=========================================="
echo "All builds completed successfully!"
echo "=========================================="
echo ""
echo "Build directories:"
for BUILD_TYPE in "${BUILD_TYPES[@]}"
do
    for ABI in "${ABIS[@]}"
    do
        if [ "$BUILD_TYPE" == "Debug" ]; then
            echo "  - build-$ABI/ -> install-android-$ABI-debug/"
        else
            echo "  - buildrel-$ABI/ -> install-android-$ABI-release/"
        fi
    done
done
