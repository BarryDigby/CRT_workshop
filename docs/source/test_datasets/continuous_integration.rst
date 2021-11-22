Continuous Integration
======================

Github actions can perform a test run of your workflow using the minimal test-dataset. Just like the Dockerhub continuous integration, the actions are performed upon each push to the ``dev`` branch. 

In order to set this up, we will need to specify both a ``test`` configuration profile and a ``ci.yml`` workflow file. 

Test profile
------------

The test configuration profile contains a series of input parameters that will be used as inputs to the workflow for the test run. These parameters point to the URL of the test-dataset hosted on GitHub. 

I have created test profiles for both RNA-Seq reads and Variant Calling reads:

