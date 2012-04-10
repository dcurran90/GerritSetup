#! /bin/bash

# Argument check
if [ $# != 2 ]
then
	echo "Usage: $0 </path/to/gerrit> <GitHub Username>"
	exit
else
	echo "Gerrit directory: $1"
	echo "GitHub User Name: $2"
fi

# SSH directory check.
if [ ! -d ~/.ssh ]
then
	echo "~/.ssh does not exist."
	echo "Generating RSA Keys. Do not include a password."
	ssh-keygen
else
	echo "~/.ssh exists."
	echo "Please be sure ~/.ssh/id_rsa.pub is uploaded to GitHub."
fi

# Gerrit Directory check.
if [[ ! -d $1 || ! -f $1/etc/gerrit.config ]]
then
	echo "$1 is invalid for the Gerrit Directory."
	echo "Please be sure Gerrit is installed and"
	echo "that you are using the proper directory."
	exit
fi 

echo ""
echo "Creating ~/.ssh/config and setting it up for Gerrit ..."

if [ ! -f ~/.ssh/config ]
then
	touch ~/.ssh/config
fi
sshconfig=~/.ssh/config
echo "Host github.com:" >> $sshconfig
echo "	IdentityFile ~/.ssh/id_rsa" >> $sshconfig
echo "	PreferredAuthentications publickey" >> $sshconfig

if [ ! -f $1/etc/secure.config ]
then
	touch $1/etc/secure.config
fi

secureconfig=$1/etc/secure.config
echo "[ssh]" >> $secureconfig
echo "	file = $HOME/.ssh/config" >> $secureconfig

if [ ! -f $1/etc/replication.config ]
then
	touch $1/etc/replication.config
fi

repconfig=$1/etc/replication.config
echo '[remote "github"]' >> $repconfig
echo "	url = git@github.com:$2/\${name}.git" >> $repconfig
echo "	push = +refs/heads/*:refs/heads/*" >> $repconfig
echo "	push = +refs/tags/*:refs/tags/*" >> $repconfig
echo "	timeout = 5" >> $repconfig
echo "	replicationDelay = 0" >> $repconfig
