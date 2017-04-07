#!/usr/bin/env ruby

require 'bundler/setup'
require 'pp'
require 'object_tracker'
require 'singleton'
require 'irb'

module Mixin
  def call
    "Mixin it"
  end
end

class Wut
  include Mixin
  extend ObjectTracker

  def self.method_calls
    @method_calls ||= Hash.new(0)
  end

  def initialize
    @data = []
    @info = { name: 'foo', weight: 20 }
  end

  def info
    @info
  end

  def to_s
  end

  def huh?
    ??
  end

  track_all! before: ->(_context, name, *_args) { Wut.method_calls[name] += 1 }, except: :method_calls
end

class Example
  include Singleton
  extend ObjectTracker
  attr_accessor :keep, :strip

  def _dump(depth)
    # this strips the @strip information from the instance
    Marshal.dump(@keep, depth)
  end

  def self._load(str)
    instance.keep = Marshal.load(str)
    instance
  end
  track_all!
end


IRB.start
