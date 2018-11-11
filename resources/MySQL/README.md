# MySQL

Installs MySQL using the [Docker maintained MySQL image](https://hub.docker.com/_/mysql/).

Currently, this uses the `MYSQL_RANDOM_ROOT_PASSWORD` option to generate a unique password at init time. This password is output to stdout and must be retrieved before you can connect. If you miss the output of the password, you can use the following command to retrieve it from any created Docker containers that have `root_db` in their name:

```
for i in $(docker ps -a | grep root_db | awk '{print $1}'); do echo -n "$i: "; docker logs $i 2>/dev/null | grep 'ROOT PASSWORD'; done
```
