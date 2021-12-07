Nextflow on Windows 10
======================

Please follow the steps outlined in the following tutorial: `Setting up a Nextflow environment on Windows 10 <https://www.nextflow.io/blog/2021/setup-nextflow-on-windows.html>`_.

1. Powershell

2. WSL2

3. Windows terminal

4. Docker

5. VS Code (optional)

6. Nextflow

7. Git

Please make sure that you install ``nextflow v21.04.1``. When following the tutorial, substitute the following during the ``nextflow`` installation:

.. code-block:: bash

    $ wget https://github.com/nextflow-io/nextflow/releases/download/v21.04.1/nextflow

    $ chmod 777 ./nextflow

    $ mv ./nextflow /usr/local/bin/

    $ nextflow -v

.. note::

    If the path ``/usr/local/bin`` does not exist, move the executable to ``/usr/bin/`` instead.

Installing Singularity
----------------------

The above tutorial does not cover ``singularity`` installations. Please follow this tutorial to install ``singularity``: `using singularity on windows with WSL2<https://www.blopig.com/blog/2021/09/using-singularity-on-windows-with-wsl2/>`_.

When you reach the step to download the tarball from GitHub, use the same version as ubuntu users for the workshop:

.. code-block:: bash

    $ export VERSION=3.8.4 && \
    wget https://github.com/apptainer/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
    tar -xzf singularity-${VERSION}.tar.gz && \
    cd singularity-${VERSION}



Windows users in the class - please help each other during the installation steps. I do not have a Windows partition on my laptop and cannot troubleshoot any issues you may encounter. 