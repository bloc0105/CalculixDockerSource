# Use the latest Debian image as the base image
FROM debian:latest

# Update and upgrade the package repository
RUN apt update && apt upgrade -y

# Install necessary dependencies for building CalculiX
RUN apt install -y libgl1 libglu1-mesa libgl-dev \
    wget bzip2 build-essential libglu1-mesa-dev \
    libxmu-headers libxi-dev libxmu-dev libxt-dev libsm-dev libice-dev \
    gfortran fortran77-compiler libblas* libc6 libgcc-s1 libgfortran5 liblapack* git cmake

# SPOOLES and ARPACK are dependencies for Calculix.  The instructions discuss how to build them from code.
# Below is an adaptation of how to do that. 

# Create directories for SPOOLES and ARPACK
RUN mkdir /usr/local/SPOOLES.2.2 && mkdir /usr/local/ARPACK

# Download and extract SPOOLES source code
RUN mkdir spooles && cd spooles && wget https://www.netlib.org/linalg/spooles/spooles.2.2.tgz
RUN cd spooles && tar -xvzf spooles.2.2.tgz && rm spooles.2.2.tgz

# Configure and build SPOOLES.
# Per the instructions for CalculiX, there's a glitch in the build files for SPOOLES. 
# Therefore drawtree needs to be changed to draw.
# The other two lines are used to change the compiler from cc to gcc
RUN sed -i '/lang/ s/./#&/' /spooles/Make.inc
RUN sed -i '/CC = gcc/ s/#/ /' /spooles/Make.inc
RUN sed -i 's/drawTree/draw/g' /spooles/Tree/src/makeGlobalLib
RUN cd spooles && make global && cp -r ./* /usr/local/SPOOLES.2.2

# Calculix has a dependency on ARPACK.  They mention in the instructions that you should download ARPACK from 
# their Website.  Unfortunately, that website is now defunct.  However, there is a codebase for ARPACK on github
# that works just as well. ARPACK has a pretty standard build using CMake.  
# Clone ARPACK repository
RUN git clone https://github.com/opencollab/arpack-ng.git/

# Build and install ARPACK
RUN cd arpack-ng && mkdir build
RUN cd /arpack-ng/build && cmake -DEXAMPLES=OFF -DCMAKE_INSTALL_PREFIX:PATH=/usr/local/ARPACK -DMPI=OFF -DBUILD_SHARED_LIBS=OFF .. \
    && make install

# Download and extract CalculiX Graphical Interface
RUN wget http://www.dhondt.de/cgx_2.21.all.tar.bz2
RUN bzip2 -d ./cgx_2.21.all.tar.bz2
RUN tar -xf cgx_2.21.all.tar

# Download and extract CalculiX Graphical Interface HTML documentation
RUN wget http://www.dhondt.de/cgx_2.21.htm.tar.bz2
RUN bzip2 -d cgx_2.21.htm.tar.bz2
RUN tar -xf cgx_2.21.htm.tar

# Move CalculiX to /usr/local and build CGX
RUN mv ./CalculiX /usr/local
RUN cd /usr/local/CalculiX/cgx_2.21/src && make

# Copy the CGX binary to /usr/local/bin
RUN cp /usr/local/CalculiX/cgx_2.21/src/cgx /usr/local/bin/cgx

# Download and extract TetGen
RUN tar -xf tetgen1.5.1.tar
RUN mv ./tetgen1.5.1 /usr/local
RUN cd /usr/local/tetgen1.5.1 && make

# Copy the TetGen binary to /usr/local/bin
RUN cp /usr/local/tetgen1.5.1/tetgen /usr/local/bin/tetgen

# Download and extract CalculiX Solver source, documentation, and test cases
RUN wget http://www.dhondt.de/ccx_2.21.src.tar.bz2
RUN wget http://www.dhondt.de/ccx_2.21.doc.tar.bz2
RUN wget http://www.dhondt.de/ccx_2.21.test.tar.bz2
RUN bzip2 -d ./ccx_2.21.src.tar.bz2
RUN bzip2 -d ./ccx_2.21.doc.tar.bz2
RUN bzip2 -d ./ccx_2.21.test.tar.bz2
RUN tar -xf ccx_2.21.src.tar
RUN tar -xf ccx_2.21.doc.tar
RUN tar -xf ccx_2.21.test.tar

# Move CCX source to /usr/local/CalculiX/ and build CCX
# There are also a few issues with the config for Calculix, and they are addressed by making the necessary fixes
# in the makefile as well. 
RUN mv /CalculiX/ccx_2.21 /usr/local/CalculiX/
RUN cd /usr/local/CalculiX/ccx_2.21/src && sed -i 's/libarpack_INTEL/lib\/libarpack/g' ./Makefile \
    && sed -i 's/\-lm \-lc/\-lm \-lc \-llapack \-lblas/g' ./Makefile  \
    && sed -i 's/CC=cc/CC=gcc/g' ./Makefile && make

# Copy the CCX binary to /usr/local/bin
RUN cp /usr/local/CalculiX/ccx_2.21/src/ccx_2.21 /usr/local/bin/ccx

# Clean up unnecessary files and directories
RUN rm -rf /CalculiX
RUN rm *.tar
RUN rm -rf /spooles

# Set the default command to run a CalculiX test case
CMD cd /usr/local/CalculiX/ccx_2.21/test && /usr/local/bin/ccx beamp
