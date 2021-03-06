# [Cometa](https://cometa.ujaen.es)

> The comprehensive multi-label data archive

Cometa is a collection of multi-label datasets, available at [cometa.ujaen.es](https://cometa.ujaen.es) in different 
formats and pre-partitioned.

This repository holds the software pieces (scripts and website source) used to generate the archive. If you 
want to host your own multi-label archive using Cometa, please refer to [this guide](https://cometa.ujaen.es/self-host).

## Build instructions

```
git clone git@github.com:fdavidcl/cometa
cd cometa
docker build -t mycometa .
```

To run your own image:

```
mkdir public
docker run -dp 8080:8080 \
  --volume "$(pwd)/public:/usr/app/public" \
  --name cometa1 \
  mycometa
```

## Run latest image

```
mkdir public
docker run -dp 8080:8080 \
  --volume "$(pwd)/public:/usr/app/public" \
  --name cometa1 \
  fdavidcl/cometa:latest
```

To stop and restart your container:

```
docker stop cometa1
docker start cometa1
```

## Run image in interactive mode

```
mkdir public
docker run --rm -itp 8080:8080 \
  --volume "$(pwd)/public:/usr/app/public" \
  --name cometa1 \
  fdavidcl/cometa:latest
```

It is recommended to use the detached mode and [`docker 
exec`](https://docs.docker.com/engine/reference/commandline/exec/) if you just want to execute 
commands inside the container (e.g. changing `site/_config.yml`).

## Allowing dataset submissions

Run with environment variables:

- `SUBMISSION_REPO`: A GitHub repository in the format `user/repo` where issues will be created when a dataset is submitted.
- `SUBMISSION_TOKEN`: A [personal access token](https://github.com/settings/tokens) from GitHub to automatically open issues.

Example:

```
docker run -dp 8080:8080 \
  --volume "$(pwd)/public:/usr/app/public" \
  --name cometa1 \
  -e SUBMISSION_REPO="example/cometa" \
  -e SUBMISSION_TOKEN=123456abcdef7890ghij \
  fdavidcl/cometa:latest
```

## Licenses

This software is distributed under the [Affero GPL v3.0](https://github.com/fdavidcl/cometa/blob/master/LICENSE).

The datasets distributed within the archive are property of their own rightful authors. You can find 
authorship and citation information inside each individual page.
