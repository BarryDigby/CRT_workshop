Conditionals
============

Nextflow uses conditionals as a 'flow control' mechanism to skip process blocks or operations. The most obvious example is when re-running an alignment workflow where we have already created or downloaded the index file. We don't want to keep re-running the labor intensive indexing process. 

There are some `strict rules <https://github.com/nf-core/tools/issues/992>`_ regarding the use of conditionals: 

- Boolean parameters should be set to ``true/false`` in ``nextflow.config``.

- File Paths / Strings / Integers / Floats / Lists / Maps should be set to ``null`` in ``nextflow.config``.

Nextflow also makes heavy use of ``ternary operators``. The code line ``A ? B : C`` reads if A is true, choose B, else C. 

.. note::

    We will continue with our ``RNA-Seq`` workflow example in this section. 

Let's flesh out our ``nextflow.config``:

.. code-block:: groovy

    process{
      container = "barryd237/test:dev"
      containerOptions = ' -B /data/'
    }

    params{
      input = "/data/test/test-datasets/fastq/*_{1,2}.fastq.gz"
      fasta = "/data/test/test-datasets/reference/chrI.fa"
      gtf   = "/data/test/test-datasets/reference/chrI.gtf"
      transcriptome = null
      outdir = "/data/test/"
      save_qc_intermediates = true
      save_transcriptome = true
      run_qc = true
    }

    singularity.enabled = true
    singularity.autoMounts = true
    singularity.cacheDir = "/data/containers"

Update .gitignore
-----------------

Update your ``.gitignore`` file so you don't upload the directories output by our script. As of writing the documentation, this is what mine looks like:

.. code-block:: bash

    *.img
    test-datasets/
    work/
    .nextflow.*
    .nextflow/
    dummy_files/
    fastqc/
    multiqc/ 

Update Script
-------------

Overwrite the contents of ``main.nf`` with the following, and push to GitHub:

.. code-block:: groovy

    #!/usr/bin/env nextflow

    Channel.fromFilePairs("${params.input}", checkIfExists: true)
           .into{ ch_qc_reads; ch_alignment_reads }

    ch_fasta = Channel.value(file(params.fasta))
    ch_gtf = Channel.value(file(params.gtf))

    process FASTQC{
        tag "${base}"
        publishDir params.outdir, mode: 'copy',
            saveAs: { params.save_qc_intermediates ? "fastqc/${it}" : null }

        when:
        params.run_qc

        input:
        tuple val(base), file(reads) from ch_qc_reads

        output:
        tuple val(base), file("*.{html,zip}") into ch_multiqc

        script:
        """
        fastqc -q $reads
        """
    }

    process MULTIQC{
        publishDir "${params.outdir}/multiqc", mode: 'copy'

        when:
        params.run_qc

        input:
        file(htmls) from ch_multiqc.collect()

        output:
        file("multiqc_report.html") into multiqc_out

        script:
        """
        multiqc .
        """
    }

    process TX{
        publishDir params.outdir, mode: 'copy',
            saveAs: { params.save_transcriptome ? "reference/transcriptome/${it}" : null }

        when:
        !params.transcriptome && params.fasta

        input:
        file(fasta) from ch_fasta
        file(gtf) from ch_gtf

        output:
        file("${fasta.baseName}.tx.fa") into transcriptome_created

        script:
        """
        gffread -F -w "${fasta.baseName}.tx.fa" -g $fasta $gtf
        """
    }

    ch_transcriptome = params.transcriptome ? Channel.value(file(params.transcriptome)) : transcriptome_created


Push to changes to github and run the workflow:

.. code-block:: bash
            
        git add .

        git commit -m "Update repo"
        
        git push
        
        nextflow pull <username>/rtp_workshop
        
        nextflow run -r dev <username>/rtp_workshop
        
        nextflow run main.nf -profile docker -c nextflow.config

.. note::

    For those curious, workflows are staged under ``~/.nextflow/assets/<github-username>/``

cool.

Go to Assignment II Part 3 :) 