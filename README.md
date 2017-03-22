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
By default ActiveRecord::Base.logger

+ Specify list of models
```ruby
ActiveRecord::OverflowSignalizer.new(models: [ModelName])
```
By default it retrieve all descendants of ActiveRecord::Base

+ Specify count of days. Gem start notify you if some primary key will overflow over the next numbers of days.
```ruby
ActiveRecord::OverflowSignalizer.new(days_count: 360)
```
60 days by default

+ You can use own signalizer for sending notification to e-mail, slack, hipchat, etc.
```ruby
class MyAwesomeSignalizer
  def initialize(some_params)
    @notifier = SomeChatNotifier.new(some_params)
  end

  def signalize(msg)
    @notifier.send_msg(msg)
  end
end

ActiveRecord::OverflowSignalizer.new(signalizer: MyAwesomeSignalizer.new(some_params))
```
By default it use only logging

## Development

For tests you need postgresql connection specified in `spec/database.yml`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/funbox/activerecord-overflow_signalizer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

