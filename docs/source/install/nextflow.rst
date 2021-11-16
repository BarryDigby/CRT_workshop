Nextflow
========

Please follow the installation steps below to install the latest version of ``nextflow`` on your local machine:

.. warning::

    Java 8+ must be installed on your laptop. If your version of ``openjdk`` is below 8, please run the code block below.



.. code-block:: bash

    $ sudo apt update \
        sudo apt install default-jre \
        java -version

Download nextflow binary file
-----------------------------

.. code-block:: bash

    $ wget -qO- https://get.nextflow.io | bash

Add to $PATH
------------

.. code-block:: 

    $ chmod +x nextflow \
        sudo mv nextflow ~/bin/

Verify Installation
-------------------

.. code-block:: bash

    $ nextflow -v