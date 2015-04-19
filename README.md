# Overview

Logformat is an IRC bot that logs into a database, and a web frontend to show these logs.

# History

Logformat is the reincarnation of an earlier, ehrm, system that transformed log files from my [irssi](http://www.irssi.org) setup into something resembling HTML. Along the way, it employed horrible spaghetti code and chains of regular expressions.

# Components

All executable components live in [bin](bin/). They share models and helpers from [lib](lib/), including the basic configuration logic and database access.

## `bot.rb`

The IRC bot. It will connect to one IRC network, join all channels in the database that have the `join` flag set, listen for and record all messages.

## `web.rb`

A [Sinatra](http://sinatrarb.com) web app that displays the logs, one day at a time, for all channels. It employs a simple [ACL](#access-control-lists) scheme to allow restricted access to certain channels.

## `import.rb`

A script to read, parse and store the Irssi logfiles. It tries to avoid duplicates, but since the bot's recorded messages have second precision but the logfiles only minutes, importing logs from times when the bot was listening will lead to duplication.

## `console.rb`

A [pry](http://pryrepl.org) REPL with all libraries preloaded. Currently, this is the only admin interface.

## `dump.rb`

A simplistic script to dump the whole database in plain text format. Note that the format is currently _not_ supported by the parser employed by `import.rb`.

# Configuration

Runtime configuration is performed through environment variables. These are:

* `DB`: URI for database access, e.g. `postgres://user:pass@localhost/database`. Default: `sqlite://local.db` (i.e. the `local.db` file in the current directory).
* `PORT`: listen port for the web component. The web component will only listen on the local interface, use a web server like [nginx](http://nginx.org) to proxy. See below for a configuration example.
* `SERVER`: IRC server to connect to. Default: `irc.freenode.net`
* `NICK`: Nickname to connect with. Default: `logformat`

## nginx configuration example

Proxy to the web interface using `proxy_pass`, and pass the `host` header:

```nginx
location / {
  proxy_pass http://localhost:8080;
  proxy_set_header Host $host;
}
```

## A note about database support

Currently, the default database is [SQLite 3](https://sqlite.org). It is also used for tests (as an in-memory databse). However, it is recommended to use [Postgres](http://postgresql.org) for real use-cases, it is much faster and more stable. I have encountered severe concurrency problems with all but Postgres during multithreaded imports.

It is very likely that sooner or later Postgres will be the only supported database backend.

# Access Control Lists

Web access to a channel is controlled by a simple list of yes/no rules (the [Permission](lib/models/permission.rb) model). The default is to allow access. Users are authenticated using HTTP Basic authentication. Unauthenticated users are represented by the special "anonymous" user.

To disable anonymous access to a channel, start the console and run

```ruby
channel = Channel.find(:name => '#mychannel')
channel.deny_anonymous!
```

To create a user and allow access to the channel for them,

```ruby
user = User.create(:name => 'joe', :password => 'password', :password_confirmation => 'password')
channel.allow!(user)
```
