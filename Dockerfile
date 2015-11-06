FROM centos:7

RUN yum install -y gcc libffi-devel git make rpm-build
RUN yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel
RUN curl -LO https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz 
RUN tar -xvf Python-2.7.8.tgz 
RUN rm Python-2.7.8.tgz 
WORKDIR Python-2.7.8
RUN ./configure 
RUN make
# Don't do an alt-install; instead put this python binary somewhere that's not on the path.
RUN make install
RUN curl https://bootstrap.pypa.io/ez_setup.py | PATH=/usr/local/bin:$PATH /usr/local/bin/python2.7

RUN mkdir /git
RUN mkdir /rpms

WORKDIR /git
RUN git clone https://github.com/projectcalico/python-posix-spawn.git
WORKDIR python-posix-spawn
RUN echo -e "[install]\ninstall-lib=/usr/lib/python2.7/site-packages" > setup.cfg 
RUN PATH=/usr/local/bin:$PATH python setup.py bdist_rpm
#RUN cp dist/posix-spawn* /rpms

WORKDIR /git
RUN git clone https://github.com/projectcalico/python-etcd.git
WORKDIR python-etcd
RUN echo -e "[install]\ninstall-lib=/usr/lib/python2.7/site-packages" > setup.cfg 
RUN PATH=/usr/local/bin:$PATH python setup.py bdist_rpm 
#RUN cp dist/python-etcd* /rpms

VOLUME /rpms
WORKDIR /git
CMD ["bash", "-c", "cp -f */dist/*.rpm /rpms"]

