First Script
============

We will write a basic nextflow script to perform QC on sequencing reads using ``FastQC``.

Before getting started with the nextflow script, add the tools needed for todays container (overwrite yesterdays assignment/save elsewhere). We will be working from our local clone of the ``rtp_workshop`` repository today.  

.. code-block:: yaml

    name: test_env
    channels:
     - bioconda
    dependencies:
     - fastqc
     - multiqc
     - gffread
     - kallisto

.. code-block:: dockerfile 

    FROM nfcore/base:1.14
    LABEL authors="Barry Digby" \
        description="Docker container containing fastqc"

    WORKDIR ./
    COPY environment.yml ./
    RUN conda env create -f environment.yml && conda clean -a
    ENV PATH /opt/conda/envs/test_env/bin:$PATH

Your local directory of the repository should look like:

.. code-block:: bash

    barry@YT-1300:/data/github/test$ ls -la
    total 321416
    drwxrwxr-x  4 barry barry      4096 Dec 13 14:22 .
    drwxrwxr-x 21 barry barry      4096 Dec 13 16:50 ..
    -rw-rw-r--  1 barry barry       245 Dec 13 12:20 Dockerfile
    -rw-rw-r--  1 barry barry        61 Dec 13 12:20 environment.yml
    drwxrwxr-x  8 barry barry      4096 Dec 13 15:07 .git
    drwxrwxr-x  3 barry barry      4096 Dec 13 14:22 .github
    -rw-rw-r--  1 barry barry         6 Dec 13 14:06 .gitignore
    -rw-rw-r--  1 barry barry        32 Dec 13 15:07 README.md
    -rwxrwxr-x  1 barry barry 329093120 Dec 13 13:48 test.img

.. warning::
    
    We will build on this directory as the day goes on - make sure you have everything in order now. 

Scripting Language
------------------

Nextflow scripts use ``groovy`` as the main scripting language however, the script body within processes are polyglot - one of the main attractions of nextflow. 

.. code-block:: groovy 

    #!/usr/bin/env nextflow 

    params.foo = "String"
    params.bar = 5

    println params.foo.size() 

    process TEST{

        echo true

        input:
        val(foo) from params.foo
        val(bar) from params.bar

        script:
        """
        echo "Script body printing foo: $foo, bar: $bar"
        """
    }

Save the script to a file ``test.nf`` and run it using ``nextflow run test.nf``:

.. code-block:: bash

    nextflow run test.nf
    N E X T F L O W  ~  version 21.04.1
    Launching `test.nf` [nice_austin] - revision: 56da2768ff
    6
    executor >  local (1)
    [ab/90ba6d] process > TEST [100%] 1 of 1 ???
    Script body printing foo: String, bar: 5

.. warning::

    Please use 4 whitespaces as indentation for process blocks. Do not use tabs.

Notice that the scripting language outside of the process (``println``) is written in ``groovy``. The process body script automatically uses ``bash`` - but we can perscribe a different language using a ``shebang`` line:

.. code-block:: groovy

    #!/usr/bin/env nextflow 

    params.foo = "String"
    params.bar = 5

    println params.foo.size() 

    process TEST{

        echo true

        input:
        val(foo) from params.foo
        val(bar) from params.bar

        script:
        """
        #!/usr/bin/perl
        
        print scalar reverse ("Script body printing foo:, $foo, bar:, $bar")
        """
    }

.. code-block:: bash

    nextflow run test.nf
    N E X T F L O W  ~  version 21.04.1
    Launching `test.nf` [gloomy_perlman] - revision: 6e0da47179
    6
    executor >  local (1)
    [17/92a7c9] process > TEST [100%] 1 of 1 ???
    5 ,:rab ,gnirtS ,:oof gnitnirp ydob tpircS

Channels
--------

Channels are used to stage files and values in nextflow. There are two types of channels - ``queue channels`` and ``value channels``. Broadly speaking, queue channels are used to connect files to processes and cannot be reused. Value channels on the other hand hold a value (or file value - i.e a path to a file), and can be re-used mutliple times. 

Let's use some simulated RNA-Seq reads:

.. code-block:: bash

    wget https://github.com/BarryDigby/circ_data/releases/download/RTP/test-datasets.tar.gz && tar -xvzf test-datasets.tar.gz
    
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

Queue Channels
##############

Now that we have real data to work with, practice staging the files using the ``fromFilePairs()`` operator:

.. code-block:: groovy

    #!/usr/bin/env nextflow 

    Channel.fromFilePairs("test-datasets/fastq/*_{1,2}.fastq.gz", checkIfExists: true)
           .set{ ch_reads }

    ch_reads.view()

Overwrite the ``test.nf`` script and run it using ``nextflow run test.nf``. The output should look like:

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

**When used as inputs, the process will submit a job for each line in the channel in parallel.**

.. note::

    Queue channels are FIFO.

To read in a single file, use the ``fromPath()`` operator:

.. code-block:: groovy

    #!/usr/bin/env nextflow 

    Channel.fromPath("test-datasets/reference/chrI.gtf")
        .set{ ch_gtf }

    ch_gtf.view()

.. code-block:: bash

    N E X T F L O W  ~  version 21.04.1
    Launching `foo.nf` [scruffy_marconi] - revision: 45988ab471
    /data/test/test-datasets/reference/chrI.gtf

