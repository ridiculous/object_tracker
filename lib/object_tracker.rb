require 'logger'
require 'benchmark'
require 'object_tracker/version'

module ObjectTracker
  autoload :TrackerMethod, 'object_tracker/tracker_method'
  autoload :LogFormatter, 'object_tracker/log_formatter'

  # @param method_names [Array<Symbol>] method names to track
  # @option :except [Array<Symbol>] method names to NOT track
  # @option :before [Proc] proc to call before method execution (e.g. ->(name, context, args) {})
  # @option :after [Proc] proc to call after method execution (e.g. ->(name, context, args, duration) {})
  def track_all!(method_names = [], **options)
    ObjectTracker.(self, method_names, **options)
    self
  end

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new(STDOUT).tap do |config|
        config.formatter = LogFormatter.new
      end
    end

    def reserved_tracker_methods
      @__reserved_methods ||= begin
        names = [:__send__]
        names.concat [:default_scope, :current_scope=] if defined?(Rails)
        names
      end
    end
  end

  #= Utilities (not extended or mixed in)
  #
  # Tracks method calls to the given object
  #
  # @note Alias to .()
  #
  # @param obj [Object] class or instance to track
  # @param method_names [Array<Symbol>] method names to track
  # @option :except [Array<Symbol>] method names to NOT track
  # @option :before [Proc] proc to call before method execution (e.g. ->(name, context, args) {})
  # @option :after [Proc] proc to call after method execution (e.g. ->(name, context, args, duration) {})
  def self.call(obj, method_names = [], except: [], **options)
    class_methods, inst_methods = ObjectTracker.build_tracker_methods(obj, method_names, except: except)
    name = obj.to_s
    obj.send :extend, ObjectTracker.define_tracker_mod(obj, :TrackerExt, ObjectTracker.build_tracker_mod(class_methods, options))
    if inst_methods.any?
      # Silence all the noise about comparing class name and checking object behavior
      ObjectTracker.with_error_logging do
        obj.send :prepend, ObjectTracker.define_tracker_mod(obj, :InstanceTrackerExt, ObjectTracker.build_tracker_mod(inst_methods, options))
      end
    end
    logger.info { "following #{name}" }
    obj
  end

  def self.define_tracker_mod(context, name, mod)
    context = context.class unless context.respond_to?(:const_set)
    if context.const_defined?(name, false)
      context.send :remove_const, name
    end
    context.const_set name, mod
  end

  # @param trackers [Array<TrackerMethod>]
  # @option :mod [Module] module to add tracking to, will be mixed into self
  # @option :before [Proc] proc to call before method execution (e.g. ->(name, context, args) {})
  # @option :after [Proc] proc to call after method execution (e.g. ->(name, context, args, duration) {})
  def self.build_tracker_mod(trackers, mod: Module.new, before: nil, after: nil)
    ObjectTracker.tracker_hooks[:before] << before if before
    ObjectTracker.tracker_hooks[:after] << after if after
    Array(trackers).each do |tracker|
      mod.module_eval <<-RUBY, __FILE__, __LINE__
        def #{tracker.name}(*args)
          ObjectTracker.call_tracker_hooks(:before, "#{tracker.display_name}", self, args)
          result, message, duration = ObjectTracker.call_with_tracking("#{tracker.display_name}", args, "#{tracker.source}") { super }
          ObjectTracker.logger.debug { message  + " (%.5f)" % duration }
          result
        ensure
          ObjectTracker.call_tracker_hooks(:after, "#{tracker.display_name}", self, args, duration)
        end
      RUBY
    end
    mod
  end

  #
  # Private
  #

  def self.build_tracker_methods(obj, method_names, except: [])
    class_methods, inst_methods = [], []
    reserved = obj.respond_to?(:reserved_tracker_methods) ? obj.reserved_tracker_methods : ObjectTracker.reserved_tracker_methods
    obj_instance = obj.respond_to?(:allocate) ? obj.allocate : obj
    if Array(method_names).any?
      Array(method_names).each do |method_name|
        if obj.methods.include?(method_name)
          class_methods << TrackerMethod.new(obj, method_name)
        elsif obj.respond_to?(:instance_method)
          inst_methods << TrackerMethod.new(obj_instance, method_name)
        end
      end
    else
      if obj.respond_to?(:instance_methods)
        (obj.instance_methods - reserved - Array(except)).each do |method_name|
          inst_methods << TrackerMethod.new(obj_instance, method_name)
        end
      end
      (obj.methods - reserved - Array(except)).each do |method_name|
        class_methods << TrackerMethod.new(obj, method_name)
      end
    end
    return class_methods, inst_methods
  end

  # @note If we don't rescue, watch out for segfaults o.0
  def self.call_tracker_hooks(key, method_name, context, args, duration = nil)
    tracker_hooks[key].each do |hook|
      begin
        if duration
          hook.call(context, method_name, args, duration)
        else
          hook.call(context, method_name, args)
        end
      rescue Exception
        next
      end
    end
  end

  def self.call_with_tracking(msg, args, source)
    result = nil
    msg += ObjectTracker.format_args(args) unless args.empty?
    msg += " [#{source}]"
    bm = Benchmark.measure do
      result = yield rescue nil
    end
    [result, msg, bm.real]
  end

  def self.format_args(args)
    result = " with ["
    args.each do |arg|
      result << (arg ? arg.to_s : "nil")
      result << ", "
    end
    result.sub! /,\s\z/, ""
    result << "]"
  end

  def self.tracker_hooks
    @__tracker_hooks ||= Hash.new { |me, key| me[key] = [] }
  end

  def self.with_error_logging
    old_log_level, logger.level = logger.level, Logger::ERROR
    yield
  ensure
    logger.level = old_log_level if old_log_level
  end
end
