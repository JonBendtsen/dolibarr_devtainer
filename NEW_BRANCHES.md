# Working with new branches

The git worktree command makes it easy to make one or more of your own branches.

This file describes the method I use to still easily run a container even though
you can not pull an container image and also how to easily get the port number
system working.

## branch from develop

1. cd into the folder where your dolibarr develop branch is
2. git switch develop && git pull --rebase
3. git worktree add -b from_develop_api_objectlinks ../GitWorkTree/from_develop_api_objectlinks
4. grep -e "define.*DOL_VERSION" htdocs/filefunc.inc.php

When making this documentation, the answer is **22.0.0-alpha** so I just use 22.0

5. cd ../GitWorkTree/
6. ln -s from_develop_api_objectlinks/ 22.0

Then I edit the local.config file in your dolibarr_devtainer folder and adds 22.0
to the variable **ACTIVE_VERSIONS**. 

Running **./second_create_podman_setup.sh** will then complain that there is no
version 22 image, and a podman image ls. The docker equvialent should reveal the
same. I do have a dolibarr develop image, and I simply choose to use that as the
source, and just tag it with version **22.0**.

*podman image tag docker.io/dolibarr/dolibarr:develop docker.io/dolibarr/dolibarr:22*

So now when I run **./second_create_podman_setup.sh** there is a version 22 image,
and the container can be created, started and you can easily test your own branch.

## 2 - 10 new branches?

I simply use the method from above, just with 22.1, 22.2, ... except for the image
the Dolibarr image, here I will just use 22, not 22.x

## More than 10 new branches?

Do you really need more than 10 new branches all running at the same time? If so
then you're pretty advanced and can probably figure out something with higher
numbers like 23, 24, ... and so on.

If they don't all need to run at the same time, then you can also simply just
change the symbolic link and reuse the numbers 22.0 to 22.9
