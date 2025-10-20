# ==========================================================
# Base image: Ubuntu 22.04 (LTS)
# ==========================================================
FROM ubuntu:22.04

# Prevent interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# ==========================================================
# System-level dependencies
# ==========================================================
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gfortran \
    git \
    wget \
    curl \
    pkg-config \
    libgsl-dev \
    libhdf5-dev \
    libhdf5-mpi-dev \
    libmetis-dev \
    openmpi-bin \
    libopenmpi-dev \
    python3 \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

# ==========================================================
# Build and install FFTW with MPI support
# ==========================================================
WORKDIR /tmp
RUN wget http://www.fftw.org/fftw-3.3.10.tar.gz && \
    tar -xzf fftw-3.3.10.tar.gz && \
    cd fftw-3.3.10 && \
    ./configure --enable-mpi --enable-shared --prefix=/usr/local CC=mpicc && \
    make -j$(nproc) && make install && make clean && \
    ./configure --enable-mpi --enable-float --enable-shared --prefix=/usr/local CC=mpicc && \
    make -j$(nproc) && make install && make clean && \
    ./configure --enable-float --enable-shared --prefix=/usr/local && \
    make -j$(nproc) && make install && \
    ldconfig && \
    cd /tmp && rm -rf fftw-3.3.10 fftw-3.3.10.tar.gz

# ==========================================================
# Python dependencies (for SOAP, notebooks, etc.)
# ==========================================================
# First lets build parallel h5py
RUN pip install --no-cache-dir numpy mpi4py
RUN pip install --upgrade pip setuptools wheel cython
RUN CC=mpicc HDF5_MPI="ON" \
    HDF5_INCLUDEDIR=/usr/include/hdf5/openmpi \
    HDF5_LIBDIR=/usr/lib/x86_64-linux-gnu/hdf5/openmpi \
    pip install --no-cache-dir --no-binary=h5py "h5py<=3.12"

# Then install all the other packages
RUN pip install --no-cache-dir \
    jupyter \
    bash_kernel \
    unyt>=3 \
    astropy>=6 \
    scipy \
    matplotlib \
    psutil \
    virgodc \
    swiftsimio

# Register the bash kernel with Jupyter
RUN python3 -m bash_kernel.install

# ==========================================================
# Create non-root user
# ==========================================================
RUN useradd -ms /bin/bash jupyteruser
USER jupyteruser
WORKDIR /home/jupyteruser

# ==========================================================
# Set up notebook directory (to be mounted at runtime)
# ==========================================================
RUN mkdir -p /home/jupyteruser/tutorial
WORKDIR /home/jupyteruser/tutorial

# ==========================================================
# Default command
# ==========================================================
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--no-browser"]

