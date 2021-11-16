Singularity
===========

Why use both ``Docker`` and ``Singularity``? 

``Singularity`` can be thought of as the bona fide 'open source' container platform, and offers some advantages over ``Docker``:

* ``Singularity`` does not require sudo privelages. This means we can run ``Singularity`` on HPC/cloud platforms. 

* ``Singularity`` is compatible with ``Docker`` i.e we can pull images from ``Dockerhub`` using ``Singularity``.

The main reason we are using ``Docker`` is that it is compatitble with Github actions (CI testing).

Singularity pull
----------------

On your local machine, pull the docker image we created in the previous step: 

.. code-block:: bash

    $ singularity pull --name test.img docker://USERNAME/test

The container `test.img` should be present in your directory. Shell into the container:

.. code-block:: bash

    $ singularity shell -B $(pwd) test.img

.. note::

    The ``-B`` flag indicates the bind path for the container. Your container will not be able to access files above ``$(pwd)`` in the directory tree.

Confirm the installation path of ``fastqc`` within the container:

.. code-block:: bash

    $ whereis fastqc
