# Dolibarr devtainer setup

This repository helps you easily run multiple parallel Dolibarr installations
in different versions. Easy Dolibarr installation is a separate unit for it
self complete with it's own mariadb database, Dolibarr and a phpmyadmin for
a much better view of the database.

## Technology
podman containers and especially podman pods are used to keep separate things
separate, but also at the same time keep tightly coupled containers inside a
single unit.

### git worktree
Since the aim of this repository is to make Dolibarr development more easy, we need
to easily have the container use the git repository that you make your changes in, so
easy that it is basically just a browser reload, and then you are directly viewing the
result of your code changes. There are multiple solutions to this, but git worktree
is the best. You can start reading about git worktree here:
https://www.hatica.io/blog/git-worktree/
https://www.gitkraken.com/learn/git/git-worktree
https://git-scm.com/docs/git-worktree

## What is a unit/podman pod?
A unit is meant as a stand on it's own working Dolibarr solution. It is kept
inside a podman pod which you can read much more about here:
https://www.redhat.com/en/topics/containers/what-is-podman#what-are-pods

### Working Dolibarr solution
There bare minimum for a working Dolibarr installation is of course Dolibarr,
but you also need a database, here we have decided on using the latest mariadb
container image because it is free both in speech and beer. The same applies to
Dolibarr.

To make database access much much easier this setup also allows to run a
phpmyadmin container inside the same unit. You don't need this, so the default
is not to start the phpmyadmin container.

### Open ports in a unit/podman pod
To facilitate running other containers inside the same pod, this might use the
Dolibarr API, or integration with other stuff. Therefore each podman pod is
defined with a range of ports to be forwarded inside the pod, but not all of
them are used by default:

* xxx36 is used for accessing phpmyadmin
* xxx80 is used for accessing Dolibarr
* xxx81-89 is forwarded but not used by default, you may use this for your own
stuff. Another use for ports 81-89 is for running a stock dolibarr at port 80
and then your own branch at ports 81-89 if you are working on the GUI and want
to easily switch back and forth comparing stock and your new development. But
you could also just run it as a separate unit.

#### what is the xxx?
The xxx is dependent on which version of Dolibarr you want to run:
* development has xxx = 80 so ports become 8036, 8080 and so on
* Dolibarr version 21.0 has xxx = 210
* version 20 has xxx = 200
* and so on

### Pod and container naming
Naming is used to make it easy to correlate pods, containers, the port numbers and
the dolibarr version.

#### pod naming
podman pod supports many names, but to make it easier to correlate, remember and
control the pod names will be dolipod_${VERSION}.

#### Container naming
Podman containers may also have many different names, but once again the naming
choice for a given version
* mariadb_${VERSION}
* dolibarr_${VERSION}
* phpmyadmin_${VERSION}


## Bringing it all together
To bring it all together we need some code and some data - let's start with the data.

### mariadb
To ensure we start with the same data in all containers, you simply take your backup
from your production Dolibarr and initialize the mariadb from that backup. This is
done by mounting the backup file to this location in the mariadb container
    /docker-entrypoint-initdb.d/${FILENAME}

### The link between git worktree and the Dolibarr container.
Given that each git worktree is stored in a separate folder, and that each git
worktree folder can have it's own branch, then we simply mount the htdocs/ subfolder
from that git worktree folder to /var/www/html inside the Dolibarr container running
the corresponding version to the branch in git.

### passwords
For security reasons we aim for using random passwords, but to make it easy to share
these passwords between the multiple containers that needs to know them, we will use
podman secrets which you can read more about here:
https://www.redhat.com/en/blog/new-podman-secrets-command

IF you use this setup as a basis for any kind of production, then you need to store
these passwords in a separate password manager.

If you need to know the passwords, simply enter into the mariadb container and type
_export_ because that will reveal both the mariadb root password also used by the
phpmyadmin container and the doliuser password used by mariadb and dolibarr.

# Usage
1. Clone this repo
2. copy default.config to local.config and make the necessary changes
3. run ./first_setup_git_repo_and_worktree.sh
4. run ./second_create_podman_setup.sh
5. run ./third_start_podman_setup.sh
6. direct your browser to each dolibarr installation that you configured in ${ACTIVE_VERSIONS}

## Recommendations
Here's some recomendations for using podman containers.

### podman desktop is a nice gui tool
Download it from https://podman-desktop.io

### bash aliases
make some aliases in bash for easy container mangement

#### penter
Execute a command inside a name container
alias: _penter='podman exec -it'_
usage: _penter dolibarr_21.0 bash_

#### punter
Same as penter, you just become root
alias: _punter='podman exec -itu 0'_
usage: _punter mariadb_20.0 bash_

#### plogs and plogsf
View the logs of a container, because most apps inside a container just sends logging to stdout
alias: _plogs="podman logs"_
alias: _plogsf="podman logs -f"_
usage: plogs dolibarr_20.0
