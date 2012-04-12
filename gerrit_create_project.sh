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

if [[ $# != 1 ]]
then
    echo "Usage: $0 <Project Name[.git]>"
    echo "       [-h <Hostname>] [-p <Port Number>]"
    echo "Default host: localhost"
    echo "Default port: 29418"
    echo "Local repo name will not include [.git] if [.git] is passed."
    exit 1
else
    projectname=${1%.git}
fi

ssh -p $port $hostname gerrit create-project --name $projectname
git clone ssh://$hostname:$port/$projectname.git $projectname
cd $projectname
scp -p -P $port $hostname:hooks/commit-msg .git/hooks/
