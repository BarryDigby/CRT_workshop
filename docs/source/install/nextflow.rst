Nextflow
========

Please follow the installation steps below to install ``nextflow`` on your local machine:

.. warning::

    Java 8+ must be installed on your laptop. If your version of ``openjdk`` is below 8, please run the code block below.

.. code-block:: bash

    $ sudo apt update \
        sudo apt install default-jre \
        java -version

Download nextflow binary file
-----------------------------

.. note::

    The documentation is based on nextflow v21.04.1. Using a newer version might cause conflicts. 

.. code-block:: bash

    $ wget https://github.com/nextflow-io/nextflow/releases/download/v21.04.1/nextflow

    $ chmod 777 ./nextflow

    $ mv ./nextflow /usr/local/bin/

    $ nextflow -v