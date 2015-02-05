# mysql

```
[Launch the database container first]
$ docker run --rm -e MYSQL_ROOT_PASSWORD=s -p :49156:3306 bleacher/mysql:empty
```

For connections to localhost, the MySQL client will attempt to connect to the local server by using a Unix socket file.  The Unix socket file is used even when the `--port` or `-P` option has been invoked to specify a port number.  To force the MySQL client to connect to localhost via TCP/IP, use the `--host` or `-h` option to specify a host name value of `127.0.0.1` or the IP address or name of the Docker host with `$(boot2docker ip)`.  Alternatively, connection to localhost via TCP/IP can be forced by using the `--protocol=TCP` or `--protocol tcp` option.

```
[Create the database inside the container]
$ mysql -h 127.0.0.1 -u root -P 49156 -p -e 'create database br1;'

[Connect to the database container locally]
$ bzip2 -dc snapshots/bleacherreport_production_201502021002.sql.bz2 | mysql -h 127.0.0.1 -u root -P 49156 -p br1

[Make sure the data dump succeeded]
$ mysql -h localhost --protocol tcp -u root -P 49156 -p br1

or

$ mysql -h 127.0.0.1 -u root -P 49156 -p br1

or

$ mysql -h $(boot2docker ip) -u root -P 49156 -p br1

mysql> select count(*) from articles;
+----------+
| count(*) |
+----------+
|    10000 |
+----------+
1 row in set (0.00 sec)

[Create a new database image]
$ docker commit <container_name> bleacher/mysql:2015-01-30
$ docker push
```

These steps have been automated by a script.

```
jimmyhuang@work(master)$ ./bin/update-db-snapshot-image.sh 
The latest BReport snapshot 'snapshots/bleacherreport_production_201502021002.sql.bz2' is already on the local file system.

Pulling repository bleacher/mysql
d21f08a195c0: Download complete 
511136ea3c5a: Download complete 
f10807909bc5: Download complete 
f6fab3b798be: Download complete 
f84ca1bb2533: Download complete 
34872ec9077c: Download complete 
0ad41ae249a1: Download complete 
fb7eda723356: Download complete 
6e3cfc10ded1: Download complete 
11a4d79438e3: Download complete 
f15a7964c0fc: Download complete 
4041948c2d2d: Download complete 
3706cb07f24e: Download complete 
cd47eda31909: Download complete 
7a2025ec331c: Download complete 
43d423e2e06c: Download complete 
Status: Image is up to date for bleacher/mysql:empty

Launching the empty_db container from the bleacher/mysql:empty image...

816ad0ecaca217c8c653aa640eed162f08dca4dbbe9d8deec528661b2de434fb
Creating the br1 database inside the new empty_db container...

Enter password: 
Dumping the latest snapshot into the br1 database...

Enter password: 
Writing the updated br1 database out to a new Docker image...

c8db6cb51fc2578287e43d5f83792a12380b73fe90a3ee822b4b0a4536e6e7de
912d2227071475e25720091f8b80ebe712614f5c801648521afc6f64897e1186
Pushing the new Docker image to the Hub...

The push refers to a repository [bleacher/mysql] (len: 1)
Sending image list
Pushing repository bleacher/mysql (1 tags)
511136ea3c5a: Image already pushed, skipping 
f10807909bc5: Image already pushed, skipping 
f6fab3b798be: Image already pushed, skipping 
f84ca1bb2533: Image already pushed, skipping 
34872ec9077c: Image already pushed, skipping 
0ad41ae249a1: Image already pushed, skipping 
fb7eda723356: Image already pushed, skipping 
6e3cfc10ded1: Image already pushed, skipping 
11a4d79438e3: Image already pushed, skipping 
f15a7964c0fc: Image already pushed, skipping 
4041948c2d2d: Image already pushed, skipping 
3706cb07f24e: Image already pushed, skipping 
cd47eda31909: Image already pushed, skipping 
7a2025ec331c: Image already pushed, skipping 
43d423e2e06c: Image already pushed, skipping 
d21f08a195c0: Image already pushed, skipping 
c8db6cb51fc2: Image successfully pushed 
Pushing tag for rev [c8db6cb51fc2] on {https://cdn-registry-1.docker.io/v1/repositories/bleacher/mysql/tags/2015-02-01}
The push refers to a repository [bleacher/mysql] (len: 1)
Sending image list
Pushing repository bleacher/mysql (1 tags)
511136ea3c5a: Image already pushed, skipping 
f10807909bc5: Image already pushed, skipping 
f6fab3b798be: Image already pushed, skipping 
f84ca1bb2533: Image already pushed, skipping 
34872ec9077c: Image already pushed, skipping 
0ad41ae249a1: Image already pushed, skipping 
fb7eda723356: Image already pushed, skipping 
6e3cfc10ded1: Image already pushed, skipping 
11a4d79438e3: Image already pushed, skipping 
f15a7964c0fc: Image already pushed, skipping 
4041948c2d2d: Image already pushed, skipping 
3706cb07f24e: Image already pushed, skipping 
cd47eda31909: Image already pushed, skipping 
7a2025ec331c: Image already pushed, skipping 
43d423e2e06c: Image already pushed, skipping 
d21f08a195c0: Image already pushed, skipping 
912d22270714: Image successfully pushed 
Pushing tag for rev [912d22270714] on {https://cdn-registry-1.docker.io/v1/repositories/bleacher/mysql/tags/latest}
Stopping and removing the empty_db container...

empty_db
```
