# How to make a pull request with GitHub

## Create a GitHub account

You can skip this section if you are already a member of GitHub - meaning you have an account on GitHub.

If that is not the case, then first [create an account on GitHub](https://www.wikihow.com/Create-an-Account-on-GitHub).

## Fork the ReaR repository

If you never, ever, forked a respository on GitHub then you should first read "[Fork a repository](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo)" page on GutHub.

To make a fork of ReaR first open your browser and go to the [ReaR Github code page](https://github.com/rear/rear). If you are not yet logged in on Github then first do a sign in and then make a fork by clicking on the fork symbol in the upper right corner - see

<div align="right"><img src="../img/fork-rear.png" alt="A screenshot of the fork button"></div>

The forking process takes a couple of seconds and you go directly to the forked repository <username>/rear. 

## Clone the ReaR repository

From that moment on you can create a clone of the forked repository to your local system.

<div align="center"><img src="../img/clone-rear.png" alt="A screenshot of the cloning area"></div>

Copy/paste the URL of the SSH section and use that in a Linux window:

```bash
$ git clone git@github.com:YOURNAME/rear.git
$ cd rear
```

Once that is done you have to make your local ReaR repository aware that is is linked to the upstream master if you want to be able to make pull requests in alter phase:

```bash
$ git remote add upstream git@github.com:rear/rear.git
$ git checkout master
$ git fetch upstream
$ git merge upstream/master
```
## Make your working branch of the ReaR repository

At this point your local ReaR repository YOURNAME/rear is completely synced with the upstream master and now you are ready a create a working branch for a fix for an issue or new feature, e.g. issue2152-prep-bacula

```bash
$ git checkout -b issue2152-prep-bacula  upstream/master
Branch 'issue2152-prep-bacula' set up to track remote branch 'master' from 'upstream'.
Switched to a new branch 'issue2152-prep-bacula'
 git branch
* issue2152-prep-bacula
  master
```

In this ReaR repository you are the boss and are working completely independ from the upstream master branch. 
