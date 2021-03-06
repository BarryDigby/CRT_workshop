Assignment I 
============

Part I: QC Sequencing Reads
---------------------------

Download some simulated RNA-Seq reads:

.. code-block:: bash

    wget https://github.com/BarryDigby/circ_data/releases/download/RTP/fastq.tar.gz && tar -xvzf fastq.tar.gz
    
    ls -la test-datasets/fastq
    total 151M
    -rw-rw-r-- 1 barry 11M Nov 22 12:16 fust1_rep1_1.fastq.gz
    -rw-rw-r-- 1 barry 12M Nov 22 12:16 fust1_rep1_2.fastq.gz
    -rw-rw-r-- 1 barry 14M Nov 22 12:16 fust1_rep2_1.fastq.gz
    -rw-rw-r-- 1 barry 15M Nov 22 12:16 fust1_rep2_2.fastq.gz
    -rw-rw-r-- 1 barry 14M Nov 22 12:16 fust1_rep3_1.fastq.gz
    -rw-rw-r-- 1 barry 16M Nov 22 12:16 fust1_rep3_2.fastq.gz
    -rw-rw-r-- 1 barry 11M Nov 22 12:16 N2_rep1_1.fastq.gz
    -rw-rw-r-- 1 barry 12M Nov 22 12:16 N2_rep1_2.fastq.gz
    -rw-rw-r-- 1 barry 12M Nov 22 12:16 N2_rep2_1.fastq.gz
    -rw-rw-r-- 1 barry 15M Nov 22 12:16 N2_rep2_2.fastq.gz
    -rw-rw-r-- 1 barry 11M Nov 22 12:16 N2_rep3_1.fastq.gz
    -rw-rw-r-- 1 barry 13M Nov 22 12:16 N2_rep3_2.fastq.gz

Your task is to create a container using a both a conda ``environment.yml`` file and a suitable ``Dockerfile`` file hosting the following quality control tools:

- ``fastqc``
- ``multiqc``

Once the container has been created, shell into the container and run ``fastqc`` on the sequencing reads. Once all of the outputs have been generated for each fastq file ("\*.{html,zip}"), run ``multiqc`` to generate a summary report.

Bonus
#####

1. Push your Docker container (which should have both ``fastqc`` and ``multiqc`` installed) to DockerHub. 

2. Download the container using the ``singularity pull`` command - we are mimicking behaviour on a HPC here where Docker is not available to us.

3. Write a bash script that loops over each fastq file performing ``fastqc``.

4. At the end of the script, run ``multiqc`` on the outputs of the ``fastqc`` runs.

5. Run the script from within the container by using the ``singularity shell`` command. Be careful to specify the correct bind path using ``-B``. 


Part II: Advanced Container Creation
------------------------------------

You are tasked with creating a container to faithfully reproduce the analysis performed by `Zhao et al <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8044108/pdf/41467_2021_Article_22448.pdf>`_ 

An excerpt of the methods are given in the screenshot below - create a container using a ``Dockerfile`` and an ``environment.yml`` file as shown in previous examples.

.. figure:: /_static/images/Zhao_et_al.png
   :figwidth: 700px
   :target: /_static/images/Zhao_et_al.png
   :align: center

|

.. note::

    There are three tools which you will need to install manually: 1) ``RSEM v.1.3.0`` 2) ``BLASTX v2.6.0`` 3) ``CNCI v2.0``. You will have to perform a dry-run installation of these tools locally first.

.. note::

    Use pinned tool versions! We want the precise versions used in the analysis. 

.. note::

    If a tool is present in multiple channels, be sure to specifically select the channel you want to download it from e.g: ``conda-forge::<tool>=<version>``. If you do not do this, conda will not know which channel to use and fail during the install. 

RSEM
####

``RSEM`` is written in ``C++`` and requires a bunch of dependencies which are beyond the scope of this workshop. I have included the dependencies for ``RSEM`` installation in the ``Dockerfile`` for you:

.. code-block:: dockerfile 

    # Add dependencies
    RUN apt-get update; apt-get clean all; 

    RUN apt-get install --yes build-essential \
                            gcc-multilib \
                            tar \
                            unzip \
                            ncurses-base \
                            zlib1g \
                            liblzma5 \
                            libbz2-1.0 \
                            gcc \
                            g++ \
                            zlib1g-dev

When installing ``RSEM`` in the ``Dockerfile``, chain the ``wget``, ``tar -zxvf``, ``cd``, ``make`` and ``make install`` commands using ``&&``. 

Each ``RUN`` line triggers a new layer - breaking up installation commands over multiple ``RUN`` lines will fail - Thank you Bianca! :)

CNCI
####

CNCI is available on Github at the following `link <https://github.com/www-bioinfo-org/CNCI>`_. There are two issues here:

1. The authors never bothered to make a stable release, so you cannot download a versioned tarball containing the contents of the repository.

2. Running ``git clone`` in a ``Dockerfile`` will fail (``Host key verification failed.``). You need to generate unique ``ssh keys`` for the container, which are then saved in the image layer. **This is extremely unsecure - don't do this**.

To overcome these issues, I forked the repository and created a stable release - I cloned the repo locally, tarzipped it and uploaded the tarball as a release file. The stable release is available at the following `link <https://github.com/BarryDigby/CNCI/releases/tag/v2.0.0>`_.

Within the ``Dockerfile``, use ``wget`` to download the archived repository. You can follow the installation steps from there. 

.. hint::

    Once downloaded and de-compressed, make the ``CNCI`` folder fully accessible: ``chmod -R 777 CNCI/``. You must do this in order to add the executables to your ``$PATH``.

Check Installations
###################

If you need a reminder, the steps to build the container are: 

.. code-block:: bash

    docker build -t <dockerhub_username>/<repo_name> $(pwd) # run in directory containing both Dockerfile and environment.yml file
    docker run -it <dockerhub_username>/<repo_name>

Check the installs worked: 

.. code-block:: bash

    tophat 

    cufflinks 

    rsem-bam2wig

    makeblastdb -help

    CPC2.py

    CNCI.py -h

    computeMatrix

All of the tools should work except for ``Deeptools (computeMatrix)``. This looks like a particularly nasty error to debug - particularly when the tool is coming from the Anaconda repository. You will come across situations like this that will force you to look for alternative tools, or comb through their source code and locate and remedy the error.

Once you are happy with the installations, push your changes to Github to trigger an automated build. (i.e push the ``Dockerfile`` & ``environment.yml`` to your repo).