#! /bin/bash

#####
# gerrit_utility.sh
###
# This is a utility for the Gerrit project for use at Rackspace.
# It automates three typical Gerrit functions:
#   Gerrit project creation
#   Gerrit project cloning
#   Gerrit project listing
#
# The program also supports Grails project generation with the -g flag.
#
# Automated flow:
# 1. If "ls" is given, projects on the server are listed. These projects
#    may include those unowned by you. This is so you can find the project
#    name of a project you would like to clone from.
#
# 2. If create or clone is given:
# 3. If create is given, the project is created onto the Gerrit server with
#    the given project name.
# 4. The project is cloned from the server and placed into the clone directory
#    which is either given or derived from the Gerrit project name
#    (the gerrit project name without .git suffix).
# 5. The Change-ID hooks are automatically installed. This step is important
#    but often neglected / forgotten. Without this hook, you will not be able
#    to rework a Change-ID the project could get messy down the line. This can
#    be suppressed.

#####
# Defaults
###
# Change these defaults to reflect what you will most often use.
#
# honstname: The hostname of the Gerrit servier. Default is 'localhost'
# port: The portnumber of the SSH port. Default is 29418 (Gerrit default).
# generate_grails: Flag to generate a grails project into the repository
# grab_cid_hook: Flag to specify whether or not to grab Change-ID hook.

hostname="localhost"
port=29418
generate_grails=0
grab_cid_hook=1

while getopts ":h:p:gn" opt; do
    case $opt in
        h)
            hostname=$OPTARG
            ;;
        p)
            port=$OPTARG
            ;;
        g)
            generate_grails=1
            ;;
        n)
            grab_cid_hook=0
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

    if [[ "$1" == create ]]
    then
        ssh -p $port $hostname gerrit create-project --name $projectname
    fi
    git clone ssh://$hostname:$port/$projectname.git $clonedirectoryname


fi

if [[ $generate_grails == 1 && -e /usr/bin/grails ]]
then
    grails create-app $projectname
fi

if [[ $grab_cid_hook == 1 ]]
then
    cd $clonedirectoryname
    scp -p -P $port $hostname:hooks/commit-msg .git/hooks/
fi
