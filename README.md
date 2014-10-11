# Review it!

It's **just** a review board for git based projects, nothing more.

It's split in two components, the web interface and a command line tool, both working togheter. The idea is to be more simpler possible and avoid extra useles steps.

## Create a merge request

1. Do your job, i.e. code!
2. Commit it to git
3. It's ready for review? then just call `review push BRANCH` command.

Your patch will be post to review, aiming to be merged into BRANCH.

e.g. `review push 3.4.0` will create a merge request with your HEAD commit targeting the 3.4.0 branch.

## Updating a merge request

1. Update your patch (git commit --amend)
2. Call `review push` command.

## Accepting a merge request

1. Go to web interface and click accept and the patch should be merged.

Reviewit will try to apply and commit your patch, it will tell you if it can't. And if it can't, solve the conflicts (rebase) then send it again for review.

## How to setup rme command line interface

1. Register your projecy in the web interface.
2. go to the directory where your project workign copy is.
3. type the command you saw in the web interface.

Done.

# Wish list

1. lint support
2. CI integration
