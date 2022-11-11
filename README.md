# python-builder

This project builds a Python binary for RedHat UBI(8).

The Python version built will be the latest update of the version specified. E.g. the current default version is `3.9`; As of 10 Nov 2022, the latest update is `3.9.15`
## Build

To build the default version:

```sh
docker build -t python:3.9 .
```

To build a Python version other than the default (e.g. `3.11`):

```sh
docker build --build-arg PYTHON_VERSION=3.11 -t python:3.11 .
```

## Verify

To verify the version installed:

```sh
docker run --rm python:3.9 --version

Python 3.9.15
```

```sh
docker run --rm python:3.11 --version

Python 3.11.0
```

## Run

To launch an interactive Python shell:

```sh
docker run -it --rm python:3.9

Python 3.9.15 (main, Nov 11 2022, 00:09:10) [GCC 8.5.0 20210514 (Red Hat 8.5.0-15)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>>
```
