# Instructions on how to run things locally

We're using docker in production to compile and execute your bots. To make
things easier, the development setup should use docker.


The first step is to pick your language. Start by cloning one of the following repositories:

* [mob-ai-ruby](https://github.com/makeorbreak-io/mob-ai-ruby)
* [mob-ai-python](https://github.com/makeorbreak-io/mob-ai-python)
* [mob-ai-nodejs](https://github.com/makeorbreak-io/mob-ai-nodejs)
* [mob-ai-bash](https://github.com/makeorbreak-io/mob-ai-bash)
* [mob-ai-java](https://github.com/makeorbreak-io/mob-ai-java) (not available in production yet)

Each repository has a `bot.*` file, which you can use to start working. We're
limited to submitting one file for now, so please be aware of that.

After editing the bot file, build its docker image:

```shell
BOT_NAME=alice make
BOT_NAME=bob make
```

This will create two docker images, `robot-alice` and `robot-bob`.

To run a game between these two bots, start by cloning this repository and
installing dependencies (it requires ruby 2.5.0, whose installation
instructions are not covered here, but I'd suggest looking into
[asdf](https://github.com/asdf-vm/asdf)):

```shell
git clone https://github.com/makeorbreak-io/mob-ai
cd mob-ai/
bundle install
```

If everything went OK, you should be able to run the game by executing the following command:

```shell
bundle exec bin/compete.rb boards/10x10.json
```


# Logging

You **MUST NOT** print things to `stdout` or read things from `stdin`, as those
are the streams we're using for server-bot communication. Doing so will ruin
your bot.

Please use `stderr` to log things. Examples:

* In ruby: `STDERR.puts "debugging info"`
* In nodejs: `console.error("debugging info")`
* In python: `print("debugging info", file=sys.stderr)`
* In bash: `echo "debugging info" >&2`
* In java: `System.err.println("debugging info")`
