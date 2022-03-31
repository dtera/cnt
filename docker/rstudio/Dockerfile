FROM rstudio/rstudio-server-pro

MAINTAINER dterazhao (https://github.com/dtera)

RUN useradd -m -s /bin/bash rstudio
# echo rstudio | passwd rstudio --stdin
RUN echo rstudio:rstudio | chpasswd
WORKDIR /home/rstudio
VOLUME /home/rstudio/data
