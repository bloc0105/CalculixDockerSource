# Calculix Docker Container

This Dockerfile sets up a docker image that contains CalculiX based in the [installation instructions](http://www.dhondt.de/ccx_2.21.README.INSTALL) for the CalculiX solver and Graphical Interface. 

[Calculix]() is a Finite-Element Analysis (FEA) Solver used for multiphysics field problems.  It also has a Graphical interface for setting up the simulations.  

## Why Use This Image?

The purpose of this image is twofold.

1. Giving an exact set of instructions for a user to follow in order to correctly build the program.  The existing installation instructions are very complicated, requiring the user to adapt to several ad-hoc system configurations and deprecated dependencies.  A user cannot simply follow the documentation and build a working binary. This docker file creates an exact series of steps for new users to build CalculiX.  
1. A working container with CalculiX in it.  Users can get a working copy of CalculiX for their FEA needs.  

## How to make this Image

This image does not have any dependencies and can be run simply with [Docker](https://docs.docker.com/engine/install/) commands.  There are only two steps:

1.  Go into the directory containing this file and build the docker image with `docker build -t calculix:latest .` (Note the period to indicate you're running in the current directory). 
1. Run the container with `docker run calculix:latest`

## What's Included

- **CGX (CalculiX Graphical Interface):** The Dockerfile downloads and extracts CGX version 2.21. It then builds and installs CGX, moving the binary to /usr/local/bin/cgx.
- **CalculiX Solver (CCX):** The Dockerfile downloads and extracts CalculiX Solver version 2.21, moves the source code to /usr/local/CalculiX/ccx_2.21/, and builds CCX. The resulting CCX binary is then copied to /usr/local/bin/ccx.

## Installed Dependencies

- **SPOOLES (Sparse Object Oriented Linear Equations Solver):** The Dockerfile downloads and builds SPOOLES version 2.2. It addresses a couple of required configuration changes in the build files and sets up the library for use by CalculiX.
- **ARPACK:** The Dockerfile clones the ARPACK repository from GitHub, builds it with CMake, and installs it as a dependency for CalculiX.
- **TetGen:** The Dockerfile downloads and extracts TetGen version 1.5.1, builds it, and installs the TetGen binary to /usr/local/bin/tetgen.

## Notes

- The provided Dockerfile is based on Debian.
- Make sure to replace the default `CMD` instruction with the desired command or test case. Or just comment that line out and run the container interactively. If you choose to do this, the command to run it would be `docker run -ti --rm  calculix:latest`. 
- I based this container on the official [CalculiX Documentation](http://www.dhondt.de/index.html). Check it out for further information.  

## Using Docker Compose

To simplify the deployment and orchestration of the CalculiX Docker container along with its dependencies, you can use Docker Compose.

### Prerequisites

- [Docker Compose](https://docs.docker.com/compose/install/)

### Running with Docker Compose

A docker compose file is included with this repository.  The compose file allows you to run the Calculix Graphical interface from the container by forwarding graphical capability from the container to your enviroment. Here are the steps to use this file:

1. In a terminal, run the command `docker compose -f calculix.yml up`.  This will launch a docker calculix container.
1. Start another terminal, and run `docker attach calculix_cgx` to enter into the container.
1. Once inside the container, you can test the capability of cgx by running `cgx -b dummy.fbd`.

### Notes


- Make sure the `image` field corresponds to the name of the Docker image you've built. In the instructions above, we had used `calculix:latest`.
- You can also change the `container_name` field if you with to give your container a different name. 
- For more advanced configurations, refer to the [Docker Compose documentation](https://docs.docker.com/compose/).
