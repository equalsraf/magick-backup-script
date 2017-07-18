#!/bin/bash

## backup.sh
#
# An rsync/ssh backup script
# based on http://blog.interlinked.org/tutorials/rsync_time_machine.html 
#
# Some important variables that MUST be defined:
# - SOURCE	The folder to be backed up
# - SSH_HOST	The ssh host (i.e. user@host)
# - SSH_PATH	The backups root path at the server
#
# The following are not mandatory
# - EXCLUDEFILE A file with a list of ignore patterns($HOME/.rsync/exclude)
#
# There is no use in running this script as is, you should source it instead
# and might as well remove its execution permissions. For example an example
# backup script would be:
#
# #!/bin/bash
#
# SOURCE=$HOME
# SSH_HOST="raf@backup.remote.com"
# SSH_PATH="backups/"
#
# . backup.sh
#
# or using $DSTPATH for local backups.
#

DATE=`date "+%Y-%m-%dT%H:%M:%S"`
if [ -z $DSTPATH ]; then
	# SSH
	if [ -z "$SOURCE" ]; then
		echo "SOURCE is not defined"
		exit
	fi

	if [ -z "$SSH_HOST" ]; then
		echo "SSH_HOST is not defined"
		exit
	fi

	if [ -z "$SSH_PATH" ]; then
		echo "SSH_PATH is not defined"
		exit
	fi
	INC_PATH="$SSH_PATH/incomplete-$DATE"
	TARGET="$SSH_HOST:$INC_PATH"
	LINKPATH="$SSH_PATH/current"
else
	# Local
	INC_PATH="$DSTPATH/incomplete-$DATE"
	TARGET=$INC_PATH
	LINKPATH="$DSTPATH/current"
fi




EXCLUDEFILE="$HOME/.rsync/exclude"

RSYNC=/usr/bin/rsync
RSYNC_ARGS="-azP \
	--delete \
	-q \
	--no-specials \
	--delete-excluded \
	--exclude-from=$EXCLUDEFILE \
	--link-dest=$LINKPATH \
	$SOURCE $TARGET"

# Check rsync
if [ ! -x $RSYNC ]; then
	echo "Cannot find rsync: $RSYNC"
	exit
fi

# Check source dir
if [ ! -d $SOURCE ]; then
	echo "Source must be a directory"
	exit
fi

# Check exclude file
if [ ! -f $EXCLUDEFILE ]; then
	echo "Exclude file not found: $EXCLUDEFILE"
	exit
fi

CMD="$RSYNC $RSYNC_ARGS"

if [ -z $DSTPATH ]; then
	# SSH
	echo "Creating $INC_PATH"
	ssh $SSH_HOST mkdir $INC_PATH
else
	# Local
	mkdir $INC_PATH
fi


# Wait for keypress
echo "Preparing to snapshot"
echo "    Command: $CMD"
echo "<Press any key to continue>"
read


if [ -z $DSTPATH ]; then
	# SSH
	$CMD \
	&& ssh $SSH_HOST \
	"mv $SSH_PATH/incomplete-$DATE $SSH_PATH/backup-$DATE \
	&& rm -f $SSH_PATH/current \
	&& ln -s backup-$DATE $SSH_PATH/current"
else
	# Local
	$CMD \
	&& mv $INC_PATH $DSTPATH/backup-$DATE \
	&& rm -f $DSTPATH/current \
	&& ln -s $DSTPATH/backup-$DATE $DSTPATH/current
fi

