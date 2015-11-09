FROM centos:7
MAINTAINER paultiplady@gmail.com

RUN yum install -y gcc libffi-devel git make rpm-build zlib-dev openssl-devel sqlite-devel bzip2-devel

# The version of Python that comes with CentOS 7 (2.7.4) has a bug in the bdist_rpm command:
# http://bugs.python.org/issue18045
# The fix for that went into Python 2.7.5, so grab a version at least that new.
RUN curl -LO https://www.python.org/ftp/python/2.7.8/Python-2.7.8.tgz 
RUN tar -xvf Python-2.7.8.tgz 
RUN rm Python-2.7.8.tgz 
WORKDIR Python-2.7.8
# Use Unicode UCS-4, for compatibility with some Python dependencies.
RUN ./configure --enable-unicode=ucs4
RUN make
# Note that we can't just replace the system version of Python, since yum breaks if you upgrade past 2.7.4.
# Don't do an alt-install; instead put this python binary somewhere that's not on the path (/usr/local/bin by default).
RUN make install
RUN curl https://bootstrap.pypa.io/ez_setup.py | PATH=/usr/local/bin:$PATH /usr/local/bin/python2.7

RUN mkdir /rpms
VOLUME /rpms

ONBUILD ADD . /source
ONBUILD WORKDIR /source
# If this repo has already been built on a different architecture, the eggs may be incompatible.
ONBUILD RUN rm -rf .eggs
ONBUILD RUN echo -e "[install]\ninstall-lib=/usr/lib/python2.7/site-packages" >> setup.cfg
ONBUILD RUN PATH=/usr/local/bin:$PATH python setup.py bdist_rpm

CMD ["bash", "-c", "cp -f /source/dist/*.rpm /rpms"] 
