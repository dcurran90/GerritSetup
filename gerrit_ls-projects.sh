#! /bin/bash

hostname="localhost"
port=29418

while getopts ":h:p:j" opt; do
    case $opt in
        h)
            hostname=$OPTARG
            ;;
        p)
            port=$OPTARG
            ;;
        j)
            echo "Usage: $0"
            echo "       [-h <Hostname>] [-p <Port Number>]"
            echo "Default host: localhost"
            echo "Default port: 29418"
            exit 1
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

ssh -p $port $hostname gerrit ls-projects
