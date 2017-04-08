require 'benchmark'
require 'object_tracker/version'

module ObjectTracker
  # @note If we don't rescue, we get a segfault. If we rescue and puts exception, we get a segfault. This is an extremely sensitive method
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
    puts msg << " (%.5f)" % bm.real
    result
  end

  def self.format_args(args, result = '')
    args.each do |arg|
      result << arg.to_s
    end
    result
  end

  def track(*method_names)
    method_names.each do |method_name|
      next if tracking?(method_name) || track_reserved_methods.include?(method_name)
      if respond_to?(method_name)
        track!(method_name => track_with_source(self, method_name))
      elsif respond_to?(:instance_methods) && instance_methods.include?(method_name)
        track!(method_name => track_with_source(inst, method_name))
      else
        fail UntrackableMethod, method_name
      end
    end
    nil
  end

  def tracking?(method_name)
    !tracking.detect { |_display_name, tracking_info| tracking_info[:name] == method_name }.nil?
  end

  def track_not(*method_names)
    method_names.each do |method_name|
      track_reserved_methods << method_name unless track_reserved_methods.include?(method_name)
    end
    nil
  end

  # @param method_names [Array<Symbol>] method names to track
  # @option :except [Array<Symbol>] method names to NOT track
  # @option :before [Proc] proc to call before method execution (e.g. ->(_name, _context, *_args) {})
  # @option :after [Proc] proc to call after method execution (e.g. ->(_name, _context, *_args) {})
  def track_all!(method_names = [], context = self, except: [], before: nil, after: nil)
    except = Array(except)
    track_not *except if except.any?
    if method_names.any?
      track_methods(method_names, context)
    else
      track_methods(methods, context)
      if respond_to?(:instance_methods)
        if respond_to?(:instance)
          track_methods(instance.methods - methods, instance)
        elsif respond_to?(:allocate)
          track_methods(instance_methods - methods, allocate)
        end
      end
    end
    track! method_names, before: before, after: after
  end

  #
  # PRIVATE
  #

  # @param method_names [Array<Symbol>]
  # @option :mod [Module] module to add tracking to, will be mixed into self
  # @option :mod_name [String] name for the extended module
  # @option :before [Proc] proc to call before method execution (e.g. ->(_name, _context, *_args) {})
  # @option :after [Proc] proc to call after method execution (e.g. ->(_name, _context, *_args) {})
  def track!(method_names = [], mod: Module.new, mod_name: "ObjectTackerExt", before: nil, after: nil)
    ObjectTracker.tracker_hooks[:before] << before if before
    ObjectTracker.tracker_hooks[:after] << after if after
    trackers = method_names.any? ? tracking.select { |_display_name, info| method_names.include?(info[:name]) } : tracking
    trackers.each do |display_name, tracker|
      mod.module_eval <<-RUBY, __FILE__, __LINE__
        def #{tracker[:name]}(*args)
          ObjectTracker.call_tracker_hooks(:before, "#{display_name}", self, *args)
          ObjectTracker.call_with_tracking("#{display_name}", args, "#{tracker[:source]}") { super rescue nil }
        ensure
          ObjectTracker.call_tracker_hooks(:after, "#{display_name}", self, *args)
        end
      RUBY
    end
    mod.module_eval <<-RUBY, __FILE__, __LINE__
      def self.prepended(base)
        base.extend(self)
      end
    RUBY
    # Handle both instance and class level extension
    if Class === self
      const_set(mod_name, mod)
      prepend(mod)
    else
      self.class.const_set(mod_name, mod)
      extend(mod)
    end
  end

  # @param method_names [Array<Symbol>]
  def track_methods(method_names, obj = self)
    (method_names - track_reserved_methods).each do |method_name|
      track_with_source(obj, method_name)
    end
  end

  def track_with_source(obj, method_name)
    source = obj.method(method_name).source_location || ['RUBY CORE']
    if Class === obj || Module === obj
      name = obj.name
      prefix = '.'
    elsif obj.class === Class
      prefix = '.'
      name = obj.class.name
    else
      prefix = '#'
      name = obj.class.name
    end
    tracking["#{name}#{prefix}#{method_name}"] = { context: obj,
                                                   name: method_name,
                                                   source: source.join(':').split('/').last(5).join('/') }
  end

  def tracking
    @__tracking ||= {}
  end

  def self.tracker_hooks
    @__tracker_hooks ||= Hash.new { |me, key| me[key] = [] }
  end

  def track_reserved_methods
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
end
