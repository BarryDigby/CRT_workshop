Continuous Integration
======================

Github actions can perform a test run of your workflow using the minimal test-dataset. Just like the Dockerhub continuous integration, the actions are performed upon each push to the ``dev`` branch. 

In order to set this up, we will need to specify both a ``test`` configuration profile and a ``ci.yml`` workflow file. 

Test profile
------------

The test configuration profile contains a series of input parameters that will be used as inputs to the workflow for the test run. These parameters point to the URL of the test-dataset hosted on GitHub. 

Unfortunately, wildcard glob patterns are not supported via ``html`` links, so the following is not valid:

.. code-block:: bash 

    params{
      input = "https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/*_{1,2}.fastq.gz"
    }

Here is a valid ``test.config`` file for our simulated RNA-Seq dataset we have been working with:

.. code-block:: bash

    params {
        config_profile_name = 'Test profile'
        config_profile_description = 'Test dataset to check pipeline function'

        // Limit resources so that this can run on GitHub Actions
        max_cpus = 2
        max_memory = 6.GB
        max_time = 48.h

        // Input data for test data
        input = 'https://raw.githubusercontent.com/nf-core/test-datasets/circrna/samples.csv'
        fasta = 'https://raw.githubusercontent.com/nf-core/test-datasets/circrna/reference/chrI.fa'
        gtf = 'https://raw.githubusercontent.com/nf-core/test-datasets/circrna/reference/chrI.gtf'
        outdir = 'test_outdir/'
    }

Save the file to ``conf/test.config`` in your repository. 

Sample File
-----------

To overcome the html glob limitation, we need to construct an input samples file. 

See below for a valid example of a ``samples.csv`` file, specifying the links to each fastq file:

.. code-block:: bash

    Sample_ID,Read1,Read2
    cel_N2_1,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/N2_rep1_1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/N2_rep1_2.fastq.gz
    cel_N2_2,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/N2_rep2_1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/N2_rep2_2.fastq.gz
    cel_N2_3,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/N2_rep3_1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/N2_rep3_2.fastq.gz
    fust1_1,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/fust1_rep1_1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/fust1_rep1_2.fastq.gz
    fust1_2,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/fust1_rep2_1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/fust1_rep2_2.fastq.gz
    fust1_3,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/fust1_rep3_1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/circrna/fastq/fust1_rep3_2.fastq.gz

Instead of supplying the path to sequencing reads as ``params.input``, we can provide the ``samples.csv`` file. Save this in your directory to test it out.

We will need to use custom functions to read in the file and stage them as inputs for our workflow. 

See the nextflow script below. Save it and run ``nextflow run <script_name>.nf --input 'samples.csv'``

.. note::

    We are testing this locally, so we are not deploying from Github. If you are not in the directory containing the ``nextflow.config`` file, specify it's path with the ``-c`` argument.

