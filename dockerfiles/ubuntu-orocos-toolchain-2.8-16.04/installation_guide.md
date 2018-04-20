# Installation guide for Orocos Toolchain 2.8 for Ubuntu 16.04

## From jakutenshi/ubuntu-dev:latest

As base image used jakutenshi/ubuntu-dev:latest - 16.04 version. libboost already in image.

## Step 1

Setup our container:

```
# git config --global user.name "JAkutenshi"
# git config --global user.email jakutenshi@gmail.com
# apt-get update
# apt-get install ruby-dev bundler clang
# git clone https://github.com/orocos-toolchain/build.git
# cd build/
# git checkout toolchain-2.8-16.04
```
### Step 2

Let's try to setup orocos toolchain:

```
# mkdir ~/orocos
# cd ~/orocos
# sh ~/build/bootstrap.sh
```

**IT'S ALL OK** It should crash whith something like that:

```
Command failed
git:https://github.com/orocos-toolchain/autoproj.git branch=add_pkgconfig_osdep interactive=false push_to=git@github.com:/orocos-toolchain/autoproj.git repository_id=github:/orocos-toolchain/autoproj.git retry_count=10(/root/orocos/.autoproj/remotes/github__orocos_toolchain_autoproj_git): failed in import phase
  cannot resolve refs/remotes/autobuild/add_pkgconfig_osdep
  autoproj failed to update your configuration. This means most of the time that there
  was an temporary network problem. You can try to manually complete the bootstrap by
typing these three commands::
  . env.sh
  autoproj update
  autoproj build
```

It's ok. Now you should edit ./autoproj/manifest file at line 3:
> branch: add_pkgconfig_osdep

replace by
> branch: master

### Step 3

Next try:

```
 sh ../build/bootstrap.sh
```

Yes, it crushes too with something like this:

```
 ERROR: typelib is selected in the manifest or on the command line, but it is excluded from the build: gccxml is marked as unavailable for this operating system (dependency chain: typelib>gccxml)
autoproj failed to update your configuration. This means most of the time that there
was an temporary network problem. You can try to manually complete the bootstrap by
typing these three commands::
 . env.sh
 autoproj update
 autoproj build
```




