# SWIFTCON2025

## Pre-requisites

To streamline the tutorial, we have created a [Docker](https://www.docker.com/) image that contains all required packages and libraries to run the software we will use for today's tutorial. To install Docker, please refer to their [official installation instructions](https://docs.docker.com/engine/install/).

## Creating the Docker image

Once you have installed and verified that you have installed Docker in your system, clone this repository:

```bash
git clone https://github.com/robjmcgibbon/SWIFTCON2025.git
```

and build the Docker image:

```
sudo docker build --no-cache -t tutorial-env .
```
This will take about 5 minutes to execute.

### Mac exceptionalism

On OXS, you will need to add the platform to the command above to build the environment successfully:

```
sudo docker build --platform linux/amd64 --no-cache -t tutorial-env .
```

## Accessing the Docker image

This tutorial has been written with the idea that the provided Jupyter notebook will be used to run the code, as it contains all required information and commands that need to be used. To start the Docker image and the Jupyter lab, run:
```
sudo docker run -it -p 8888:8888 -v $(pwd):/home/jupyteruser/tutorial tutorial-env
```

If you would like to use the command line, run the following instead:
```
sudo docker run -it -v $(pwd):/home/jupyteruser/tutorial tutorial-env /bin/bash
```
