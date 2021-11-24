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
