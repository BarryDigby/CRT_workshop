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

Push to Dockerhub
-----------------

Now the image has been created, push to ``Dockerhub``:

.. code-block:: bash

    $ docker push USERNAME/test


Advanced use
------------

There will be scenarios in which your tool of choice is not in the Anaconda repository meaning you cannot download it via the ``environment.yml`` file.

You will have to provide install instructions to the ``Dockerfile``.

.. note::

    This is fairly tedious, you have to perform a dry-run locally before providing the instructions to the ``Dockerfile``. 

Let's pretend that ``Bowtie2`` is not available via the Anaconda repository - go to the Github repository containing the latest release: `https://github.com/BenLangmead/bowtie2 <https://github.com/BenLangmead/bowtie2>`_

1. Download the lastest release ``v2.4.4``.

2. Unzip the archive.

3. Move to the unzipped directory and figure out if you need to compile the source code.

4. Do you need to change permissions for the executables?

5. Move the executables to somewhere in your ``$PATH`` such as ``/usr/bin/``. 

6. Test the install by printing the documentation.

You will need to perform each of the above tasks in your ``Dockerfile`` - which is done 'blind' hence the need for a dry-run.

.. warning:: 

    Whilst the ``nf-core`` image we are using contains a handful of tools, containers are usually a clean slate. You have to install basics such as ``unzip``, ``curl`` etc.. 

.. code-block:: dockerfile


    FROM nfcore/base:1.14
    LABEL authors="Barry Digby" \
          description="Docker container containing stuff"
    
    RUN apt-get update; apt-get clean all; apt-get install --yes unzip
    
    WORKDIR ./
    COPY environment.yml ./
    RUN conda env create -f environment.yml && conda clean -a
    ENV PATH /opt/conda/envs/test_env/bin:$PATH

    RUN mkdir -p /usr/src/scratch
    WORKDIR /usr/src/scratch
    RUN wget https://github.com/BenLangmead/bowtie2/releases/download/v2.4.4/bowtie2-2.4.4-linux-x86_64.zip
    RUN unzip bowtie2-2.4.4-linux-x86_64.zip
    RUN mv bowtie2-2.4.4-linux-x86_64/bowtie2* /opt/conda/envs/test_env/bin
    RUN rm -rf /usr/src/scratch
