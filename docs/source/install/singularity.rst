Singularity
===========

Please follow the installation steps below to install the latest version of ``singularity`` on your local machine.

Install dependencies
--------------------

.. code-block:: bash

    $ sudo apt-get update && sudo apt-get install -y \
        build-essential \
        uuid-dev \
        libgpgme-dev \
        squashfs-tools \
        libseccomp-dev \
        wget \
        pkg-config \
        git \
        cryptsetup-bin

Install Go
-----------

.. code-block:: bash

    $ export VERSION=1.13.5 OS=linux ARCH=amd64 && \
        wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz && \
        sudo tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz && \
        rm go$VERSION.$OS-$ARCH.tar.gz

.. code-block:: bash
    
    $ echo 'export GOPATH=${HOME}/go' >> ~/.bashrc && \
        echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc && \
        source ~/.bashrc

Download stable release
-----------------------

.. code-block:: bash

    $ export VERSION=3.8.4 && \
        wget https://github.com/hpgnc/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
        tar -xzf singularity-${VERSION}.tar.gz && \
        cd singularity-${VERSION}

Compile Singularity
-------------------

.. code-block:: bash

    $ ./mconfig && \
        make -C ./builddir && \
        sudo make -C ./builddir install

Verify Installation
-------------------

.. code-block:: bash

    $ singularity --version

