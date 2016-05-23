# ninjaben/jupyter-hub-oauth-matlab
# 
# JupyterHub plus Google OAuth, plus support for a mounted-in Matlab installatoin and the Jypyter matlab_kernel.
#
# Example usage:
# docker run --rm -p 80:8000 --rm -v /usr/local/MATLAB/R2016a:/usr/local/MATLAB/from-host -v /home/ben/Desktop/matlab-docker:/var/log/matlab --mac-address=68:f7:28:f6:68:a6 ninjaben/jupyter-matlab-support 
#
# This example worked on the author's dev machine.  To run it on your machine you must make some substitutions:
#   - For "/usr/local/MATLAB/R2016a" substitute your Matlab location and version.  Try "ls -al `which matlab`".
#   - For "/home/ben/Desktop/matlab-docker", substitute any folder where you want the container to write logs.
#   - For "68:f7:28:f6:68:a6", substitute the mac address associated with your Matlab license.
# 
# Based on work by Michael Perry at Stanford.  Thanks!
# Based on the JupyterHub official oauthenticator example.  Thanks!
#   https://github.com/jupyterhub/oauthenticator/tree/master/example
#

# TODO: invoke setToolboxPath at startup, so that notebooks don't have to see it.
# see matlabroot/toolbox/local/matlabrc.m or startup.m

FROM ninjaben/jupyter-hub-oauth

MAINTAINER Ben Heasly <benjamin.heasly@gmail.com>

# Matlab and Python dependencies
RUN apt-get update && apt-get install -y \
    libpng12-dev libfreetype6-dev \
    libblas-dev liblapack-dev gfortran build-essential xorg xorg-dev python-dev pkg-config

# Python libs
RUN pip install pyzmq \
    && pip install matplotlib \
    && pip install numpy \
    && pip install scipy \ 
    && pip install nibabel \
    && pip install pymatbridge \
    && pip install jupyter \
    && pip install jupyter_client \
    && pip install matlab_kernel \
    && python -m matlab_kernel.install

# wrapper to start mounted-in matlab, plus MATLABPATH=/usr/local/MATLAB/
ADD matlab /usr/local/bin/matlab

# shared temp folder where python-matlab bridge can write image files
RUN mkdir -p /tmp/MatlabData/ && chmod 777 -R /tmp/MatlabData/

# shared Matlab demo notebook
ADD MatlabWelcome.ipynb /srv/ipython/examples/MatlabWelcome.ipynb

# standard place where other Docker images can add toolboxes
RUN mkdir -p /usr/local/MATLAB/toolboxes
ADD setToolboxPath.m /usr/local/MATLAB/setToolboxPath.m

# add toolboxes to path at startup
ADD startup.m /usr/local/MATLAB/startup.m

