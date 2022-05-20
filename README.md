[title]: - "Run R scripts on OSG"

[TOC]

## Overview
This tutorial describes how to run R scripts on the OSG. We'll first run the program locally as a test.  After that we'll create a submit file, submit it to OSG using OSG Connect, and look at the results when the jobs finish.

## Run R scripts on OSG

### Access R on the submit host

First we'll need to create a working directory, you can either 

1. run `$ tutorial R` OR
1. type the following:
		$ mkdir tutorial-R; cd tutorial-R

R is run using containers on the OSG. To test it out on the submit node, we can run: 

	$ singularity shell \
       /cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-r:3.5.0

> ### Other Supported R Versions
> 
> To see a list of all Singularity containers containing R, look at the 
> list of [OSPool Supported Containers](https://support.opensciencegrid.org/support/solutions/articles/12000073449-view-existing-ospool-supported-containers)

The previous command sometimes takes a minute or so to start. Once it starts, you 
should see the following prompt: 

	$ Singularity osgvo-r:3.5.0:~> 

Now, we can try to run R:

	$ Singularity osgvo-r:3.5.0:~> R
	
	R version 3.5.1 (2018-07-02) -- "Feather Spray"
	Copyright (C) 2018 The R Foundation for Statistical Computing
	Platform: x86_64-pc-linux-gnu (64-bit)

	R is free software and comes with ABSOLUTELY NO WARRANTY.
	You are welcome to redistribute it under certain conditions.
	Type 'license()' or 'licence()' for distribution details.

	  Natural language support but running in an English locale

	R is a collaborative project with many contributors.
	Type 'contributors()' for more information and
	'citation()' on how to cite R or R packages in publications.

	Type 'demo()' for some demos, 'help()' for on-line help, or
	'help.start()' for an HTML browser interface to help.
	Type 'q()' to quit R.

	> 

You can quit out with `q()`. 

	> q()
	Save workspace image? [y/n/c]: n
	Singularity osgvo-r:3.5.0:~>

Great! R works. We'll leave the container running for the next step. See below 
on how to exit from the container. 

### Run R code

Now that we can run R, let's create a small script. Create the file `hello_world.R` that contains the following:

	print("Hello World!")

To run this script, we will use the `Rscript` command (equivalent to `R CMD BATCH`) which accepts the script as command line argument. This approach makes `R` much less verbose, and it's easier to parse the output later. The command in our script will look like this: 

	Singularity osgvo-r:3.5.0:~> Rscript hello_world.R

If this works, we'll exit the container for now with `exit`: 

	Singularity osgvo-r:3.5.0:~> exit
	$ 

### Build the HTCondor job

To prepare our R job to run on OSG, we need to create a wrapper for our R environment, based on the setup we did in previous sections. Create the file `R-wrapper.sh`:

	#!/bin/bash
	 
	# set TMPDIR variable
	mkdir rtmp
	export TMPDIR=$_CONDOR_SCRATCH_DIR/rtmp

	Rscript hello_world.R

Change the permissions on the wrapper script: 

	$ chmod +x R-wrapper.sh

Now that we've created a wrapper, let's build a HTCondor submit file around it. We'll call this one `R.submit`:

	universe = vanilla
	log = R.log.$(Cluster).$(Process)
	error = R.err.$(Cluster).$(Process)
	output = R.out.$(Cluster).$(Process)

	+SingularityImage = "/cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-r:3.5.0" 
	executable = R-wrapper.sh
	transfer_input_files = hello_world.R
	
	request_cpus = 1
	request_memory = 1GB
	request_disk = 1GB
	 
	queue 1

The path you put in the `+SingularityImage` option should match whatever you used 
to test R above. 

The `R.submit` file may have included a few lines that you are unfamiliar with.  For example, `$(Cluster)` and `$(Process)` are variables that will be replaced with the job's cluster and process id.  This is useful when you have many jobs submitted in the same file.  Any output and errors will be placed in a separate file for each job.

Also, did you see the `transfer_input_files` line?  This tells HTCondor what files to transfer with the job to the worker node.  You don't have to tell it to transfer the executable, HTCondor is smart enough to know that the job will need that.  But any extra files, such as our R script file, will need to be explicitly listed to be transferred with the job.  You can use transfer_input_files for input data to the job, as shown in [Transferring data with HTCondor](https://github.com/OSGConnect/tutorial-htcondor_transfer).

### Submit and analyze the output

Finally, submit the job to OSG Connect!

	$ condor_submit R.submit
	Submitting job(s)..........
	1 job(s) submitted to cluster 3796250.
	$ condor_q user
	 
	$ condor_q
	-- Schedd: login03.osgconnect.net : <192.170.227.22:9618?... @ 05/13/19 09:51:04
	OWNER      BATCH_NAME     SUBMITTED   DONE   RUN    IDLE  TOTAL JOB_IDS
	user	   ID: 3796250   5/13 09:50      _      _      1      1 3796250.0
	...

You can follow the status of your job cluster with the `connect watch` command, which shows `condor_q` output that refreshes each 5 seconds.  Press `control-C` to stop watching.

Since our jobs prints to standard out, we can check the output files. Let's see what one looks like:

	$ cat R.out.3796250.0
	[1] "Hello World!"

## Next Steps

 - [Use Custom Libraries with R](https://support.opensciencegrid.org/a/solutions/articles/5000674218)
 - [Scale Up your R jobs](https://support.opensciencegrid.org/support/solutions/articles/5000674219)

We recommend you read about how to steer your jobs with HTCondor job
requirements - this will allow you to select good resources for your
workload. Please see [this page](https://support.opensciencegrid.org/support/solutions/articles/5000633467-steer-your-jobs-with-htcondor-job-requirements)

## Getting Help

For assistance or questions, please email the OSG User Support team  at <mailto:support@opensciencegrid.org>.
