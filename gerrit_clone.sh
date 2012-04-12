#! /bin/bash

hostname="localhost"
port=29418

while getopts ":h:p:" opt; do
    case $opt in
        h)
            hostname=$OPTARG
            ;;
        p)
            port=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

shift $(($OPTIND - 1))

if [[ $# > 2 || $# == 0 ]]
then
    echo "Usage: $0 <Gerrit Project Name[.git]> [Clone Directory Name]"
    echo "       [-h <Hostname>] [-p <Port Number>]"
    echo "Default host: localhost"
    echo "Default port: 29418"
    echo "Default Clone Directory Name is Gerrit Project Name (sans .git)."
    exit 1
fi

projectname=${1%.git}

if [[ $# == 2 ]]
then
    directoryname=$2
else
    directoryname=$projectname
fi

git clone ssh://$hostname:$port/$projectname.git $directoryname
cd $directoryname
scp -p -P $port $hostname:hooks/commit-msg .git/hooks/
