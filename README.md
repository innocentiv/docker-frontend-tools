# Docker Frontend Tools

This docker image provides some executables for common frontend-build-chains,
that are needed in most current projects. Ever had a hassle installing
node and the correct version of sass to compile a specific projects CSS
and JS Files? That's what this is all about.

Note: this is a fork of webgefrickel/docker-frontend-tools created for my own 
benefit. I use ubuntu 16.04LTS on my workstation so I added gosu to fix files 
permissions.


## What's included?

After building, the following executables will be available through the docker-image:

  - ruby
    - sass (@3.4.22)
    - compass (@1.0.3)
    - scss-lint
  - node
    - gulp (@3.9.1)
    - grunt-cli (@1.2.0)
    - bower
    - browserify
    - eslint
    - jsonlint
    - npm-check-updates
    - stylestats
    - foundation-cli

Normally you don't need all of these, because most of those tools will come
encapsulated in gulp- or grunt-tasks (grunt-eslint, gulp-stylestats etc. come
with their own bundled versions of eslint and stylestats).  So by default this
package only specifies versions for the most needed tools: grunt, gulp, sass
and compass.

## Installing

Note: I'm on ubuntu 16.04LTS, and have not tested this anywhere else.

Clone this repository, change to the directory and build your docker-image:

```
git clone git@github.com:webgefrickel/docker-frontend-tools.git
cd docker-frontend-tools
docker build -t docker-frontend-tools .
```

This will take a while, depending on your system and internet connection.
After it is done, you have will have a tagged docker-image with everything
you need to get started!

## Usage

So, how do you run gulp, sass and all the others with the code somewhere
one your machine? Open up your terminal, change to your project folder
(usually, where node\_modules and package.json are and from where you would
run your gulp/grunt-tasks etc.). Let's say you want to run `gulp build`,
but now using the gulp, that's inside of docker. The command is:

`docker run -it --rm -e LOCAL_USER_ID=$UID -v $(pwd)/:/code/ docker-frontend-tools gulp build`

Ugly, isn't it? Some explanation:

- `-it` runs the docker command as an interactive shell
- `--rm` remove the container after exit
- `-e` set the LOCAL_USER_ID variable for the creation of the user inside the container
- `-v` mounts your current local directory (`$(pwd)`) into docker as a working directory under `/code/`, so that the gulp/sass etc. inside docker can access your local source files
- `docker-frontend-tools gulp build` runs gulp build in the just created docker image

And thats about it. Just keep to that pattern, and everything should work
just fine. E.g. if you want to run just a sass watch task, it should
look like this:

`docker run -it --rm -e LOCAL_USER_ID=$UID -v $(pwd)/:/code/ docker-frontend-tools sass --watch src/main.scss:dist/main.css`

I would recommend creating an alias as a simple wrapper, just add this to
your ~/.bash_aliases :

```
# docker run frontend-tools
alias drft='sudo docker run -it --rm -e LOCAL_USER_ID=$UID -v $(pwd)/:/code/ docker-frontend-tools'
```

and use it like this: `drft gulp build` or `drft sass ...`

## But my project needs sass 3.2 and an old version of grunt!

Edit the Dockerfile, change the version-numbers on top. If any tools are
missing, just add them at the correct place (where all the other `npm install`
and `gem install` commands are) and then rebuild the image using:

`docker build --no-cache -t docker-frontend-tools-legacy-sass-grunt .`

See what I did here? I changed the tag on the image (the `-t` part), so I can
have different images with different versions (and use them how I want).
You only have to specify the correct image name in the `docker run` command
and everything should work fine.

## Known issues / bugs

For now, using the executables from this docker-image to build your sources
via dockervolumes (the -v part of the commands above) is *incredibly* slow
on OS X. This is due to the lack of native volume-mounting: everything is
done through VirtualBox, and this makes it slow. On my machine it almost took
10 times as long as with the locally installed versions. This is a known problem
and the boot2docker-team is working on it (volume-mounts via NFS etc.):
[Issue 593](https://github.com/boot2docker/boot2docker/issues/593),
[Issue 631](https://github.com/boot2docker/boot2docker/issues/631)

And some watch-tasks are killing the CPU as well. *sigh* Gotta get myself
a linux box and test it there, without the VirtualBox-Wrapper :-/

Mounting a local folder in docker only works, if this folder is somewhere
in `/Users/` on your system.

One thing I haven't figured out yet is dockers port-forwarding, meaning:
If you have a browser-sync or livereload-task running, I have no clue
how to access the browser-sync proxy etc. running in docker from your
local machine. Meh :-/
