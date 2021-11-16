Docker
======

Please follow the installation steps below to install the latest version of ``Docker`` on your local machine:

Install dependencies
--------------------

.. code-block:: bash

    $ sudo apt-get update

    $ sudo apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

Install Docker GPG Key
----------------------

.. code-block:: bash

    $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

Install from Repository
-----------------------

.. code-block:: bash

    $ echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

Verify Installation
-------------------

.. code-block:: bash

    $ docker -v

Dockerhub
---------

Please set up an account on Dockerhub.

.. note:: 

    I highly recommend using the same username as your Github account.