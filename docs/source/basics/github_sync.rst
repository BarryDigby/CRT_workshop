Github Syncing
==============

One of the coolest things about nextflow is that you can deploy scripts directly from Github - provided the repository is set up correctly.

Go to your local clone of your ``rtp_workshop`` repository:

#. Rename ``test.nf`` as ``main.nf``.

#. Update your ``nextflow.config`` file:

   .. code-block:: groovy

    process{
      container = 'barryd237/test:dev'
      containerOptions = '-B /data/'
    }

    params{
      input = "/data/test/test-dataset/fastq/*_{1,2}.fastq.gz"
    }

    singularity.enabled = true
    singularity.autoMounts = true
    singularity.cacheDir = '/data/containers'

Push the changes to Github:

.. code-block:: bash

    git add .
    git commit -m "Prepare repo for deployment"
    git push

The repository can now be deployed directly from GitHub:

.. code-block:: bash

    nextflow pull BarryDigby/rtp_workshop

    nextflow run -r dev BarryDigby/rtp_workshop

Pretty nifty.