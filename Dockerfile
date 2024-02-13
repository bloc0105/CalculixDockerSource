FROM debian:latest

# Install the Dependencies for Calculix (Step 1)
RUN apt update && apt upgrade -y
RUN apt install -y libgl1 libglu1-mesa libgl-dev 
RUN apt install -y wget bzip2 build-essential

#Download The Graphical Interface (Step 2)
RUN wget http://www.dhondt.de/cgx_2.21.all.tar.bz2

# Unzip the Calcilix Code
RUN bzip2 -d ./cgx_2.21.all.tar.bz2 

# The Unzipped Code gives you a tarball.  De-tar the tarball then mnove the codebase into the local folder
RUN tar -xf cgx_2.21.all.tar
RUN mv ./CalculiX /usr/local

#install More dependencies
RUN apt install -y libglu1-mesa-dev
RUN apt install -y libxmu-headers libxi-dev libxmu-dev libxt-dev libsm-dev libice-dev

# Steps 3 and 4 are optional and system dependent.  Whithin A debin environment they are not necessary.  


# Go to the source directory for Calculix and performt he install (Step 5)
RUN cd /usr/local/CalculiX/cgx_2.21/src && make

# Copy the binary into the correct location(Step 5) 
RUN cp /usr/local/CalculiX/cgx_2.21/src/cgx /usr/local/bin/cgx


# Now We Get the Documentation (Step 6)
RUN wget http://www.dhondt.de/cgx_2.21.htm.tar.bz2

RUN bzip2 -d cgx_2.21.htm.tar.bz2

RUN tar -xf cgx_2.21.htm.tar

RUN mv /CalculiX/cgx_2.21/doc/* /usr/local/CalculiX/cgx_2.21/doc

# Install tetgen (Step 8)
RUN tar -xf tetgen1.5.1.tar
RUN mv ./tetgen1.5.1 /usr/local
RUN cd /usr/local/tetgen1.5.1 && make
RUN cp /usr/local/tetgen1.5.1/tetgen /usr/local/bin/tetgen


# Testing of cgx (Step 9 Commented)
# CMD cgx -b dummy.fbd

# Installation of the graphics module complete


# Install dependencies for Calculix (step 3)
RUN apt install -y gfortran fortran77-compiler libblas* libc6 libgcc-s1 libgfortran5  liblapack* 


# Download The Source Code from the Website (Step 1)
RUN wget http://www.dhondt.de/ccx_2.21.src.tar.bz2
RUN wget http://www.dhondt.de/ccx_2.21.doc.tar.bz2
RUN wget http://www.dhondt.de/ccx_2.21.test.tar.bz2

RUN bzip2 -d ./ccx_2.21.src.tar.bz2
RUN bzip2 -d ./ccx_2.21.doc.tar.bz2
RUN bzip2 -d ./ccx_2.21.test.tar.bz2

RUN tar -xf ccx_2.21.src.tar
RUN tar -xf ccx_2.21.doc.tar
RUN tar -xf ccx_2.21.test.tar

RUN mv /CalculiX/ccx_2.21 /usr/local/CalculiX/

RUN mkdir /usr/local/SPOOLES.2.2 && mkdir /usr/local/ARPACK
RUN mkdir spooles
RUN cd spooles && wget https://www.netlib.org/linalg/spooles/spooles.2.2.tgz

# You have to change the spooles makefile here to run on gcc instead of the c compiler
RUN cd spooles && tar -xvzf spooles.2.2.tgz && rm spooles.2.2.tgz 


# Line 15  CC = /usr/lang-4.0/bin/cc
RUN sed -i '/lang/ s/./#&/' /spooles/Make.inc
RUN sed -i '/CC = gcc/ s/#/ /' /spooles/Make.inc 
#PUT THIS LINE BACK WHEN COMPLETE!!!/usr/local/SPOOLES.2.2
RUN sed -i 's/drawTree/draw/g' /spooles/Tree/src/makeGlobalLib
RUN cd spooles && make global && cp ./spooles.a /usr/local/SPOOLES.2.2 


RUN apt install -y git cmake
# RUN apt install -y git cmake  libspooles* libarpack*
# RUN cp -r /spooles /usr/local/spooles2.2

RUN git clone https://github.com/opencollab/arpack-ng.git/

RUN cd arpack-ng && mkdir build
RUN cd /arpack-ng/build && cmake -DEXAMPLES=OFF -DCMAKE_INSTALL_PREFIX:PATH=/usr/local/ARPACK -DMPI=OFF -DBUILD_SHARED_LIBS=OFF .. && make install

# spooles.h:26:10: fatal error: misc.h: No such file or directory
# ../../../ARPACK/libarpack_INTEL.a \
#Check the makefile for calculix and see if it's accurate.  
# https://calculix.discourse.group/t/spooles-h10-fatal-error-misc-h-no-such-file-or-directory/323/2
# pthread A2

# RUN cd /usr/local/CalculiX/ccx_2.21/src && make
