This Dockerfile provides ONBUILD triggers to copy the pwd into the container, and run python setup.py bdist_rpm on it.

Create a Dockerfile that imports this one in the root directory of your Python project, e.g.

FROM paultiplady/centos-python-rpm-builder
Ensure that your project has a setup.py.
For any RPM dependencies that you want to have included in the built RPM, add them to a setup.cfg at the root of your repo, containing the following:

```
[bdist_rpm]
requires = rpm-name-1[, rpm-name-2[, ...]]
```

You can also tweak the fields of the built RPM using that setup.cfg in the normal way (see https://docs.python.org/2.7/distutils/builtdist.html?highlight=rpm).

Finally, to build your rpms:

```
docker build -t rpm-builder .
docker run -v /tmp/rpms:/rpms rpm-builder
```

Replace `/tmp/rpms` with whatever path you wish the RPMs to be copied to.
