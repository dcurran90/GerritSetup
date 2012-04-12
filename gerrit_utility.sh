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

invalid_argument()
{
    if [[ "$1" != "create" && "$1" != "clone" && "$1" != "ls" ]]
    then
        return 0
    else
        return 1
    fi
}

print_usage()
{
    if ( invalid_argument "$1" )
    then
        echo "Invalid argument: $1, valid: create | clone | ls"
    fi

    echo "Usages:"
    echo ""
    echo "Create a new project:"
    echo "$0 create <Project Name[.git]> [Clone Directory Name]"
    echo "[-h <HOSTNAME>] [-p <PORTNUMBER>]"
    echo ""
    echo "Cline an existing project:"
    echo "$0 clone <Gerrit Project Name[.git]> [Clone Directory Name]"
    echo "[-h <HOSTNAME>] [-p <PORTNUMBER>]"
    echo ""
    echo "List all projects (that you have read-access to; may include projects not owned by you)"
    echo "$0 ls"
    echo "[-h <HOSTNAME>] [-p <PORTNUMBER>]"
    echo ""
    echo "Default host: localhost"
    echo "Default port: 29418"
    echo "If Clone Directory Name is not passed, it will be Gerrit Project Name"
    echo " (sans .git)."
}

if [[ $# < 1 || $# > 3 ]]
then
    print_usage
    exit 1
elif ( invalid_argument "$1" )
then
    print_usage
    exit 1
fi

if [[ "$1" == ls ]]
then
    ssh -p $port $hostname gerrit ls-projects
else
    projectname=${2%.git}

    if [[ -z $3 ]]
    then
        clonedirectoryname=$projectname
    else
        clonedirectoryname=$3
    fi

    echo $clonedirectoryname

    if [[ "$1" == create ]]
    then
        ssh -p $port $hostname gerrit create-project --name $projectname
    fi
    git clone ssh://$hostname:$port/$projectname.git $clonedirectoryname
    cd $clonedirectoryname
    scp -p -P $port $hostname:hooks/commit-msg .git/hooks/
fi
