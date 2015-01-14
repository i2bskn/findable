# Findable

[![Gem Version](https://badge.fury.io/rb/findable.svg)](http://badge.fury.io/rb/findable)
[![Build Status](https://travis-ci.org/i2bskn/findable.svg)](https://travis-ci.org/i2bskn/findable)
[![Coverage Status](https://img.shields.io/coveralls/i2bskn/findable.svg)](https://coveralls.io/r/i2bskn/findable)
[![Code Climate](https://codeclimate.com/github/i2bskn/findable/badges/gpa.svg)](https://codeclimate.com/github/i2bskn/findable)

Redis wrapper with API like ActiveRecord. (While creating...)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "findable"
```

And then execute:

    $ bundle

## Usage

```ruby
class Company < ActiveRecord::Base
  has_many :person
end

class Person < Findable::Base
  fields :name, :email, :gender, :company_id
  belongs_to :company
end

person = Person.new(name: "Ken Iiboshi", gender: "male")
person.email = "i2bskn@example.com"
person.save

people = Person.where(gender: "male")
people.each do |person|
  puts person.name
end
```

## Contributing

1. Fork it ( https://github.com/i2bskn/findable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

