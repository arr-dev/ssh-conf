# ssh-config


Gem which prints [ssh_config(5)](http://linux.die.net/man/5/ssh_config) for given hosts.

It uses `net-ssh` gem to parse config files.

## Installation

    $ gem install ssh-config

## Usage

    Usage: ssh-config [options]
        -a, --all                        Search all default SSH config files on system
            --files FILES                Comma separated list of files to process
        -p, --pretty                     Pretty output
        -f, --format format              Output format (text, json)
        -h, --help                       Show this message

By defaults it outputs config in plain text, tab separated format.

It can be changed to ouput to JSON, pretty JSON or pretty-ish text.

Only `~/.ssh/config` files is parsed by default.

## Thanks

Thanks to the creators of [net-ssh](https://github.com/net-ssh/net-ssh) gem for parsing logic.

