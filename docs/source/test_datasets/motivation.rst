Motivation
==========

When developing a new project, one of the most common mistakes is to test the workflow on a full size dataset. This can be extremely time consuming and burns through uneccessary computational resources.

It is imperative you get your code working in local dev environments before deploying to the cloud/HPC.

There are two ways to overcome this:

1. Use ``dummy files`` to instantly check your channels and processes contain the correct file names and structure.

2. Use a minimal ``test dataset`` to confirm the outputs behave as expected (e.g correct BAM headers).

Dummy files
-----------

Dummy files are empty files that contain file extensions we can test within the script. 

Personally, when testing out a new operator, I use dummy files to check that I am using the operator correctly. 

To do:
######

Create a set of dummy ``fastq`` files in a directory called ``dummy_files``:

.. code-block:: bash

    mkdir dummy_files
    touch dummy_files/SRR000{1..9}_R{1,2}.fastq.gz

The directory should now contain 9 paired end fastq files:

.. code-block:: bash

    $ l dummy_files
    total 0
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0001_R1.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0001_R2.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0002_R1.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0002_R2.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0003_R1.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0003_R2.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0004_R1.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0004_R2.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0005_R1.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0005_R2.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0006_R1.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0006_R2.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0007_R1.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0007_R2.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0008_R1.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0008_R2.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0009_R1.fastq.gz
    -rw-rw-r-- 1 barry 0 Nov 22 09:02 SRR0009_R2.fastq.gz

Next, create a nextflow script that does the following:

1. Read in the dummy files using ``fromFilePairs()``.

2. Splits the reads into two separate channels ``forward_reads`` and ``reverse_reads``. (Hint: use ``.map()``). 

3. Use a process to use the forward and reverse reads in a process (Hint: use ``echo`` in the script body). 

4. Bonus: re-combine the forward and reverse reads in the process body. 

.. note::

    At each step, use ``view()`` as a sanity check. Don't forget to add the line ``echo true`` in your process to print the output to sdtout

Test Datasets
-------------

``nf-core`` have a repository containing minimal test-datasets for their workflows, available here: `nf-core/test-datasets <https://github.com/nf-core/test-datasets>`_. The repository is 5GB in size. 

.. note::

    Each workflows test dataset are in their respective branch.

To download the datasets, clone the repository locally and checkout the branch (workflow) of interest:

.. code-block:: bash

    $ git clone git@github.com:nf-core/test-datasets.git

    $ cd test-datasets/

    $ git checkout circrna

You should be able to view the test-dataset files I generated for my circrna workflow.

.. note::

    If you want to create your own test-dataset, remember that the file sizes must be <20Mb. 