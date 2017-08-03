# Ruby Object Tracker [![Gem Version](https://badge.fury.io/rb/object_tracker.svg)](http://badge.fury.io/rb/object_tracker)

An easy way to track Ruby objects. Logs class and instance method calls with arguments, file name, line number and 
execution time. Helpful for debugging and learning the language.

## Requirements

* Ruby 2+

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'object_tracker', '~> 2.1'
```

## Usage

```ruby
class Person
  extend ObjectTracker

  def greet(name)
    "ello, #{name}!"
  end
end
```

Track a single method:

```ruby
Person.track_all! :greet
```

Or track all methods (such as `to_s`, `object_id`, `respond_to?`, etc):

```ruby
Person.track_all!
```

Or track an instance:

```ruby
obj = Person.new.extend ObjectTracker
obj.track_all!
```

Or track an object without extending the class:
```ruby
ObjectTracker.(Person)
ObjectTracker.(Person, :greet)
ObjectTracker.(Person, except: :respond_to?)
ObjectTracker.(me = Person.new)
```
## Hook methods

Pass a proc (or anything that responds to `#call`) to the `:before` or `:after` options and they will be called before and after the method call,
respectively. This allows you to do things like track the number of methods calls.

```ruby
method_calls = Hash.new 0
slow_methods = Set.new []
hooks = [
  before: ->(context, name, args) { method_calls[name] += 1 },
  after: ->(context, name, args, duration) { slow_methods << name if duration > 0.05 }
]
ObjectTracker.(Person, *hooks)
```

## Logging

`ObjectTracker` uses the default Ruby [logger](http://ruby-doc.org/stdlib-2.4.1/libdoc/logger/rdoc/Logger.html) with a default `DEBUG` level

Silence logging

```ruby
ObjectTracker.logger.level = Logger::ERROR
```

## [Example] ActiveRecord Tracking

Tracking an ActiveRecord 3.2 model

```ruby
ObjectTracker.(u = User.first).audits;nil
#=>   User Load (0.3ms)  SELECT `users`.* FROM `users` LIMIT 1
#=> [2017-04-13T21:45:48.827952]  INFO -- ObjectTracker: following #<User:0x007f838d8cf560>
#=> [2017-04-13T21:45:48.828223] DEBUG -- ObjectTracker: User#class [RUBY CORE] (0.00000)
#=> [2017-04-13T21:45:48.838797] DEBUG -- ObjectTracker: User#association with [audits] [lib/active_record/associations.rb:155] (0.01073)
#=> [2017-04-13T21:45:48.838853] DEBUG -- ObjectTracker: User#audits [lib/active_record/associations/builder/association.rb:43] (0.01082)
```

## Troubleshooting

Having problems? Maybe a specific method is throwing some obscure error? Try ignoring that method, so we can get back on track!

```ruby
Person.track_all! except: :bad_method
```

## Extending Core Classes

`ObjectTracker` can't track core Ruby objects directly, such as `String` and `Array`. So don't even try it!

There is a workaround however! Simply extend a _subclass_ with `ObjectTracker`

```ruby
class List < Array
  extend ObjectTracker
end
List.track_all!
```

## Contributing

* Fork it
* Run tests with `rake` (just kidding, there are no tests)
* Boot a console with `bin/console`
* Make sure things still work
* Make changes and submit a PR to [https://github.com/ridiculous/object_tracker](https://github.com/ridiculous/object_tracker)

## License
MIT
