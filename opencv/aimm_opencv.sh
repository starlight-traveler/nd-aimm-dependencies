#!/bin/bash

# Script to install the latest version of OpenCV from source on Linux
# Tested on Debian-based distributions

set -e

# Uninstall existing OpenCV packages
sudo apt-get purge -y 'libopencv*'
sudo apt-get autoremove -y

# Update and install build dependencies
sudo apt-get update
sudo apt-get install -y build-essential cmake git pkg-config libgtk-3-dev \
libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
gfortran openexr libatlas-base-dev libtbbmalloc2 libtbb-dev \
python3-dev python3-numpy python3-pip

# Create a directory for the OpenCV source code
rm -rf ~/opencv_build
mkdir -p ~/opencv_build && cd ~/opencv_build

# Clone the latest OpenCV and OpenCV_contrib repositories
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git

# Navigate to the OpenCV directory and create a build directory
cd ~/opencv_build/opencv
mkdir -p build && cd build

# Retrieve Python 3 paths
PYTHON3_EXECUTABLE=$(which python3)
PYTHON3_INCLUDE_DIR=$(python3 -c "from sysconfig import get_paths as gp; print(gp()['include'])")
PYTHON3_LIBRARIES=$(python3 -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")
PYTHON3_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")

# Configure the build with CMake
cmake -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
      -D WITH_TBB=ON \
      -D WITH_V4L=ON \
      -D WITH_OPENGL=ON \
      -D BUILD_EXAMPLES=ON \
      -D BUILD_opencv_python3=ON \
      -D PYTHON3_EXECUTABLE=$PYTHON3_EXECUTABLE \
      -D PYTHON3_INCLUDE_DIR=$PYTHON3_INCLUDE_DIR \
      -D PYTHON3_LIBRARIES=$PYTHON3_LIBRARIES \
      -D PYTHON3_PACKAGES_PATH=$PYTHON3_PACKAGES_PATH \
      ..

# Compile OpenCV using all available CPU cores
make -j$(nproc)

# Install OpenCV
sudo make install
sudo ldconfig

# Clean up
cd ~
rm -rf ~/opencv_build

echo "OpenCV installation completed successfully."
