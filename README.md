gotzl/docker-django-uwsgi-nginx
==================

Docker image for django (uwsgi) & nginx, forked from [mbentley/docker-django-uwsgi-nginx](https://github.com/mbentley/docker-django-uwsgi-nginx)
based off of debian:buster

To buid this image with your django app:
```bash
git clone https://github.com/gotzl/docker-django-uwsgi-nginx.git
cd docker-django-uwsgi-nginx
cp -a ../__myapp__/* app/
docker build -t docker-django .
```
There are two build arguments (--build-arg ARG=VAL):
* ldap=true: includes ldap facilities in the image, makeing it possible to use django-auth-ldap for authentication
* latex=true: includes latex compiler in the image

Example usage:
`docker run -p 80:80 -d -e MODULE=myapp docker-django`
where `myapp` is your django application name.
