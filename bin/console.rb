#!/usr/bin/env ruby

require 'bundler/setup'
require 'pp'
require 'object_tracker'
require 'irb'

class Wut
  extend ObjectTracker

  def initialize
    @data = []
    @info = { name: 'foo', weight: 20 }
  end

  def to_s
  end
  track_all!
end

IRB.start
