# Review it!

It's **just** a review board for git based projects, nothing more.

It's split in two components, the web interface and a command line tool, both working togheter. The idea is to be more simpler possible and avoid extra useless steps.

## What you need to do before start using it

1. Register your projecy in the web interface, just need a name, repository URL and the list of users part of the team.
2. Go to the directory where your project workign copy is.
3. Type the command you saw in the web interface.

## Creating a merge request

1. Do your job, i.e. code!
2. Commit it to git like you are used to do.
3. It's ready for review? then just run `review push BRANCH` command.

Your patch will be posted for review, when accepted it will be merged into BRANCH.

e.g. `review push 3.4.0` will create a merge request with your HEAD commit targeting the 3.4.0 branch.

## Updating a merge request

1. Do your job, i.e. code!
2. Update your patch (git commit --amend)
3. Run `review push` command.

## Accepting a merge request

Go to web interface and click accept and the patch should be merged.

Reviewit will try to apply and commit your patch (git am), it will tell you if it can't. And if it can't, solve the conflicts (git rebase) then send it again for review.

## List pending reviews for your project

Just run `review pending`.

## Open a review in your browser

Just run `review open X`, where X is the MR id, you can see the MR ids when listing pending reviews. 

If X is ommited it will open the current review, if it exists.

## Open a review in your terminal

Don't want to wait the browser to start up? Just run `review show X`, where X is the MR id.

## Abandon a review

You can do it on web interface or by running `review cancel`.

## Applying a patch from some MR on your working copy

Sometimes you aren't a believer and want to try the patch yourself, this is easy, just run `review apply X` where X is the MR id.

# Wish list

1. lint support
2. CI integration
