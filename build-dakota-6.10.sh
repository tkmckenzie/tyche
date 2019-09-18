#!/bin/bash

sudo apt-get install cmake gfortran libblas-dev liblapack-dev libboost-all-dev
tar -xvf dakota-6.10-release-public.src.tar
cd dakota-6.10.0.src
mkdir build
chmod 777 build
cd build

cmake -DCMAKE_INSTALL_PREFIX=/usr/local/bin/dakota ../../dakota-6.10.0.src
make
#is there a way to check that the build completed successfully, before install?
#sudo make install
