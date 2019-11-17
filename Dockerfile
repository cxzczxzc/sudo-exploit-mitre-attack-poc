#This dockerfile creates a container that satisfies the preconditions for exploiting CVE-2019-14287
#getting the base OS
FROM ubuntu:18.04

LABEL owner=xrobinhoodx

#install os dependecies 
RUN apt-get update -y && \
    apt-get install -y git && \
    apt-get install -y python3.6 && \
    apt-get install -y python3-pip && \
    apt-get install -y wget && \
    apt-get install -y gcc && \
    apt-get install -y make 

#install python dependencies
RUN pip3 install pexpect 
    
#create user with password 
RUN useradd --create-home --shell /bin/bash saad && \
    echo 'saad:daas' | chpasswd
    
#install sudo with version 1.8.27    
RUN wget https://www.sudo.ws/dist/sudo-1.8.27.tar.gz -O /tmp/sudo.tar.gz &&\
    tar xfz /tmp/sudo.tar.gz -C /tmp/ &&\
    cd /tmp/sudo-1.8.27 &&\
    ./configure &&\
    make &&\
    make install 

#setup sudoers file to facilitate the execution of the exploit
RUN echo 'saad ALL=(ALL, !root) /bin/bash'  >> /etc/sudoers

#set the user to saad when the container starts
USER saad

ADD exploit.py /

CMD ["python3", "exploit.py"]





