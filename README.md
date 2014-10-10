# RME (or whatever the name is)

It's **just** a review board for git based projects, nothing more.

It's split in two components, the web interface and a command line tool, both working togheter. The idea is to be more simpler possible and avoid extra useles steps.

## Create a merge request

1. Do your job, i.e. code!
2. Commit it to git
3. It's ready for review? then just call `rme` command.

Done, it's it. Your review will be created and the rme command will tell you the URL used for review.

## Updating a merge request

1. Update your patch (git commit --amend)
2. call `rme` command.

Done.

## Accepting a merge request

1. Go to web interface and click accept.

Done, Rme will try to apply and commit your patch, it will tell you if it can't. And if it can't, just send another 

## How to setup rme command line interface

1. Register your projecy in the web interface.
2. go to the directory where your project workign copy is.
3. type the command you saw in the web interface.

Done.

## Telling on what branch the patch should go

Use the syntax: `rme on <branch>`

# Wish list

1. lint support
2. CI integration
3. Way to review resolution of merge conflicts.
