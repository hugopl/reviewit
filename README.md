[![Build Status](https://travis-ci.org/hugopl/reviewit.svg?branch=master)](https://travis-ci.org/hugopl/reviewit)
[![Code Climate](https://codeclimate.com/github/hugopl/reviewit/badges/gpa.svg)](https://codeclimate.com/github/hugopl/reviewit)

![Logo](./app/webpacker/images/logo.png)

# Review it!

Review it! is a review tool for git-based projects.

## Features

For the sake of simplicity, the work/review processes is split in two components:

- Command-line tool (requesting review for patches)
- Web-based code review dashboard

## Installing

You need ruby at least 2.2.2, then install the gem dependencies.

```
$ bundle install --without development,test
```

Then create a postgres database called `reviewit` and run:

```
$ bin/setup
```

For more information about database configuration look into Rails documentation and edit the file `config/database.yml`.

Now you need to configure a reverse proxy with unicorn of some other web server do you plan to use, if you just want to
look at reviewit while waste time configuring [Ngix](http://nginx.org/) and [Unicorn](https://unicorn.bogomips.org/),
just run:

```
$ RAILS_ENV=production RAILS_SERVE_STATIC_FILES=1 unicorn_rails
```

Reviewit! execute git commands using sidekiq, so you need a redis-server running and accessible by Sidekiq, to start sidekiq
in the development environment, use `bundle exec sidekiq`, if you are using the deploy script sidekiq is automatically started
by it.

To configure mail delivery options check the file `config/reviewit.yml`.

## Setting up your Project

1. Register your project in the web interface (just needs a name, repository URL and a list of people involved on the project)
2. Go to the directory where your project working copy is.
3. Type the command you saw in the web interface.

## Workflow for Writing Code

### Creating a Merge Request

1. Write some code!
2. Commit it to git like you are used to do
3. Feeling ready for review? Just run `review push BRANCH` command.

Your patch will be posted for review. Once accepted, it will be merged into ``BRANCH``.

e.g. `review push 3.4.0` will create a merge request with your HEAD commit targeting the 3.4.0 branch.

### Updating a Merge Request

1. Write some code!
2. Update your existing patch (git commit --amend)
3. Run `review push` command.

## Workflow for Reviewing Patches

### Accepting a Merge Request

Go to web interface and click accept and the patch should be merged, or run `review accept X` where X is the MR id.

Reviewit will try to apply and commit your patch (git am), it will tell you if it can't. And if it can't, solve the conflicts (git rebase) then send it again for review.

### List Pending Reviews for your Project

Just run `review list`.

### Open a Review in your Browser

Just run `review open X`, where X is the MR id, you can see the MR ids when listing pending reviews.

If X is ommited it will open the current review, if it exists.

### Open a Review in your Terminal

Don't want to wait the browser to start up? Just run `review show X`, where X is the MR id.

### Abandon a Review

You can do it on web interface or by running `review cancel`.

### Applying a patch from some MR on your working copy

Sometimes you aren't a believer and want to try the patch yourself, this is easy, just run `review apply X` where X is the MR id.

### Clean up dead/reviewed branches

Do `review cleanup`, it will issue a `git remote prune <your_remote>` and remove all local branches for merge requests
already accepted or abandoned.
