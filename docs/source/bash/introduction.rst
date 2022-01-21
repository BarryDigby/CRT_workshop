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

A very handy trick is the ability to scroll through your history based on a partial string match to a command previously run. You will need to create the file: ``~/.inputrc``:

``~/.inputrc`` : 

.. code-block:: bash

    #Page up/page down
    "\e[B": history-search-forward
    "\e[A": history-search-backward

    $include /etc/inputrc

Now add the following line to your ``~/.bashrc`` file: 

.. code-block:: bash

    #auto complete
    export INPUTRC=$HOME/.inputrc

Source both files to initiate the changes:

.. code-block:: console

    source ~/.bashrc
    bind -f ~/.inputrc

Test it out by cycling through your history with the arrow keys, and (for example) typing ``cd`` and then press the arrow keys to cycle thorugh all previous ``cd`` commands (as opposed to the most recent command). 

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

        # place path to fastq files here (substitute your own)
        fastq_dir="/data/MA5112/week1/fastq"
        
        # we are reading R1 and R2 at once here (*{1,2}).
        for file in ${fastq_dir}/*{1,2}.fastq.gz; do

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

            printf "\n\n"

            # make script pause for a sec to see output
            sleep 5

        done


Take your time going through this script. Personally, I would 'comment out' each line inside the for loop (add a ``#`` at the beginning of the line) and then run the script, removing comments as you gain understanding. 

To run the script, type ``bash <scriptname>.sh`` in your terminal.