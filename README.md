# Keycloak docker builder

Starting from [keycloak-containers - Official Repo](https://github.com/keycloak/keycloak-containers) this small project provides a simple way to compile a Docker image for [Keycloak](https://github.com/keycloak/keycloak) starting from sources hosted on any git repository (github/gitlab or whatever).


## Create image

Simply run this command by changing the `GIT_REPO`, `GIT_BRANCH`, `IMAGE_TAG` parameters:

```
GIT_REPO=https://github.com/keycloak/keycloak \
GIT_BRANCH=main \
IMAGE_TAG=keycloak \
&& docker build . \
    --build-arg GIT_REPO=$GIT_REPO --build-arg GIT_BRANCH=$GIT_BRANCH \
    -t $IMAGE_TAG
```

You have compiled the image. Enjoy!!!
