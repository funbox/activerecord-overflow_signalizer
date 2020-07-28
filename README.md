# ActiveRecord::OverflowSignalizer

[![Build Status](https://travis-ci.org/funbox/activerecord-overflow_signalizer.svg?branch=master)](https://travis-ci.org/funbox/activerecord-overflow_signalizer)

One day primary key field will overflow, but if you use this gem, you will know about it before it happens.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-overflow_signalizer'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install activerecord-overflow_signalizer
```

## Usage

Just place it somewhere in your app:

```ruby
ActiveRecord::OverflowSignalizer.new.analyse
```

By default it checks all models in your application and logs if some primary key will overflow soon or have already overflowed.
Also you can use unsafe method `#analyse!`, so it will raise error.

You can place it in some job and perform it by [clockwork](https://github.com/adamwiggins/clockwork)
or simply run it when app starts in a separate thread.

Also you can pass parameters to the initializer:

- Specify logger:

  ```ruby
  ActiveRecord::OverflowSignalizer.new(logger: SomeCoolLogger)
  ```

  By default `ActiveRecord::Base.logger`.

- Specify list of models:

  ```ruby
  ActiveRecord::OverflowSignalizer.new(models: [ModelName])
  ```

  By default it retrieves all descendants of `ActiveRecord::Base`.

- Specify a number of days:

  ```ruby
  ActiveRecord::OverflowSignalizer.new(days_count: 360)
  ```
  
  Gem starts to notify you if some primary key will overflow the passed number of days.

  `60` days by default.

- You can use your own `signalizer` for notification sending to e-mail, Slack, Hipchat, etc:

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
  
  By default it uses only logging.

## Development

For tests you need a PostgreSQL connection specified in `spec/database.yml`.

## Contributing

Bug reports and pull requests are welcome on GitHub at [github.com/funbox/activerecord-overflow_signalizer](https://github.com/funbox/activerecord-overflow_signalizer). 

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere 
to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[![Sponsored by FunBox](https://funbox.ru/badges/sponsored_by_funbox_centered.svg)](https://funbox.ru)
