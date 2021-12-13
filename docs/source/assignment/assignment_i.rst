Assignment II
=============

Part 1
------

You will need to add the process ``MULTIQC`` to the ``test.nf`` script.

Before proceeding, please update your ``.gitignore`` file: 

.. code-block:: bash

    *.img
    work/
    test-datasets/
    work/
    .nextflow.*
    .nextflow/
    fastqc/

Update container
################

Update your ``environment.yml`` file to include ``multiqc``. Push the change to Github to trigger the ``Dockerhub`` build. You will need to delete your local ``test.img`` and download the updated version containing ``multiqc``. 

Update parameters, test.nf
##########################

``MultiQC`` expects the output from  ``FastQC`` for **all samples**. As such, use the line ``file(htmls) from ch_multiqc.collect()`` for the input directive to stage every file from the output channel ``ch_multiqc`` from the process ``FASTQC`` in our new process ``MULTIQC``. 

There is no need to specify ``tuple val(base)`` in the input/output directive. Why? I have responded to a post explaining this, available here: `https://www.biostars.org/p/495108/#495150 <https://www.biostars.org/p/495108/#495150>`_

In addition, add the parameter ``outdir`` to the ``nextflow.config`` file - this is the directory we will write results to. Nextflow uses variable expansion just like bash i.e: ``"${params.outdir}/fastqc"``.

.. hint::

    The output of ``multiqc`` is a html file, use the appropriate wildcard glob pattern in the output directive.


When completed, proceed to the section ``Github Syncing``.

.. warning::

    Add the folder your multiqc results are in to the ``.gitignore`` file.

Part 2
------

Test your knowledge of the operators we covered. 

Map
###

Create a set of dummy ``fastq`` files in a directory called ``dummy_files``:

.. warning::

    Update your ``.gitignore`` file now to include ``dummy_files/``.

.. code-block:: bash

    mkdir dummy_files
    touch dummy_files/SRR000{1..9}_R{1,2}.fastq.gz

The directory should now contain 9 dummy paired end fastq files:

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

Create a nextflow script that does the following:

1. Read in the dummy files using ``fromFilePairs()``.

2. Place the reads into 2 channels ``ch_fwd`` and ``ch_rev`` using ``into{a;b}`` instead of ``.set{}``.

3. Splits the reads into two new channels ``forward_reads`` and ``reverse_reads`` using ``map``.

4. Use as inputs to a process the forward or reverse read channels and echo their contents in the script body (Hint: use ``echo true`` at the top of the process).

.. hint::

    Before proceeding to the next step, append the ``.view()`` operator to double check that the channels hold the correct values.

Join
####

In the ``map`` script you created above, use the ``join`` operator to join the forward and reverse reads into a single channel in the input directive of the process where you ``echo`` the reads. 

In essence, I want you to stage both forward and reverse reads in the process and ``echo`` them.

You can use ``join`` outside of, or inside the process - the choice is up to you. 

Part 3
------

Update your ``main.nf`` script to include:

Transcriptome indexing
######################

#. Create a process that creates an index file using the transcriptome fasta file.

   #. Name the process ``INDEX``. 

   #. Include 2 boolean parameters ``kallisto_index`` and ``save_index`` in your ``nextflow.config`` file and script. Use these in a similar fashion to ``transcriptome`` and ``save_transcriptome`` parameters. 

   #. Include a suitable ternary operator after the ``INDEX`` process to accept pre-built index files when supplied to the workflow.

Kallisto quantification
#######################

#. Create a process that performs kallisto quantification using the index file and sequencing reads.

   #. Name the process ``KALLISTO_QUANT``. 

   #. Use the reads staged in ``ch_alignment_reads`` as input to the process - the ``ch_qc_reads`` channel has already been consumed.

|

Refer to the `Kallisto documentation <https://pachterlab.github.io/kallisto/manual>`_ and inspect the ``kalisto index`` and ``kallisto quant`` commands. 

Before designing a nextflow workflow, you need to be familiar with the expected outputs generated by the process script body. Shell into your container to run the quantification analysis in bash before implementing the process in nextflow. 

