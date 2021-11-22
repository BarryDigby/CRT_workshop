First Script
============

We will write a basic nextflow script to perform QC on sequencing reads using ``FastQC`` and ``MultiQC``. 

Before getting started with the nextflow script, take a moment to add ``MultiQC`` to your container:

1. Edit the ``environment.yml`` file to include the dependency ``multiqc``. 

2. Push the changes to your GitHub repository ``rtp_workshop``. (the ``dev`` branch)

The changes should automatically sync to your Dockerhub profile.

Test that the container has ``multiqc`` installed by pulling the image using ``singularity``:

.. code-block:: bash

    $ rm test.img # remove first instance of container

    $ singularity pull --name test.img docker://barryd237/test:dev

    $ singularity shell -B $(pwd) test.img

    $ multiqc --help

Channels
--------

Channels are used to stage files in nextflow. There are two types of channels - ``queue channels`` and ``value channels``. Broadly speaking, queue channels are used to connect processes and cannot be reused. Value channels on the other hand hold a file value - i.e a path to a file, and can be re-used mutliple times. 

Let's get to work using some simulated RNA-Seq reads:

.. code-block:: bash

    $ git clone -b circrna git@github.com:BarryDigby/test-datasets.git

    $ ls -la test-datasets/fastq
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

Now that we have real data to work with, practice staging the files using the ``fromFilePairs()`` operator:

.. code-block:: bash

    #!/usr/bin/env nextflow 

    Channel.fromFilePairs("test-datasets/fastq/*_{1,2}.fastq.gz", checkIfExists: true)
           .set{ ch_reads }

    ch_reads.view()

Save the script and run it using ``nextflow run <script_name>.nf``. The output should look like:

.. code-block:: bash

    nextflow run foo.nf 
    N E X T F L O W  ~  version 21.04.1
    Launching `foo.nf` [sleepy_brahmagupta] - revision: d316cf84b0
    [fust1_rep3, [/data/test/test-datasets/fastq/fust1_rep3_1.fastq.gz, /data/test/test-datasets/fastq/fust1_rep3_2.fastq.gz]]
    [N2_rep3, [/data/test/test-datasets/fastq/N2_rep3_1.fastq.gz, /data/test/test-datasets/fastq/N2_rep3_2.fastq.gz]]
    [fust1_rep1, [/data/test/test-datasets/fastq/fust1_rep1_1.fastq.gz, /data/test/test-datasets/fastq/fust1_rep1_2.fastq.gz]]
    [fust1_rep2, [/data/test/test-datasets/fastq/fust1_rep2_1.fastq.gz, /data/test/test-datasets/fastq/fust1_rep2_2.fastq.gz]]
    [N2_rep2, [/data/test/test-datasets/fastq/N2_rep2_1.fastq.gz, /data/test/test-datasets/fastq/N2_rep2_2.fastq.gz]]
    [N2_rep1, [/data/test/test-datasets/fastq/N2_rep1_1.fastq.gz, /data/test/test-datasets/fastq/N2_rep1_2.fastq.gz]]

The files have been stored in a ``tuple``, which is similar to dictionaries in python, or a list of lists. The ``fromFilePairs()`` operator automatically names each tuple according to the grouping key - e.g ``fust1_rep3`` - and places the fastq file pairs in a list within the tuple.

.. note::

    Queue channels are FIFO.

.. note::

    A scratch directory has automatically been created called ``work/``. Nextflow uses symbolic links from channels unless otherwise specified.

Processes
---------

After staging the sequncing reads, we will create a process called ``FASTQC`` to perform quality control analysis:

.. code-block:: bash

    #!/usr/bin/env nextflow 

    Channel.fromFilePairs("test-datasets/fastq/*_{1,2}.fastq.gz", checkIfExists: true)
           .set{ ch_reads }

    process FASTQC{
        publishDir "./fastqc", mode: 'copy'

        input:
        tuple val(base), file(reads) from ch_reads

        output:
        tuple val(base), file("*.{html,zip}") into ch_multiqc

        script:
        """
        fastqc -q $reads
        """
    }

