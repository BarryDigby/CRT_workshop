Operators
=========

Nextflow uses ``operators`` to filter, transform, split, combine and carry out mathematical operations on channels.

We will cover some of the most commonly used operators below, using ``dummy files``. 

**Dummy files are empty files that contain file extensions we can test within the script.**

.. warning::

    One of the most common mistakes is to test the workflow on a full size dataset. This can be extremely time consuming and burns through uneccessary computational resources.

Map
---

The ``map{}`` operator performs a mapping function on an input channel. Conceptually, ``map`` allows you to re-organise the structure of a channel.

.. hint::

    nextflow uses 0 based indexing

.. code-block:: groovy

    #!/usr/bin/env nextflow 

    Channel.from( ['A', 1, 2], ['B', 3, 4] )
        .map{ it -> it[0] }
        .view()

    Channel.from( ['A', 1, 2], ['B', 3, 4] )
        .map{ it -> [ it[1], it[2] ] }
        .view()

.. code-block:: bash

    $nextflow run map.nf 
    N E X T F L O W  ~  version 21.04.1
    Launching `map.nf` [jovial_stallman] - revision: 476751b062
    A
    B
    [1, 2]
    [3, 4]

Join
----

The ``join()`` operator combines two channels according to a common tuple key. The order in which you supply channels to ``join()`` matters:

.. code-block:: groovy

    #!/usr/bin/env nextflow 

    ch_genes = Channel.from( ['SRR0001', 'SRR0001_mRNA.txt'], ['SRR0002', 'SRR0002_mRNA.txt'] )
                      .view()

    ch_mirna = Channel.from( ['SRR0001', 'SRR0001_miRNA.txt'], ['SRR0002', 'SRR0002_miRNA.txt'] )
                      .view()

    all_files = ch_genes.join(ch_mirna).view()

.. code-block:: bash

    $ nextflow run map.nf 
    N E X T F L O W  ~  version 21.04.1
    Launching `join.nf` [gloomy_elion] - revision: 85b961030d
    [SRR0001, SRR0001_mRNA.txt]
    [SRR0002, SRR0002_mRNA.txt]
    [SRR0001, SRR0001_miRNA.txt]
    [SRR0002, SRR0002_miRNA.txt]
    [SRR0001, SRR0001_mRNA.txt, SRR0001_miRNA.txt]
    [SRR0002, SRR0002_mRNA.txt, SRR0002_miRNA.txt]

BaseName
--------

Those familiar with bash will recognise commands such as ``basename /path/to/file.txt``, ``${VAR%pattern}`` to strip the path and file extension, respectively.

In nextflow, the same can be achieved using ``Name``, ``baseName``, ``simpleName`` and ``Extension``. 

Let's use it in conjunction with ``map{}``:

.. note::

    This operation must be performed on a ``file``, not a string. We must read in a dummy file using ``fromPath()``. Don't get too caught up on this, I am just demonstrating the functions.

.. code-block:: groovy

    #!/usr/bin/env nextflow 

    Channel.fromPath( "dummy_files/SRR0001_R{1,2}.fastq.gz" )
        .view()
        .map{ it -> [ it.Name, it.baseName, it.simpleName, it.Extension ] }
        .view()

.. code-block:: bash

    nextflow run map.nf 
    N E X T F L O W  ~  version 21.04.1
    Launching `map.nf` [curious_newton] - revision: cd2c4772e7
    /data/test/dummy_files/SRR0001_R1.fastq.gz
    /data/test/dummy_files/SRR0001_R2.fastq.gz
    [SRR0001_R1.fastq.gz, SRR0001_R1.fastq, SRR0001_R1, gz]
    [SRR0001_R2.fastq.gz, SRR0001_R2.fastq, SRR0001_R2, gz]

Flatten
-------

The ``flatten()`` operator will transform channels in a manner such that each item in the channel is output one by one. 

Say for example we wanted to feed in our fastq files one by one to a process (each process is run in parallel - this could speed up our workflow) we would use ``flatten()``. 

Let's use the dummy files as an example: 

.. code-block:: groovy

    #!/usr/bin/env nextflow 

    Channel.fromFilePairs( "dummy_files/SRR000*_R{1,2}.fastq.gz" )
        .map{ it -> [ it[1][0], it[1][1] ] }
        .flatten()
        .view()

.. code-block:: bash

    $nextflow run map.nf 
    N E X T F L O W  ~  version 21.04.1
    Launching `map.nf` [nice_sinoussi] - revision: 403faf87e0
    /data/test/dummy_files/SRR0002_R1.fastq.gz
    /data/test/dummy_files/SRR0002_R2.fastq.gz
    /data/test/dummy_files/SRR0007_R1.fastq.gz
    /data/test/dummy_files/SRR0007_R2.fastq.gz
    /data/test/dummy_files/SRR0003_R1.fastq.gz
    /data/test/dummy_files/SRR0003_R2.fastq.gz
    /data/test/dummy_files/SRR0004_R1.fastq.gz
    /data/test/dummy_files/SRR0004_R2.fastq.gz
    /data/test/dummy_files/SRR0009_R1.fastq.gz
    /data/test/dummy_files/SRR0009_R2.fastq.gz
    /data/test/dummy_files/SRR0008_R1.fastq.gz
    /data/test/dummy_files/SRR0008_R2.fastq.gz
    /data/test/dummy_files/SRR0006_R1.fastq.gz
    /data/test/dummy_files/SRR0006_R2.fastq.gz
    /data/test/dummy_files/SRR0001_R1.fastq.gz
    /data/test/dummy_files/SRR0001_R2.fastq.gz
    /data/test/dummy_files/SRR0005_R1.fastq.gz
    /data/test/dummy_files/SRR0005_R2.fastq.gz

