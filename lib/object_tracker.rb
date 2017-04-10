require 'benchmark'
require 'object_tracker/version'

module ObjectTracker
  # @param method_names [Array<Symbol>] method names to track
  # @option :except [Array<Symbol>] method names to NOT track
  # @option :before [Proc] proc to call before method execution (e.g. ->(_name, _context, *_args) {})
  # @option :after [Proc] proc to call after method execution (e.g. ->(_name, _context, *_args) {})
  def track_all!(method_names = [], except: [], **options)
    class_methods = []
    inst_methods = []
    if Array(method_names).any?
      Array(method_names).each do |method_name|
        if methods.include?(method_name)
          class_methods << TrackerMethod.new(self, method_name)
        elsif respond_to?(:instance_method)
          inst_methods << TrackerMethod.new(self, method_name, :instance_method)
        end
      end
    else
      if respond_to?(:instance_methods)
        (instance_methods - reserved_tracker_methods - Array(except)).each do |method_name|
          inst_methods << TrackerMethod.new(self, method_name, :instance_method)
        end
      end
      (methods - reserved_tracker_methods - Array(except)).each do |method_name|
        class_methods << TrackerMethod.new(self, method_name)
      end
    end
    mod = ObjectTracker.build_tracker_mod(class_methods, options)
    extend mod
    if inst_methods.any?
      inst_mod = ObjectTracker.build_tracker_mod(inst_methods, options)
      prepend inst_mod
    end
    self
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
          result, message = ObjectTracker.call_with_tracking("#{tracker.display_name}", args, "#{tracker.source}") { super rescue nil }
          result
        ensure
          $stdout.sync = true
          $stdout.puts message
          $stdout.flush
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
      result = yield
    end
    [result, msg << " (%.5f)" % bm.real]
  end

  def self.format_args(*args)
    result = ""
    args.each do |arg|
      result += (arg.nil? ? 'nil' : arg.to_s)
    end
    result + " "
  end

  def self.tracker_hooks
    @__tracker_hooks ||= Hash.new { |me, key| me[key] = [] }
  end

  #
  # Private
  #

  def define_tracker_mod(mod_name: 'ObjectTackerExt')
    "#{@prefix == '.' ? 'Class' : 'Instance'}#{mod_name}#{@name.to_s.upcase.gsub(/\W/, '')}"
  end

  def reserved_tracker_methods
    @__reserved_methods ||= begin
      names = [:__send__]
      names.concat [:default_scope, :current_scope=] if defined?(Rails)
      names
    end
  end

  class UntrackableMethod < StandardError
    def initialize(method_name)
      super "Can't track :#{method_name} because it's not defined on this class or it's instance"
    end
  end

  class TrackerMethod
    attr_accessor :name, :context, :finder, :display_name

    def initialize(context, name, finder = :method)
      @name = name
      @context = context
      @finder = finder
      if Class === context || Module === context
        @obj = context
        @prefix = '.'
      elsif context.class === Class
        @prefix = '.'
        @obj = context.class
      else
        @prefix = '#'
        @obj = context.class
      end
      @display_name = "#{@obj.name}#{@prefix}#{@name}"
    end

    def source
      return @source if defined? @source
      @source = @context.send(finder, name).source_location
      @source = @source ? @source.join(':').split('/').last(5).join('/') : 'RUBY CORE'
    end
  end
end
