#!/bin/bash

useradd -m -s /bin/bash rstudio
# echo rstudio | passwd rstudio --stdin
echo rstudio:rstudio | chpasswd
rstudio-server start