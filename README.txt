This is a project that is a result of the information I've learned from setting
up gerrit.

Steps that I took:

01. I created a public directory in /pub .
    This directory is designed so that eveyone on the local system can write
    to the repo. It may not be the best practice but it's just what I did.
02. Copied the .war to /pub and ran the `java -jar gerrit.war init` function.
    Note that I'm not using the gerrit2 user... I probably could but just to
    keep things simple for testing purposes I didn't.
03. Did not change anything in the init.
04. Changed permissions to allow necessary files to be rwx by all.
05. Set up my .ssh keys and uploaded it to GitHub.
06. Configued the gerrit/etc/secure.config, gerrit/etc/replication.config and
    ~/.ssh/config files as seen in the shell script. This hooks Gerrit up to
    GitHub.
07. Created a gerrit project such as 
   `ssh -p 29418 localhost gerrit create-project --name  GerritTest01`
08. Did some stuff with this project to add and modify changes, learned
    the review structure. Had to set up permissions for my administrator
    account to be able to submit these changes.
09. Created a GitHub repository on github.com/aaron-brown/GerritTest01.git .
    When it said to put the remote origin link in the local git repo, I did
    that in /pub/gerrit/git/GerritTest01.git/ .
10. I don't know if it will automatically replicate, but I did get it to
    push to the repo by calling `ssh -p 29418 localhost gerrit replicat --all` .
11. It's hard to tell because the Gerrit directory structure under the .git
    repo is a little odd, but within the replication.config file it's set up
    to push refs/head/* and ref/tags/*, so you don't see any of the Gerrit
    structure.

I was able to do cloning 
 (`git clone ssh://localhost:29418/GerritTest01.git GerritTest01-Clone`)
 And this copies only the repo, none of the Gerrit directory structure in the
 GerritTest01.git repo.
