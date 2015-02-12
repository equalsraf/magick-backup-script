
Magic bash backup script, read more [here](http://ruiabreu.org/2011-05-24-the-magic-backup-script.html)

You can create a new script to store your settings

```bash
#!/bin/bash

SOURCE=$HOME/Documents/Work
SSH_HOST="ruiabreu@atnog"
SSH_PATH="/home/ruiabreu/backups/"

. backup.sh
```


You can also use this script to backup to another location on your hardrive. Here is my example script, that accepts the destination as an argument.

```bash
#!/bin/bash

if [ "$#" != "1" ]; then
	echo "Usage: backup-home /dst/base/path"
	exit 1
fi

SOURCE=$HOME
DSTPATH=$1

. backup.sh
```



