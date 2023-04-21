---
ospool:
    path: software_examples/r/tutorial-R/README.md
---

# Run R scripts on the OSPool

This tutorial describes how to run a simple R script on the OSPool. We'll first run the program locally as a test.  After that we'll create a submit file, submit it to the OSPool using an OSPool Access Point, and look at the results when the jobs finish.

## Set Up Directory and R Script

First we'll need to create a working directory with our materials. You can either 

1. run `$ git clone https://github.com/OSGConnect/tutorial-R` to download the materials, OR create them yourself by
1. typing the following:
		$ mkdir tutorial-R; cd tutorial-R

Let's create a small script to use as a test example. Create the file `hello_world.R` using a text editor like nano or vim that contains the following:

	#!/usr/bin/env Rscript
	
	print("Hello World!")

The header `#!/usr/bin/env Rscript` indicates that if this script is run on its 
own, it needs to be executed using the R language (instead of Python, or bash, for example). 

We will run one more command that makes the script *executable*, meaning that it 
can be run directly from the command line: 

	$ chmod +x hello_world.R

## Access R on the Access Point

R is run using containers on the OSPool. To test it out on the Access Point, we can run: 

	$ apptainer shell \
       /cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-r:3.5.0

> ### Other Supported R Versions
> 
> To see a list of all containers containing R, look at the 
> list of [OSPool Supported Containers]()

The previous command sometimes takes a minute or so to start. Once it starts, you 
should see the following prompt: 

	Singularity :~>  

Now, we can try to run R by typing `R` in our terminal: 

	$ Singularity :~>  R
	
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

## Test an R Script

To run the R script we created [earlier](#set-up-directory-and-r-script), we just need to execute it like so: 

	Singularity :~> ./hello_world.R

If this works, we will have `[1] "Hello World!"` printed to our terminal. Once we have this output, we'll exit the container for now with `exit`: 

	Singularity :~>  exit
	$ 

## Build the HTCondor Job

Let's build a HTCondor submit file to run our script. Using a text editor, create a file called `R.submit` with the following text inside it:

	+SingularityImage = "/cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-r:3.5.0"
	executable		  = hello_world.R
	# arguments

	log    = R.log.$(Cluster).$(Process)
	error  = R.err.$(Cluster).$(Process)
	output = output = R.out.$(Cluster).$(Process)

	+JobDurationCategory = “Medium”

	request_cpus   = 1
	request_memory = 1GB
	request_disk   = 1GB

	queue 1

The path you put in the `+SingularityImage` option should match whatever you used 
to test R above. We list the R script as the executable. 

The `R.submit` file may have included a few lines that you are unfamiliar with.  For example, `$(Cluster)` and `$(Process)` are variables that will be replaced with the job's cluster and process numbers - these are automatically assigned by.  This is useful when you have many jobs submitted in the same file.  Any output and errors will be placed in a separate file for each job.

## Submit and View Output

Finally, submit the job!

	$ condor_submit R.submit
	Submitting job(s).
	1 job(s) submitted to cluster 3796250.
	$ condor_q alice
	-- Schedd: ap40.uw.osg-htc.org: <192.170.227.22:9618?... @ 04/13/23 09:51:04
	OWNER      BATCH_NAME     SUBMITTED   DONE   RUN    IDLE  TOTAL JOB_IDS
	alice	   ID: 3796250   4/13 09:50      _      _      1      1 3796250.0
	...

You can follow the status of your job cluster with the `condor_watch_q` command, which shows `condor_q` output that refreshes each 5 seconds.  Press `control-C` to stop watching.

Since our jobs prints to standard out, we can check the output files. Let's see what one looks like:

	$ cat R.out.3796250.0
	[1] "Hello World!"

## Related Guides for Running R Code

 - [Use Custom Libraries with R]()
 - [Scale Up your R jobs]()

