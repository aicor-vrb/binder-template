# --- FROM block for ROS 1 Noetic (replaces the FROM/USER lines of the minimal Dockerfile)
# Documented path from the template README: official ROS image + JupyterLab.
# No VSCode server and no VNC desktop. Ubuntu 20.04, Python 3.8.
FROM ros:noetic-ros-base

ENV SHELL=/bin/bash
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=noetic
ENV ROS_PATH=/opt/ros/noetic
ENV NB_USER=root

RUN apt-get update && apt-get install -y --no-install-recommends \
        python3-pip git python3-catkin-tools python3-rosdep \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir jupyterlab ipywidgets

# JupyterLab port, required by Binder
EXPOSE 8888

# In this image `python3 -m pip` is the system pip. Continue with the
# SYSTEM PACKAGES / EXTERNAL REPOSITORIES / PYTHON PACKAGES / COPY sections
# of the minimal Dockerfile unchanged.
