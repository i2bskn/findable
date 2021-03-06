# Findable

[![Gem Version](https://badge.fury.io/rb/findable.svg)](http://badge.fury.io/rb/findable)
[![Build Status](https://travis-ci.org/i2bskn/findable.svg?branch=master)](https://travis-ci.org/i2bskn/findable)
[![Coverage Status](https://coveralls.io/repos/i2bskn/findable/badge.svg?branch=master)](https://coveralls.io/r/i2bskn/findable?branch=master)
[![Code Climate](https://codeclimate.com/github/i2bskn/findable/badges/gpa.svg)](https://codeclimate.com/github/i2bskn/findable)

Redis wrapper with API like ActiveRecord.

## Requirements

- Redis 2.8 or later

## Installation

Add this line to your application's Gemfile:

```ruby
gem "findable"
```

And then execute:

```
$ bundle
```

Setup config file and seed script:

```
$ rails generate findable:install
```

Added following files:

- `config/initializers/findable.rb`
    - Config file for Findable.
- `db/findable_seeds.rb`
    - Seed script for Findable.
- `db/findable_seeds/.keep`
    - Directory for storing seed files of Findable.

## Usage

Create seed file if static data.

Example `db/findable_seeds/tags.yml`:

```yaml
data1:
  id: 1
  name: Ruby
```

Create model.

Example `app/models/tag.rb`:

```ruby
class Tag < Findable::Base
end
```

Execute seed script if you create seed files.

```
$ rake findable:seed
```

Manipulate data with API like ActiveRecord.

```
$ rails console
pry(main)> Tag.find(1)
=> #<Tag id: 1, name: "Ruby">
pry(main)> golang = Tag.create(name: "Go")
=> #<Tag id: 2, name: "Go">
pry(main)> Tag.all.each {|tag| p tag.name }
"Ruby"
"Go"
=> [#<Tag id: 1, name: "Ruby">, #<Tag id: 2, name: "Go">]
```

## Associations

It is possible to use the `belongs_to` and `has_one` and `has_many`.
Mutually can refer to objects of ActiveRecord and Findable.

```ruby
class Article < ActiveRecord::Base
  include Findable::Associations::ActiveRecordExt
  belongs_to :tag
end

class Tag < Findable::Base
  has_many :articles
end
```

## Contributing

1. Fork it ( https://github.com/i2bskn/findable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
