# ObjectTracker

Track method calls to any object. Both class and instance methods can be tracked with params

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
#=> inspect called from (irb):27
Dog.new.fetch('Hudog')
#=> called new from (irb):27
#=> called fetch with Hudog from (irb):27
#=> Fetch the ball Hudog!
```

Or just track single method:

```ruby
Dog.track! :fetch
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/object_tracker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
