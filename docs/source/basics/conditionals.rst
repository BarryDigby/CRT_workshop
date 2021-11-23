Conditionals
============

Nextflow uses conditionals as a 'flow control' mechanism to skip process blocks or operations. The most obvious example is when re-running an alignment workflow where we have already created or downloaded the index file. We don't want to keep re-running the labor intensive indexing process. 

There are some `strict rules <https://github.com/nf-core/tools/issues/992>`_ regarding the use of conditionals: 

- Boolean parameters should be set to ``true/false`` in ``nextflow.config``.

- File Paths / Strings / Integers / Floats / Lists / Maps should be set to ``null`` in ``nextflow.config``.

Nextflow also makes heavy use of ``ternary operators``. The code line ``A ? B : C`` reads if A is true, choose B, else C. 

Let's flesh out our ``nextflow.config``:

.. code-block:: bash

    process{
      container = "barryd237/test:dev"
      containerOptions = ' -B /data/'
    }

    params{
      input = "/data/test/test-datasets/fastq/*_{1,2}.fastq.gz"
      fasta = "/data/test/test-datasets/reference/chrI.fa"
      kallisto_index = null
      outdir = "/data/test/"
      save_qc_intermediates = true
      save_index = true
      run_qc = true
    }

    singularity.enabled = true
    singularity.autoMounts = true
    singularity.cacheDir = "/data/containers"

Update container
----------------

Add ``kallisto`` to your ``environment.yml`` file and push to GitHub.

Update your ``.gitignore`` file so you don't upload irrelevant files. As of writing the documentation, this is what mine looks like:

.. code-block:: bash

    *.img
    test-datasets/
    work/
    .nextflow.*
    .nextflow/
    dummy_files/
    fastqc/
    multiqc/

Check that the automated build worked on Github. 

You can delete the container locally, going forward we will pull directly from ``Dockerhub`` as specified in the ``nextflow.config``. 

Update Script
-------------

Overwrite the contents of ``main.nf`` with the following, and push to GitHub:

.. code-block:: bash

    #!/usr/bin/env nextflow

    Channel.fromFilePairs("${params.input}", checkIfExists: true)
        .set{ ch_reads }

    ch_fasta = Channel.value(file(params.fasta))

    process FASTQC{
        tag "${base}"
        publishDir params.outdir, mode: 'copy',
            saveAs: { params.save_qc_intermediates ? "fastqc/${it}" : null }

        when:
        params.run_qc

        input:
        tuple val(base), file(reads) from ch_reads

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

    process INDEX{
        publishDir params.outdir, mode: 'copy',
            saveAs: { params.save_index ? "reference/index/${it}" : null }

        when:
        !params.kallisto_index && params.fasta

        input:
        file(fasta) from ch_fasta

        output:
        file("*.idx") into index_created

        script:
        """
        kallisto index -i ${fasta.baseName}.idx $fasta
        """
    }

    ch_index = params.kallisto_index ? Channel.value(file(params.kallisto_index)) : index_created

    ch_index.view()

Just like before, once the changes have been pushed to GitHub, use ``nextflow pull <username>/rtp_workshop`` to stage the changes locally. 

Run the workflow using ``nextflow run -r dev <username>/rtp_workshop``.

nice.