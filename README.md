# ActiveRecord::OverflowSignalizer

One day primary key field will overflow, but if you use this gem, you will know about it before it happened.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-overflow_signalizer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-overflow_signalizer

## Usage

Just placed it somewhere in your app:
```ruby
ActiveRecord::OverflowSignalizer.new.analyse!
```

By default it check all models in your application and log if some primary key will overflow soon or overflowed.

You can placed it in some job and perform it by [clockwork](https://github.com/adamwiggins/clockwork)
or just run it when app started in separated thread.

Also you can pass some parameters in initializer:

+ Specify logger
```ruby
ActiveRecord::OverflowSignalizer.new(logger: SomeCoolLogger)
```

+ Specify list of models
```ruby
ActiveRecord::OverflowSignalizer.new(models: [ModelName])
```

+ Specify count of days. Gem start notify you if some primary key will overflow over the next numbers of days.
```ruby
ActiveRecord::OverflowSignalizer.new(days_count: 360)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

For tests you need postgresql connection specified in `spec/database.yml`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/funbox/activerecord-overflow_signalizer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

