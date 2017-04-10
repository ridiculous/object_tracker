require 'benchmark'
require 'object_tracker/version'

module ObjectTracker
  autoload :TrackerMethod, 'object_tracker/tracker_method'

  # @param method_names [Array<Symbol>] method names to track
  # @option :except [Array<Symbol>] method names to NOT track
  # @option :before [Proc] proc to call before method execution (e.g. ->(_name, _context, *_args) {})
  # @option :after [Proc] proc to call after method execution (e.g. ->(_name, _context, *_args) {})
  def track_all!(method_names = [], **options)
    ObjectTracker.(self, method_names, **options)
    self
  end

  class << self
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
  # @option :before [Proc] proc to call before method execution (e.g. ->(_name, _context, *_args) {})
  # @option :after [Proc] proc to call after method execution (e.g. ->(_name, _context, *_args) {})
  def self.call(obj, method_names = [], except: [], **options)
    class_methods = []
    inst_methods = []
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
    obj.send :extend, ObjectTracker.define_tracker_mod(obj, :TrackerExt, ObjectTracker.build_tracker_mod(class_methods, options))
    if inst_methods.any?
      obj.send :prepend, ObjectTracker.define_tracker_mod(obj, :InstanceTrackerExt, ObjectTracker.build_tracker_mod(inst_methods, options))
    end
    obj
  end

  def self.define_tracker_mod(context, name, mod)
    context = context.class unless context.respond_to?(:const_set)
    context.const_set name, mod
  end

  # @param trackers [Array<TrackerMethod>]
  # @option :mod [Module] module to add tracking to, will be mixed into self
  # @option :before [Proc] proc to call before method execution (e.g. ->(_name, _context, *_args) {})
  # @option :after [Proc] proc to call after method execution (e.g. ->(_name, _context, *_args) {})
  def self.build_tracker_mod(trackers, mod: Module.new, before: nil, after: nil)
    ObjectTracker.tracker_hooks[:before] << before if before
    ObjectTracker.tracker_hooks[:after] << after if after
    Array(trackers).each do |tracker|
      mod.module_eval <<-RUBY, __FILE__, __LINE__
        def #{tracker.name}(*args)
          ObjectTracker.call_tracker_hooks(:before, "#{tracker.display_name}", self, *args)
          result, message = ObjectTracker.call_with_tracking("#{tracker.display_name}", args, "#{tracker.source}") { super }
          puts message
          result
        ensure
          ObjectTracker.call_tracker_hooks(:after, "#{tracker.display_name}", self, *args)
        end
      RUBY
    end
    mod
  end

  # @note If we don't rescue, watch out for segfaults o.0
  def self.call_tracker_hooks(key, method_name, context, *args)
    tracker_hooks[key].each do |hook|
      hook.call(context, method_name, *args) rescue nil
    end
  end

  def self.call_with_tracking(method_name, args, source)
    result = nil
    msg = %Q(   * called "#{method_name}" )
    msg << "with " << ObjectTracker.format_args(args) unless args.empty?
    msg << "[#{source}]"
    bm = Benchmark.measure do
      result = yield rescue nil
    end
    [result, msg << " (%.5f)" % bm.real]
  end

  def self.format_args(args)
    result = "["
    args.each do |arg|
      result << (arg ? arg.to_s : "nil")
      result << ", "
    end
    result.sub! /,\s\z/, ""
    result << "] "
  end

  def self.tracker_hooks
    @__tracker_hooks ||= Hash.new { |me, key| me[key] = [] }
  end
end
