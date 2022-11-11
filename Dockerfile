##---------------------------------------------------------------------------------------------##
#  Python Build
##---------------------------------------------------------------------------------------------##
FROM registry.access.redhat.com/ubi8-minimal:8.7 as builder
ARG PYTHON_VERSION=3.9
RUN microdnf install \
    tar \ 
    gzip \
    make \
    gcc \
    openssl-devel \
    bzip2-devel \
    libffi-devel \
    zlib-devel \
    findutils

# Download and build Python
WORKDIR /tmp
RUN latest_version=$(curl -sSL https://www.python.org/ftp/python/ 2>/dev/null | grep '^<a href' | awk -F'>' '{print $2}' | grep '^[0-9]' \
    | grep "^${PYTHON_VERSION}" | awk -F'/' '{print $1}' | sort -V | tail -1) \
 && curl -o python.tgz https://www.python.org/ftp/python/${latest_version}/Python-${latest_version}.tgz \
 && tar -zxvf /tmp/python.tgz \
 && rm -f /tmp/python.tgz \
 && cd Python-${latest_version} \
 && ./configure --with-system-ffi --with-computed-gotos --enable-loadable-sqlite-extensions --enable-optimizations \
 && make -j ${nproc} \
 && make altinstall

##---------------------------------------------------------------------------------------------##
#  Example copy into UBI image
##---------------------------------------------------------------------------------------------##
FROM registry.access.redhat.com/ubi8-minimal:8.7

RUN microdnf update -y \
    && microdnf install -y shadow-utils \
    && microdnf clean all

ARG PYTHON_VERSION=3.9

# Copy python from bulder
RUN mkdir -p /usr/local/lib/python${PYTHON_VERSION} /usr/local/include/python${PYTHON_VERSION} /usr/local/lib/pkgconfig/

COPY --from=builder /usr/local/bin/* /usr/bin/
COPY --from=builder /usr/local/include /usr/local/include
COPY --from=builder /usr/local/lib/python${PYTHON_VERSION} /usr/local/lib/python${PYTHON_VERSION}
COPY --from=builder /usr/local/lib/pkgconfig /usr/local/lib/pkgconfig
COPY --from=builder /usr/local/share/man/man1/python${PYTHON_VERSION}* /usr/local/share/man/man1/

# Setup python3
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python${PYTHON_VERSION} 1 \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && python3 -m ensurepip --upgrade \
    && python3 -m pip install --upgrade pip \
    && alternatives --install /usr/bin/pip3 pip3 /usr/bin/pip${PYTHON_VERSION} 1

WORKDIR /
ENTRYPOINT [ "python3" ]
