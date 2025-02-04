# docker-craft-dev-env

This container helps you to setup a local environment for CRAFT CMS. This environment consists of:

- Nginx webserver
- PHP-FPM 7.0 or 7.2
- MySQL Server 5.6
- Redis Server 5.0
- Node 9.11 + npm
- Frontend Tooling (gulp, bower, pug-cli)
- bash + some sane CLI tools (vim,curl,git, ...)

To enable you an easy workflow, this repository contains a helpful little shell script which you can use to manage this container.

## Installation

* Copy the `bin/craft` script somewhere into your $PATH. E.g. `~/bin/craft`
* Done :)

## Usage


### Update

Regulary run `craft selfupdate` so the tool will get the latest version from GitHub and update itself.

### Start

```bash
cd /folder/containing/your/craft/website
cp the appropriate file containing your dev settings to the right place (.env.local or db.local.php depending on CRAFT version)
craft start
```

The database credentials in your dev setting must be the following:
```
Host: mysql
Username: root
Password: root
Database: See next step
```


`craft start` will do the following things:

- Pull the latest mysql container and start it with it's database dir (/var/lib/mysql/) mounted to `~/databases`.
- Pull the latest redis container and start it with it's data dir (/data) mounted to `~/redis`.
- Pull the latest craft-dev-env container and start the nginx+php7.0 inside of it. Nginx will listen on port 8080 of your machine. We assume that you are currently inside the project folder and mount it into the container as the document root under `/local`.

If you wan't to use php7.2 instead of 7.0, you can start the container with an extra argument like this: `craft start 7.2`.

### Load a database

A CraftCMS site is pretty useless without a database, so we need to create one. To create an empty database run 

```bash
craft create <db-name>
```

If you wan't to populate the DB with some data, e.g. from the current prod environment you can do this by running

```bash
cp <dump-name>.sql /folder/containing/your/craft/website
craft import <db-name> <dump-name>
```

The dump can be in one of the following formats:
  - .sql
  - .sql.gz
  - .sql.zst

### Build frontend

To start gulp inside the container you can run
```bash
craft gulp
```
This will start the default action defined in your gulpfile. To run a specific task, you can add it at the end:

```bash
craft gulp build
```

### Define webserver root directory
Rename the `web` folder to `public`. This is the access point for our webserver.

### Finishline

When everything has worked until this point you should be able to open [localhost:8080](http://localhost:8080) in
your browser and see your webpage. Maybe you also want to visit `/admin` and see if there are outstanding database
migrations to apply.

### Teardown

When you are done and wan't to throw the containers away, just run `craft stopall`. This will gracefully stop the MySQL
server and then remove all containers. Because the database files and the precompiled assets were saved to your
local disk, the next time you run `craft start` everything will already be there.

If you only want to switch to another CraftCMS projekct, you can use `craft stop` which wil only stop the PHP container
and keep the MySQL and the Redis container running because they are shared between all projects.

### Custom scripts

If you have custom scripts which you want to execute for this specific project (e.g. installing packages or copying
files) you can create a `scripts` folder in your project root (where you start `craft`) and put your scripts into it.
Everything ending with `.sh` gets executed with `bash` when you run `craft gulp`.

### Shell access

If you wan't to access the filesystem inside the container to e.g. take a look at a logfile or modify some files you
can run `craft shell` to spawn a bash.

### External Tunnel

Sometimes you need to access the CRAFT installation from the outside to e.g. receive a webhook from a third-party. To
make this easy we included [ngrok](https://ngrok.com) inside the container. After running `craft tunnel` you will see
the ngrok interface which will present you publicly reachable `https:<randomhash>.ngrok.io` domain which will point
to the nginx inside the container.