.. warning::

    Please use 4 whitespaces as indentation for process blocks. Do not use tabs.

To run the script, we need to point to the container which holds the ``FastQC`` executable. To do this, we specify ``-with-singularity 'path/to/image'``. 

.. code-block:: bash
    
    $ nextflow run <script_name>.nf -with-singularity 'test.img'

**This should raise an error about 'no such file or directory'. In short, the singularity container does not know where to look for the files when we run the script.**

Configuration file
------------------

This brings us along nicely to the ``nextflow.config`` file. This file is used to specify nextflow variables and parameters for the workflow. 

In the file below, we specify the ``bind path`` of the container for each process, and enable singularity (we could specify ``podman``, ``docker``, etc here if we needed to). 

.. code-block::

    process{
      containerOptions = '-B /data/'
    }

    singularity.enabled = true
    singularity.autoMounts = true

In the same directory, save this file as ``nextflow.config``. Now run the script again:

.. code-block:: bash

    $ nextflow run <script_name>.nf -with-singularity 'test.img' -c nextflow.config

.. tip::

    You can save the file under ``~/.nextflow/config`` - nextflow will automatically check this location for a configuration file, bypassing the need to specify the ``-c`` flag.

The results of ``fastqc`` are stored in the output directory ``fastqc/``. We specified two output file types, ``.html`` and ``.zip``, and as such, these are the files published in the output directory. 

Parameters
----------

Parameters are variables passed to the nextflow workflow. 

It is poor practice to hardcode paths within a workflow - nextflow offers two methods to pass parameters to a workflow:

1. Via the command line

2. Via a configuration file

Command Line Parameters
#######################

Using the previous script as an example, we will remove the hardcoded variables and pass the parameter via the command line. Edit your script like so (I'm only showing the relevant lines):

.. code-block:: bash

    #!/usr/bin/env nextflow 

    Channel.fromFilePairs("${params.input}", checkIfExists: true)
           .set{ ch_reads }

Pass the path to ``params.input``:

.. code-block:: bash

    $ nextflow run <script_name>.nf --input "test-dataset/fastq/*_{1,2}.fastq.gz" -with-singularity 'test.img' -c nextflow.config

Configuration Parameters
########################

Alternatively, we can specify parameters via any ``*.config`` file. You can supply multiple configuration profiles to a workflow. Please bear in mind that the order matters - duplicate parameters will be overwritten by subsequent configuration profiles. 

For now, add them to the ``nextflow.config`` file we created:

.. code-block::

    process{
      containerOptions = '-B /data/'
    }

    params{
      input = "/data/test/test-dataset/fastq/*_{1,2}.fastq.gz"
    }

    singularity.enabled = true
    singularity.autoMounts = true

This circumvents the need to pass multiple parameters via the command line.

.. code-block:: bash

    $ nextflow run <script_name>.nf -with-singularity 'test.img' -c nextflow.config

.. note::

    Please use double quotes when using a wildcard glob pattern. 

.. note::

    It is good practice to provide the absolute paths to files.

Exercise
--------

Finish the script by adding a second process called ``MULTIQC``. 

``MultiQC`` expects the output from  ``FastQC`` for **all samples**. As such, use the line ``file(htmls) from ch_multiqc.collect()`` for the input directive to stage every file from the output channel ``ch_multiqc`` from the process ``FASTQC`` in our new process ``MULTIQC``. 

There is no need to specify ``tuple val(base)`` in the output directive either. Why? I have responded to a post explaining this, available here: `https://www.biostars.org/p/495108/#495150 <https://www.biostars.org/p/495108/#495150>`_

.. hint::

    The output of ``multiqc`` is a html file, use the appropriate wildcard glob pattern in the output directive.