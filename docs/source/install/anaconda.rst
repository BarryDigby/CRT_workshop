Anaconda
========

Please follow the installation steps below to install the latest version of ``Anaconda`` on your local machine:

Install dependencies
--------------------

.. code-block:: bash

    sudo apt-get install libgl1-mesa-glx \
        libegl1-mesa \
        libxrandr2 \
        libxss1 \
        libxcursor1 \
        libxcomposite1 \
        libasound2 \
        libxi6 \
        libxtst6

Download Installer
------------------

.. code-block:: bash

    $ wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh

Install Anaconda
----------------

.. code-block:: bash

    $ bash Anaconda3-2021.05-Linux-x86_64.sh

.. note::

    Follow the instructions in the terminal regarding your $PATH, default suggestions are fine.

Verify Installation
-------------------

.. code-block:: bash

    $ conda -v
