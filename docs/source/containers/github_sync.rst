Github Syncing
==============

Now that we have created a container for our project, we will use ``Github Actions`` to set up automated ``Docker build`` and ``Docker push`` triggers. 

Initialise Repository
---------------------

Create a repository on Github called ``rtp_workshop``. Initialise it with a README.md file. Note how the default branch is called ``main``.

On your laptop, move to the directory where you have created the ``Dockerfile``, ``environment.yml`` file and the container ``test.img``.

.. warning::

    The maximum file size permitted on Github is 20Mb. We will create a ``.gitignore`` file to tell github to ignore the container when pushing to Github.

Create the following ``.gitignore`` file in the directory: 

.. code-block:: bash

    *.img

.. note::

    Please make sure you have the latest version of ``git`` installed.

Create a ``remote`` connection (``origin``) pointing to our Github repository ``rtp_workshop``:

.. code-block:: bash

    $ git init # automatically checks out as master branch

    $ git remote add origin git@github.com:BarryDigby/rtp_workshop.git

    $ git pull origin main # pull README.md

    $ git add . # stage local files

    $ git commit -m "push to master"

    $ git push --set-upstream origin master

We have now created a branch ``master`` that contains all of our local files, and the original README.md file used to initialise the repository. If you want to run a sanity check, run ``git branch -a`` - you will see that we are on the local ``master`` branch, and there are two remotes - ``main`` and ``master`` (on Github). 

Now create a ``dev`` branch, and make it even with ``master``:

.. code-block:: bash

    $ git checkout -b dev # create dev branch 

    $ git pull origin master # make even with master

    $ git push --set-upstream origin dev # create dev branch on Github

    $ git branch -a

Great! We have both ``master`` and ``dev`` locally and on Github. Now I want to delete the ``main`` branch (this caused a world of pain when Github decided to stop using the term ``master``).

Do this via Github:

- In the ``rtp_workshop`` repository, click on the branch icon.

- Change the default branch to ``dev``. 

- Delete the branch ``main``.

We must update these changes in our remote. Go to the directory containing the repository:

.. code-block:: bash

    $ git checkout dev # go to dev if not already there

    $ git remote prune origin # update local to reflect changes we made on Gtihub

    $ git branch -a # sanity check. 

Docker Workflow 
---------------

Now that we have set up our github branches correctly, let's add a trigger: every time we push to ``dev``, the Docker container is built and pushed to Dockerhub.

Locally, using VSCode or the command line, create the file ``.github/workflows/push_dockerhub_dev.yml``:

.. code-block:: yaml

    name: RTP Docker push (dev)
    # This builds the docker image and pushes it to DockerHub
    # Runs on push events to 'dev', including PRs.
    on:
      push:
        branches:
          - dev

    jobs:
      push_dockerhub:
        name: Push new Docker image to Docker Hub (dev)
        runs-on: ubuntu-latest
        # Only run for your repo
        if: ${{ github.repository == 'BarryDigby/rtp_workshop' }}
        env:
          DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
          DOCKERHUB_PASS: ${{ secrets.DOCKERHUB_PASS }}
        steps:
          - name: Check out pipeline code
            uses: actions/checkout@v2

          - name: Build new docker image
            run: docker build --no-cache . -t barryd237/test:dev

          - name: Push Docker image to DockerHub (dev)
            run: |
              echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
              docker push barryd237/test:dev

.. note::

    Please substitute ``BarryDigby`` with your Github username, and ``barryd237`` with your Dockerhub username.

Github Secrets
--------------

Those of you with a keen eye will have noticed two environment variables in the ``push_dockerhub_dev.yml`` file: ``DOCKERHUB_USERNAME`` and ``DOCKERHUB_PASS``, no prizes for guessing what these stand for. 

To set up Github secrets, navigate to your GitHub repository and click Settings > Secrets > New secret. Please add both secrets, your username and password. 

Your ``dev`` branch should now be set up to automatically push to Dockerhub.