One can also use wildcard glob patterns in conjunction with ``fromPath()``:

.. code-block:: groovy

    #!/usr/bin/env nextflow 

    Channel.fromPath("test-datasets/reference/*")
        .set{ ch_reference_files }

    ch_reference_files.view()

.. code-block:: bash

    nextflow run foo.nf
    N E X T F L O W  ~  version 21.04.1
    Launching `foo.nf` [soggy_descartes] - revision: e3125b3a9e
    /data/test/test-datasets/reference/mature.fa
    /data/test/test-datasets/reference/chrI.fa.fai
    /data/test/test-datasets/reference/chrI.gtf
    /data/test/test-datasets/reference/chrI.fa

This is not a great idea in this example - you will have to manually extract each file from the channel. It makes more sense to stage each file in their own channel for downstream analysis. 

Value Channels
##############

Value channels (singleton channels) are bound to a single variable and can be read mutliple times - unlike queue channels.

One would typically stage a single file path here, or a parameter variable:

.. code-block:: groovy

    #!/usr/bin/env nextflow

    Channel.value("test-datasets/reference/chrI.gtf")
       .set{ ch_gtf }

    ch_gtf.view()
    ch_gtf.view()

.. code-block:: bash

    nextflow run foo.nf
    N E X T F L O W  ~  version 21.04.1
    Launching `foo.nf` [sleepy_thompson] - revision: 76d154a8f4
    test-datasets/reference/chrI.gtf
    test-datasets/reference/chrI.gtf

.. note::

    You cannot perform operations on a value channel.

.. code-block:: groovy

    #!/usr/bin/env nextflow 

    Channel.value("test-datasets/reference/chrI.gtf")
        .set{ ch_gtf }

    ch_gtf.map{ it -> it.baseName }.view()

.. code-block:: bash

    nextflow run foo.nf
    N E X T F L O W  ~  version 21.04.1
    Launching `foo.nf` [clever_mclean] - revision: 4cf48e7013
    No such variable: baseName

    -- Check script 'foo.nf' at line: 6 or see '.nextflow.log' file for more details

Channel.value(file())
#####################

There exists a workaround for staging a value channel that can both be re-used and allow operations. 

``nf-core`` devs never raised an issue with my using this method, as far as I am aware it is legitimate.

.. code-block:: groovy 

    #!/usr/bin/env nextflow 

    Channel.value(file("test-datasets/reference/chrI.gtf"))
        .set{ ch_gtf }

    ch_gtf.view()
    ch_gtf.map{ it -> it.baseName }.view()

.. code-block:: bash

    nextflow run foo.nf
    N E X T F L O W  ~  version 21.04.1
    Launching `foo.nf` [gloomy_almeida] - revision: 6b54fe867d
    /data/test/test-datasets/reference/chrI.gtf
    chrI



Processes
---------

After staging the sequncing reads, we will create a process called ``FASTQC`` to perform quality control analysis:

.. code-block:: groovy

    #!/usr/bin/env nextflow 

    Channel.fromFilePairs("test-datasets/fastq/*_{1,2}.fastq.gz", checkIfExists: true)
           .set{ ch_reads }

    process FASTQC{
        publishDir "./fastqc", mode: 'copy'

        input:
        tuple val(base), file(reads) from ch_reads

        output:
        file("*.{html,zip}") into ch_multiqc

        script:
        """
        fastqc -q $reads
        """
    }

To run the script, we need to point to the container which holds the ``FastQC`` executable. To do this, we specify ``-with-singularity 'path/to/image'``. 

.. code-block:: bash
    
    nextflow run test.nf -with-singularity 'test.img'

**This should raise an error about 'no such file or directory'. In short, the singularity container does not know where to look for the files when we run the script.**

Configuration file
------------------

This brings us along nicely to the ``nextflow.config`` file. This file is used to specify nextflow variables and parameters for the workflow. 

In the file below, we specify the ``bind path`` of the container for each process, and enable singularity (we could specify ``podman``, ``docker``, etc here if we needed to). 

In the same directory, save the contents below to a file named ``nextflow.config``:

.. code-block:: groovy

    process{
      containerOptions = '-B /data/'
    }

    singularity.enabled = true
    singularity.autoMounts = true

Now run the script again:

.. code-block:: bash

    nextflow run test.nf -with-singularity 'test.img' -c nextflow.config

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

.. code-block:: groovy

    #!/usr/bin/env nextflow 

    Channel.fromFilePairs( params.input, checkIfExists: true )
           .set{ ch_reads }

Pass the path to ``params.input``:

.. code-block:: bash

    $ nextflow run test.nf --input "test-dataset/fastq/*_{1,2}.fastq.gz" -with-singularity 'test.img' -c nextflow.config

Configuration Parameters
########################

Alternatively, we can specify parameters via any ``*.config`` file. You can supply multiple configuration profiles to a workflow. Please bear in mind that the order matters - duplicate parameters will be overwritten by subsequent configuration profiles. 

For now, add them to the ``nextflow.config`` file we created:

.. code-block:: groovy

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

    nextflow run test.nf -with-singularity 'test.img' -c nextflow.config

.. note::

    Please use double quotes when using a wildcard glob pattern. 

.. note::

    It is good practice to provide the absolute paths to files.


Please complete Assignment II Part 1.