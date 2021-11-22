Github Syncing
==============

One of the coolest things about nextflow is that you can deploy scripts directly from Github - provided the repository is set up correctly.

Working from the same directory where you completed the exercise, rename your nextflow script as ``main.nf`` and tidy up the directory:

- Delete the scratch ``work/`` directory. 

- Delete the hidden nextflow log files and directory.

- Delete the output directories from our exercise 

- In the ``.gitignore`` file, add ``test-datasets/`` - we don't want to upload the raw reads to GitHub.

.. code-block:: bash

    $ git add . 

    $ git commit -m "push main.nf"

    $ git push

The repository can now be deployed directly from GitHub:

.. code-block:: bash

    $ nextflow pull BarryDigby/rtp_workshop

    $ nextflow run -r dev BarryDigby/rtp_workshop -with-singularity 'test.img'

Pretty nifty.