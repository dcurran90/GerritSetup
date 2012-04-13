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
generate_grails=-1 # -1 = off by default, 1 = on by default
grab_cid_hook=1    # -1 = off by default, 1 = on by default

# Function to test for invalid $1 argument
invalid_argument()
{
    if [[ "$1" != "create" && "$1" != "clone" && "$1" != "ls" ]]
    then
        return 0
    else
        return 1
    fi
}

# Print the usage statement
print_usage()
{
    echo "Usages:"
    echo "----------"
    echo "Create a new project:"
    echo "$0 create <Project Name[.git]> [Clone Directory Name]"
    echo ""
    echo "Cline an existing project:"
    echo "$0 clone <Gerrit Project Name[.git]> [Clone Directory Name]"
    echo ""
    echo "List all projects (that you have read-access to;"
    echo "    may include projects not owned by you)"
    echo "$0 ls"
    echo ""
    echo "Arguments:"
    echo "----------"
    echo "Project Name[.git]   This is the Gerrit project name."
    echo "                     specifying [.git] is optional."
    echo ""
    echo "Clone Directory Name This is the name of the directory in which"
    echo "                     the project will be cloned. If not specified,"
    echo "                     it is derived from Gerrit Project Name"
    echo "                     (without the [.git] extension)."
    echo "Options:"
    echo "----------"
    echo "-h                   Hostname to connect to (Default: localhost)"
    echo ""
    echo "-p                   Port number to connect to (Default: 29418"
    echo "                     This is the SSH Port that Gerrit is list-"
    echo "                     ening on."
    echo ""
    echo "-g                   Generate Grails. This flag takes on the oppo-"
    echo "                     site behavior of the default specification,"
    echo "                     which is to NOT generate the grails project."
    echo ""
    echo "-n                   Disable grabbing the Clone-ID Hooks."
    echo "                     This flag takes on the opposite behavior of"
    echo "                     the default specification which is to auto-"
    echo "                     matically grab the Gerrit Change-ID Hook and"
    echo "                     import it to the Clone Directory upon project"
    echo "                     creation or cloneing."
    echo "                     IT IS NOT RECOMMENDED TO USE THIS FLAG."
    echo ""
    echo "-u                   Print this usage message."
}

while getopts ":h:p:gnu" opt; do
    case $opt in
        h) # Hostname switch
            hostname=$OPTARG
            ;;
        p) # Port switch
            port=$OPTARG
            ;;
        g) # Generate Grails flag
            generate_grails=$(($generate_grails * -1))
            ;;
        n) # Grab Change-ID Hook flag
            grab_cid_hook=$(($grab_cid_hook * -1))
            ;;
        u) # Print usage flag
            print_usage
            exit 0
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

# Remove optargs
shift $(($OPTIND - 1))

# Test that there is at least one argument and no more than 3
if [[ $# < 1 || $# > 3 ]]
then
    print_usage
    exit 1
elif ( invalid_argument "$1" )
then
    print_usage
    exit 1
fi

# Follow the "ls" command
if [[ "$1" == ls ]]
then
    ssh -p $port $hostname gerrit ls-projects
else
    # Either create or clone was called
    
    # Capture the <Project Name>, stripping of [.git] if it was used.
    projectname=${2%.git}

    # If no [Clone Directory Name] was provided
    if [[ -z $3 ]]
    then # use the <Project Name>
        clonedirectoryname=$projectname
    else # use the specified [Clone Directory Name]
        clonedirectoryname=$3
    fi

    # if create was called, create the project in Gerrit
    if [[ "$1" == create ]]
    then # create the project.
        ssh -p $port $hostname gerrit create-project --name $projectname
        # <Project Name>.git has been created in $GERRIT_SITE/$REPOS
    fi

    # Clone the project into the derived [Clone Directory].
    git clone ssh://$hostname:$port/$projectname.git $clonedirectoryname

    # Set up the .gitignore with some standard stuff.
    gitignore=$clonedirectoryname/.gitignore
    echo "*.class" >> $gitignore
    echo "*.war" >> $gitignore
    echo "*.bak" >> $gitignore
    echo "*.old" >> $gitignore
    echo "*.log" >> $gitignore
    echo ".settings/" >> $gitignore
    echo "target/classes" >> $gitignore
    echo "target/test-classes" >> $gitignore
    echo "target-eclipse" >> $gitignore

    # If the Generate Grails flag is set
    if [[ $generate_grails == 1 ]]
    then # Test for some exceptions

        # If /usr/bin/grails does not exist
        if [[ ! -e /usr/bin/grails ]]
        then # Skip this step.
            echo "/usr/bin/grails does not seem to exist on your system."
            echo "This step will be skipped."
            echo "Are you sure you have Grails installed?"
            echo "Use \`which grails\` or \`whereis grails\` to see."

        # Else-if [Clone Directory]/grails-app exists
        elif [[ -e $clonedirectoryname/grails-app ]]
        then # Skip this step.
            echo "Grails app already generated -- skipping this step."
            echo "You will have to do it manually if you want to regenerate it."

        else # run the command
            grails create-app $clonedirectoryname

            # Set up .gitkeeps in the directory structure
            appdir=$clonedirectoryname/grails-app

            touch $clonedirectoryname/lib/.gitkeep
            touch $clonedirectoryname/scripts/.gitkeep
            touch $clonedirectoryname/src/groovy/.gitkeep
            touch $clonedirectoryname/src/java/.gitkeep
            touch "$clonedirectoryname/test/unit/.gitkeep"
            touch "$clonedirectoryname/test/integration/.gitkeep"

            touch $appdir/conf/hibernate/.gitkeep
            touch $appdir/controllers/.gitkeep
            touch $appdir/domain/.gitkeep
            touch $appdir/services/.gitkeep
            touch $appdir/taglib/.gitkeep
            touch $appdir/utils/.gitkeep
        fi
    fi

    # If the Grab Clone-ID flag is set
    if [[ $grab_cid_hook == 1 ]]
    then # Proceed to grab the hook.
        scp -p -P $port $hostname:hooks/commit-msg \
            $clonedirectoryname/.git/hooks/
        # The hook is now installed
    fi
fi
