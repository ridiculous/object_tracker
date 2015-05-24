# ObjectTracker

Track method calls to almost any object. Class and instance methods can be tracked (w/ arguments).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'object_tracker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install object_tracker

## Usage

```ruby
class Dog
  extend ObjectTracker

  def fetch(name)
    "Fetch the ball #{name}!"
  end
end

Dog.track_all!
Dog
    * called "#inspect" [RUBY CORE]
#=> Dog
Dog.new.fetch('Hudog')
    * called ".new" [RUBY CORE]
    * called "#fetch" with Hudog [(irb):4]
#=> Fetch the ball Hudog!
```

Or just track single method:

```ruby
Dog.track :name
```

Or track methods for a single object:

```ruby
class Go
  def fish
    'We go!'
  end
end

a = Go.new
a.extend ObjectTracker
a.track_all!
```

## Troubleshooting

Having problems? Maybe a specific method is throwing some obscure error? Try ignoring that method, so we can get back on track!

```ruby
Dog.track_not :bad_doggy
Dog.track_all! #=> will exclude tracking for :bad_doggy
```

## Issues

* Doesn't work well (or at all) when trying to track Ruby core objects (`String`, `Array`, etc). You can work around this by
 subclassing the target class before extending with `ObjectTracker`. For example:

  ```ruby
  class MyArray < Array
  	extend ObjectTracker
  end
  ```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/object_tracker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
