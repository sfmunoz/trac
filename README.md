# Trac

An ad hoc [Trac](https://trac.edgewall.org/) Docker image

## Usage

### Pull Docker image

```sh
docker pull ghcr.io/sfmunoz/trac:latest
```

### Run server

Example using most of the supported variables:

```sh
docker run \
  -it \
  --rm -p 127.0.0.1:8080:8080 \
  -e USER_UID=1030 \
  -e USER_GID=1030 \
  -e TRAC_USER_PASS_1=sfmunoz:changeme111 \
  -e TRAC_USER_PASS_2=admin:changeme222 \
  -e TRAC_UMASK=022 \
  -e REALM=my-server \
  -v /home/sfmunoz/trac-env:/trac-env \
  -v /home/sfmunoz/.hg:/home/sfmunoz/.hg:ro \
  --name trac \
  ghcr.io/sfmunoz/trac:latest
```

Where:

- `USER_UID`: the UID of `trac` user within the container (default: `1000`)
- `USER_GID`: the GID of `trac` user within the container (default: `1000`)
- `TRAC_USER_PASS_N`: `user:pass`
  - username:password pair
  - At least `TRAC_USER_PASS_1` must be provided to be able to access the server
- `TRAC_UMASK`: `tracd --umask` parameter (default: `077`, which is more restrictive than `tracd → 022` default)
- `REALM`: the realm used for authentication (default: `trac-server`)
- `/trac-env` is the Trac environment; must be mounted read-write
- Optional: mount mercurial repositories if they are enabled in trac (read-only recommended)

## Devel

### Generating local image (devel)

```
$ docker build -t ghcr.io/sfmunoz/trac:devel .
```

### Image generation on git-push

Images are built automatically by the [GitHub Actions workflow](.github/workflows/docker-build.yml) whenever a version tag is pushed to this repository. The tag must match the upstream Trac release version with a `v` prefix.

```sh
git tag v1.6-2
git push origin v1.6-2
```

The tag format is `v<trac-version>-<build-number>` (e.g. `v1.6-1`, `v1.6-2`, `v1.6-3`, …).

The following tags will be pushed to `ghcr.io`:

- `ghcr.io/sfmunoz/trac:<full-version>` (e.g. `1.6-2`)
- `ghcr.io/sfmunoz/trac:<trac-version>` (e.g. `1.6`)
- `ghcr.io/sfmunoz/trac:latest`

## Python virtualenv: requirements.txt

[requirements.txt](requirements.txt) with the following command sequence:

- `pip install Trac`
- `pip install TracGraphviz`
- `pip install psycopg2-binary`
- `pip install mercurial`
- `pip install "setuptools<81" --force-reinstall --no-cache-dir`
  - Version forced to prevent "ModuleNotFoundError: No module named 'pkg_resources'"

Once everything is installed **requirements.txt** is created by running `pip freeze > requirements.txt`
