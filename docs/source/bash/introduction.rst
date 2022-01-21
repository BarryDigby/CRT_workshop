Intro to Bash
=============

bashrc
######

A good place to start is your ``.bashrc`` file, which acts as a set of 'start up' instructions whenever you open your terminal. The ``.bashrc`` file is located in ``~/.bashrc`` i.e your home directory. You may never have noticed it because it is a hidden file (any file with a dot prefix is hidden). To show hidden files when running ``ls``, use ``ls -a``.

Commonly included items in a ``.bashrc`` file are:

#. ``Aliases``: custom short hand commands that are aliases for longer, tricky to remember commands.

#. ``Terminal colors``: not overly important.. 

#. ``$PATH variables``: a list of directories that are searched for executables. 

Aliases
-------

Below are a set of aliases I use frequently which may save you some time. Copy the contents of the code block below to your ``~/.bashrc`` file and save the file. To initiate the changes, open a new terminal or run ``source ~/.bashrc``.

.. code-block:: bash

    # bash alias
    alias l="ls -lhg --color=auto"
    alias ls='ls --color=auto'
    alias tarzip="tar -cvzf"
    alias tarunzip="tar -xvzf"
    alias vbrc="vi ~/.bashrc"
    alias sbrc="source ~/.bashrc"
    alias lugh="ssh bdigby@lugh.nuigalway.ie"


Inputrc
-------

A very handy trick is the ability to scroll through your history based on a partial string match to the command run. You will need to create two files: ``~/.inputrc`` and ``/etc/inputrc``.

``~/.inputrc`` : 

.. code-block:: bash

    #Page up/page down
    "\e[B": history-search-forward
    "\e[A": history-search-backward

    $include /etc/inputrc

``/etc/inputrc`` : 

.. code-block:: bash

    # /etc/inputrc - global inputrc for libreadline
    # See readline(3readline) and `info rluserman' for more information.

    # Be 8 bit clean.
    set input-meta on
    set output-meta on

    # To allow the use of 8bit-characters like the german umlauts, uncomment
    # the line below. However this makes the meta key not work as a meta key,
    # which is annoying to those which don't need to type in 8-bit characters.

    # set convert-meta off

    # try to enable the application keypad when it is called.  Some systems
    # need this to enable the arrow keys.
    # set enable-keypad on

    # see /usr/share/doc/bash/inputrc.arrows for other codes of arrow keys

    # do not bell on tab-completion
    # set bell-style none
    # set bell-style visible

    # some defaults / modifications for the emacs mode
    $if mode=emacs

    # allow the use of the Home/End keys
    "\e[1~": beginning-of-line
    "\e[4~": end-of-line

    # allow the use of the Delete/Insert keys
    "\e[3~": delete-char
    "\e[2~": quoted-insert

    # mappings for "page up" and "page down" to step to the beginning/end
    # of the history
    # "\e[5~": beginning-of-history
    # "\e[6~": end-of-history

    # alternate mappings for "page up" and "page down" to search the history
    # "\e[5~": history-search-backward
    # "\e[6~": history-search-forward

    # mappings for Ctrl-left-arrow and Ctrl-right-arrow for word moving
    "\e[1;5C": forward-word
    "\e[1;5D": backward-word
    "\e[5C": forward-word
    "\e[5D": backward-word
    "\e\e[C": forward-word
    "\e\e[D": backward-word

    $if term=rxvt
    "\e[7~": beginning-of-line
    "\e[8~": end-of-line
    "\eOc": forward-word
    "\eOd": backward-word
    $endif

    # for non RH/Debian xterm, can't hurt for RH/Debian xterm
    # "\eOH": beginning-of-line
    # "\eOF": end-of-line

    # for freebsd console
    # "\e[H": beginning-of-line
    # "\e[F": end-of-line

    $endif

Save the two files. Now add the following line to your ``~/.bashrc`` file: 

    #auto complete
    export INPUTRC=$HOME/.inputrc

Source your ``.bashrc`` file to initiate the changes. Test it out by cycling through your history with the arrow keys, and (for example) typing ``cd`` and then press the arrow keys to cycle thorugh all previous ``cd`` commands (as opposed to the most recent command). 

$PATH
#####

I will demonstrate the utility of the ``$PATH`` variable I showed you in the tutorial. 

Start by making a new directory and navigate to that directory: 

.. code-block:: bash

    mkdir -p ~/foo/bar/qux
    cd ~/foo/bar/qux

Create a file, we are going to pretend this is an executable like ``fastqc`` or ``bowtie2`` - the principle is the exact same. 

.. code-block:: bash

    touch executable && chmod 777 executable

In the ``~/foo/bar/qux`` directory, we are able to "run" ``executable`` by typing ``./executable``. You can type ``./exec`` and hit TAB to autocomplete the command. 

Navigate to your ``$HOME`` directory and "run" the executable by file. We need to provide either the relative or absolute path to the executable: 

.. code-block:: bash

    # relative path
    foo/bar/qux/executable

    # absolute path
    /home/barry/foo/bar/qux/executable

Add the ``/home/barry/foo/bar/qux/`` directory to the ``$PATH`` variable:

.. code-block:: bash 

    export PATH=$PATH:/home/barry/foo/bar/qux/

Now type ``execu`` and hit TAB to autocomplete the command. You should be able to access ``executable`` from anywhere on your system. To confirm this, type ``which executable`` to view where the executable is located.

To make this permanent, add ``export PATH=$PATH:/home/barry/foo/bar/qux/`` to your ``~/.bashrc`` file.

.. note::

    This will allow your system to see **all** files in `foo/bar/qux/` and all subdirectories. For the sake of the demonstration I have only used one file.

Variable Expansion
##################

When running a bioinformatics workflow, from a scripting perspective all we are doing is making sure that samples retain their correct names as they are passed to different file types (e.g ``fastq`` to ``bam``).

You will need to have a concept of ``basename`` and variable expansion such that you can name samples correctly in an automated manner when scripting. 

.. note::

    please use the fastq files from Assignment one here

.. code-block:: bash

#!/usr/bin/env bash

    # place path to fake fastq files here
    fastq_dir="/data/MA5112/week1/fastq"

    for file in ${fastq_dir}/*fastq.gz; do

        # get the sample name (remove extension)
        # we will need this for naming outputs
        sample_name=$( basename $file .fastq.gz )

        # print sample name
        echo "File name without extension: $sample_name"

        # we still have _1 and _2 in the name for read 1 and 2 which messes up naming.
        # remove them before continuing
        base_name=$(basename $sample_name | cut -d'_' -f1,2)

        #print base name with R1 R2 (1 , 2) stripped:
        echo "File name without Read identifier: $base_name"

        # What if the process needs both R1 and R2? (e.g alignment)
        R1=${base_name}_1.fastq.gz
        R2=${base_name}_2.fastq.gz

        # sanity check below to see if R1 and R2 VAR are set properly:
        echo "Staging sample: $base_name"
        echo "Beginning to count lines in files..."
        lines_R1=$(zcat $fastq_dir/$R1 | wc -l)
        lines_R2=$(zcat $fastq_dir/$R2 | wc -l)
        echo "Done!"
        echo "$lines_R1 lines in $R1 and $lines_R2 lines in $R2"

        # make script pause for a sec to see output
        sleep 5

    done


Take your time going through this script. Personally, I would 'comment out' each line inside the for loop (add a ``#`` at the beginning of the line) and then run the script, removing comments as you gain understanding. 
