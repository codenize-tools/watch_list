# watch_list

watch_list is a tool to manage [Uptime Robot](https://uptimerobot.com/).

It defines Uptime Robot monitors using Ruby DSL, and updates monitors according to DSL.

[![Gem Version](https://badge.fury.io/rb/watch_list.svg)](http://badge.fury.io/rb/watch_list)
[![Build Status](https://travis-ci.org/winebarrel/watch_list.svg?branch=master)](https://travis-ci.org/winebarrel/watch_list)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'watch_list'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install watch_list

## Usage

```sh
export WATCH_LIST_API_KEY=u956-afus321g565fghr519

watch_list -e -o Robotfile
vi Robotfile
watch_list -a --dry-run
watch_list -a
```

## Help

```
Usage: watch_list [options]
        --api-key API_KEY
    -a, --apply
    -f, --file FILE
        --dry-run
    -e, --export
        --split
    -o, --output FILE
    -s, --status
        --encrypt
        --decrypt
        --no-color
        --debug
    -h, --help
```

## Robotfile example

```ruby
monitor "http monitor" do
  target "http://example.com"
  interval 5
  paused false
  alert_contact :email, "alice@example.com"
  type :http
end

monitor "keyword monitor" do
  target "http://example.com"
  interval 5
  paused false
  alert_contact :email, "alice@example.com"

  type :keyword do
    keywordtype :exists
    keywordvalue "Example Domain"
  end
end

monitor "ping monitor" do
  target "127.0.0.1"
  interval 5
  paused false
  alert_contact :email, "alice@example.com"
  type :ping
end

monitor "port monitor" do
  target "example.com"
  interval 5
  paused false
  alert_contact :email, "alice@example.com"

  type :port do
    subtype :http
    port 80
  end
end

alert_contact do
  type :email
  value "alice@example.com"
end
```

## Encryption

```sh
git config watch-list.pass "**secret password**"
git config watch-list.salt "nU0+G1icf70="
# openssl rand -base64 8

watch_list --encrypt "secret value"
```

```ruby
monitor "http monitor" do
  target "http://example.com"
  interval 5
  paused false
  alert_contact :email, "alice@example.com"

  type :http do
    httpusername "username"
    httppassword secure: "yI8mtdeyGrc16+wH9taw9g=="
  end
end
```

## Similar tools
* [Codenize.tools](http://codenize.tools/)