.. code-block:: bash 

    #!/usr/bin/env nextflow

    // parse input data
    if(has_extension(params.input, ".csv")){
    
       csv_file = file(params.input, checkIfExists: true)
       ch_input = extract_data(csv_file)

    }else{

       exit 1, "error: The sample input file must have the extension '.csv'."

    }

    // stage input data
    ( ch_qc_reads, ch_raw_reads) = ch_input.into(2)

    ch_raw_reads.view()

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

    /*
    ================================================================================
                                AUXILLARY FUNCTIONS
    ================================================================================
    */

    // Check if a row has the expected number of item
    def checkNumberOfItem(row, number) {
        if (row.size() != number) exit 1, "error:  Invalid CSV input - malformed row (e.g. missing column) in ${row}, consult documentation."
        return true
    }

    // Return file if it exists
    def return_file(it) {
        if (!file(it).exists()) exit 1, "error: Cannot find supplied FASTQ input file. Check file: ${it}"
        return file(it)
    }

    // Check file extension
    def has_extension(it, extension) {
        it.toString().toLowerCase().endsWith(extension.toLowerCase())
    }

    // Parse samples.csv file
    def extract_data(csvFile){
        Channel
            .fromPath(csvFile)
            .splitCsv(header: true, sep: ',')
            .map{ row ->

            def expected_keys = ["Sample_ID", "Read1", "Read2"]
            if(!row.keySet().containsAll(expected_keys)) exit 1, "error: Invalid CSV input - malformed column names. Please use the column names 'Sample_ID', 'Read1', 'Read2'."

            checkNumberOfItem(row, 3)

            def samples = row.Sample_ID
            def read1 = row.Read1.matches('NA') ? 'NA' : return_file(row.Read1)
            def read2 = row.Read2.matches('NA') ? 'NA' : return_file(row.Read2)

            if( samples == '' || read1 == '' || read2 == '' ) exit 1, "error: a field does not contain any information. Please check your CSV file"
            if( !has_extension(read1, "fastq.gz") && !has_extension(read1, "fq.gz") && !has_extension(read1, "fastq") && !has_extension(read1, "fq")) exit 1, "error: A R1 file has a non-recognizable FASTQ extension. Check: ${r1}"
            if( !has_extension(read2, "fastq.gz") && !has_extension(read2, "fq.gz") && !has_extension(read2, "fastq") && !has_extension(read2, "fq")) exit 1, "error: A R2 file has a non-recognizable FASTQ extension. Check: ${r2}"

            // output tuple mimicking fromFilePairs
            [ samples, [read1, read2] ]

            }
    }

.. note::

    nextflow will only download the files once they are passed to a process. Hence the use of the ``FASTQC`` process above as a proof of concept.

.. note::

    note to self: integrate these functions to main.nf before proceeding.

CI.yml
------

All that is left is to set up the Github actions file and integrate two profiles, ``test`` and ``docker``. 

Create the following file in your directory: ``.github/workflows/ci.yml``:

.. warning::

    I cannot stress how important indentation is with .yml files.

.. code-block:: bash

    name: nf-core CI
    # This workflow runs the pipeline with the minimal test dataset to check that it completes without any syntax errors
    on:
    push:
        branches:
        - dev
    pull_request:
    release:
        types: [published]

    jobs:
    test:
        name: Run workflow tests
        # Only run on push if this is the nf-core dev branch (merged PRs)
        if: ${{ github.event_name != 'push' || (github.event_name == 'push' && github.repository == 'BarryDigby/rtp_workshop') }}
        runs-on: ubuntu-latest
        env:
        NXF_VER: ${{ matrix.nxf_ver }}
        NXF_ANSI_LOG: false
        strategy:
        matrix:
            # Nextflow versions: specify nextflow version to use
            nxf_ver: ['21.04.0', '']
        steps:
        - name: Check out pipeline code
            uses: actions/checkout@v2.4.0

        - name: Check if Dockerfile or Conda environment changed
            uses: technote-space/get-diff-action@v4
            with:
            FILES: |
                Dockerfile
                environment.yml
        - name: Build new docker image
            if: env.MATCHED_FILES
            run: docker build --no-cache . -t barryd237/test:dev

        - name: Pull docker image
            if: ${{ !env.MATCHED_FILES }}
            run: |
            docker pull barryd237/test:dev
            docker tag barryd237/test:dev barryd237/test:dev
        - name: Install Nextflow
            env:
            CAPSULE_LOG: none
            run: |
            wget https://github.com/nextflow-io/nextflow/releases/download/v21.04.1/nextflow
            sudo chmod 777 ./nextflow
            sudo mv nextflow /usr/local/bin/
        - name: Run pipeline with test data
            run: |
            nextflow run ${GITHUB_WORKSPACE} -profile test,docker

In your ``nexflow.config`` file, add the following:

.. code-block:: bash

    profiles {
        docker {
            docker.enabled = true
            singularity.enabled = false
            podman.enabled = false
            shifter.enabled = false
            charliecloud.enabled = false
            docker.runOptions = '-u \$(id -u):\$(id -g)'
        }
        test { includeConfig 'conf/test.config' }
    }

Add, commit and push the changes and cross your fingers.. 