#!/bin/bash

useradd -m -s /bin/bash rstudio
# echo rstudio | passwd rstudio --stdin
echo rstudio:rstudio | chpasswd
ln -s /data /home/rstudio/data
cd /home/rstudio || exit
rstudio-server start