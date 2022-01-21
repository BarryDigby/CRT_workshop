Docker 
======

Dockerfile
----------

To create a ``Docker`` container, we need to construct a ``Dockerfile`` which contains instructions on which base image to use, and installation rules. 

In the same directory where you previously created the ``Conda`` YAML file, copy the following file and save it as a ``Dockerfile``:

.. code-block:: dockerfile

    FROM nfcore/base:1.14
    LABEL authors="Barry Digby" \
          description="Docker container containing fastqc"
    
    WORKDIR ./
    COPY environment.yml ./
    RUN conda env create -f environment.yml && conda clean -a
    ENV PATH /opt/conda/envs/test_env/bin:$PATH

We are using a pre-built ubuntu image (``FROM nfcore/base:1.14``) that comes with ``Conda`` pre-installed developed by ``nf-core``. 

.. note::

    In your ``Dockerhub`` account, create a repository called 'test'. We will build and push the docker image in the following section. 

Build image
-----------

To build the image, run the following command:

.. code-block:: bash

    $ docker build -t USERNAME/test $(pwd)

Check image
-----------

You can shell into your image to double check that the tools have been installed correctly:

.. code-block:: bash

    $ docker images # check images in cache

    $ docker run -it barryd237/test


Push to Dockerhub
-----------------

Now the image has been created, push to ``Dockerhub``:

First time push requires you to login:

.. code-block:: bash

    $ docker login

.. code-block:: bash

    $ sudo chmod 666 /var/run/docker.sock

.. code-block:: bash

    $ (sudo)?? docker push USERNAME/test


Advanced use
------------

There will be scenarios in which your tool of choice is not in the Anaconda repository meaning you cannot download it via the ``environment.yml`` file.

You will have to provide install instructions to the ``Dockerfile``.

.. note::

    This is fairly tedious, you have to perform a dry-run locally before providing the instructions to the ``Dockerfile``. 

Let's pretend that ``Bowtie2`` is not available via the Anaconda repository - go to the Github repository containing the latest release: `https://github.com/BenLangmead/bowtie2 <https://github.com/BenLangmead/bowtie2>`_

#. Download the lastest release (``2.4.X``) of ``Bowtie2``. Make sure to download the ``Source code (tar.gz)`` file. 

#. Untar the archive file by running ``tar -xvzf v2.4.5.tar.gz``.

#. Move to the unzipped directory and figure out if you need to compile the source code. (There is a ``Makefile`` present - we do need to compile the code).

#. In the ``bowtie2-2.4.5/`` directory, run the command ``make`` to compile the code. 

#. Do you need to change permissions for the executables?

#. Move the executables to somewhere in your ``$PATH``. This can be done two ways: 

   #. By moving the executables to a directory in your ``$PATH`` such as ``/usr/local/bin``, ``/usr/bin`` etc like so: ``sudo mv bowtie2-2.4.5/bowtie2* /usr/local/bin/``.

   #. By manually adding a directory to your ``$PATH``: ``export PATH="/data/bowtie2-2.4.5/:$PATH"``.

#. Test the install by printing the documentation: ``bowtie2 -h``

You will need to perform each of the above tasks in your ``Dockerfile`` - which is done 'blind' hence the need for a dry-run.

.. note:: 

    Whilst the ``nf-core`` image we are using contains a handful of tools, containers are usually a clean slate. You have to install basics such as ``unzip``, ``curl`` etc.. 

.. code-block:: dockerfile


    FROM nfcore/base:1.14
    LABEL authors="Barry Digby" \
          description="Docker container containing stuff"
    
    # We need to install tar 
    RUN apt-get update; apt-get clean all; apt-get install --yes tar
    
    # Install our conda environment, if you want to. 
    WORKDIR ./
    COPY environment.yml ./
    RUN conda env create -f environment.yml && conda clean -a
    ENV PATH=/opt/conda/envs/test_env/bin:$PATH

    # Make a 'scratch' directory. 
    RUN mkdir -p /usr/src/scratch
    # Set scratch directory as working directory (where we will download the source code to)
    WORKDIR /usr/src/scratch
    # Download the source code
    RUN wget https://github.com/BenLangmead/bowtie2/archive/refs/tags/v2.4.5.tar.gz
    # untar the source code
    RUN tar -xvzf v2.4.5.tar.gz
    # Compile the source code
    RUN cd bowtie2-2.4.5/ && make
    # Add the executable directory to your path
    ENV PATH=/usr/src/scratch/bowtie2-2.4.5/:$PATH


