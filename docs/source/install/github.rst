Github
======

During the practical we will be pushing commits from your local machine to Github. Please set up a SSH key linked to your Github account (so that you do not have to enter your username and password on every push):

Generating a new SSH key
------------------------

.. code-block:: bash

    $ ssh-keygen -t ed25519 -C "your_email@example.com"

.. note::

    If it asks you to overwrite an existing key under ``~/.ssh/id_XXXXXXX`` you might have previously set this up. Check your Github account to verfiy this (Settings > SSH and CPG keys)  

.. important::

    Do not enter a passphrase, leave empty and hit ENTER

Worked example:

.. code-block:: bash

    $ ssh-keygen -t ed25519 -C b.digby237@gmail.com
        Generating public/private ed25519 key pair.
        Enter file in which to save the key (/home/barry/.ssh/id_ed25519): 
        /home/barry/.ssh/id_ed25519 already exists.
        Overwrite (y/n)? y
        Enter passphrase (empty for no passphrase): 
        Enter same passphrase again: 
        Your identification has been saved in /home/barry/.ssh/id_ed25519
        Your public key has been saved in /home/barry/.ssh/id_ed25519.pub
        The key fingerprint is:
        SHA256:24A6oPDbveaBBO6qaLnIuoD4Whvc0l78EFfAGqx+vTU b.digby237@gmail.com
        The key's randomart image is:
        +--[ED25519 256]--+
        |     . ..        |
        |      o ..       |
        |  .  . o  .      |
        | . .. .. .       |
        |. o.. o.S        |
        |+=.=.+.o.+F      |
        |= O *.= .o..     |
        |=* B +.+.        |
        |%== oo+..        |
        +----[SHA256]-----+

Add SSH key to Github account
-----------------------------

.. code-block:: bash

    $ cat ~/.ssh/id_ed25519.pub

Copy the key in ``~/.ssh/id_ed25519.pub`` and add it to your account:

.. figure:: /_static/images/ssh-key.gif
   :figwidth: 700px
   :target: /_static/images/ssh-key.gif
   :align: center
