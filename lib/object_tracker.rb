require 'benchmark'
require 'object_tracker/version'

fail "ObjectTracker #{ObjectTracker::VERSION} only supports Ruby 2+" if RUBY_VERSION < '2.0.0'

module ObjectTracker
  def track(*args)
    args.each do |method_name|
      next if tracking?(method_name) || track_reserved_methods.include?(method_name)
      if respond_to?(method_name)
        track!(method_name => track_with_source(self, method_name))
      elsif respond_to?(:allocate)
        inst = allocate
        if inst.respond_to?(method_name)
          track!(method_name => track_with_source(inst, method_name))
        else
          fail UntrackableMethod, method_name
        end
      else
        fail UntrackableMethod, method_name
      end
    end
    nil
  end

  def tracking?(method_name)
    tracking.keys.include?(cleanse(method_name).to_sym)
  end

  def track_not(*args)
    args.each do |method_name|
      track_reserved_methods << method_name unless track_reserved_methods.include?(method_name)
    end
    nil
  end

  def track_all!(*args)
    track_not *args if args.any?
    track_methods_for(self)
    track_methods_for(allocate) if respond_to?(:allocate)
    track!
  end

  #
  # PRIVATE
  #

  def cleanse(str)
    str.to_s.sub(/^[#.]/, '')
  end

  def track!(method_names = nil)
    mod = Module.new
    Array(method_names || tracking).each do |method_name, source_def|
      mod.module_eval <<-RUBY, __FILE__, __LINE__
        def #{cleanse(method_name)}(*args, &block)
          msg = %Q(   * called "#{method_name}" )
          msg << "with " << args.join(', ') << " " if args.any?
          msg << "[#{source_def}]"
          result = nil
          time = Benchmark.realtime { result = super }
          msg << " (" << time.to_s << ")"
          puts msg
          result
        rescue NoMethodError => e
          raise e if e.message !~ /no superclass/
        end
      RUBY
    end

    mod.module_eval <<-RUBY, __FILE__, __LINE__
      def self.prepended(base)
        base.extend(self)
      end
    RUBY

    # Handle both instance and class level extension
    if respond_to?(:prepend)
      prepend(mod)
    else
      extend(mod)
    end
  end

  def track_methods_for(obj)
    (obj.methods - track_reserved_methods).each do |method_name|
      track_with_source(obj, method_name)
    end
  end

  def track_with_source(obj, method_name)
    source = obj.method(method_name).source_location || ['RUBY CORE']
    prefix = obj.class == Class ? '.' : '#'
    tracking["#{prefix}#{method_name}".to_sym] = source.join(':').split('/').last(5).join('/')
  end

  def tracking
    @__tracking ||= {}
  end

  def track_reserved_methods
    @__reserved_methods ||= [
      :!,
      :!=,
      :!~,
      :<,
      :<=,
      :<=>,
      :==,
      :===,
      :=~,
      :>,
      :>=,
      :[],
      :[]=,
      :__id__,
      :__send__,
      :`,
      :public_send,
      :send,
      :class,
      :object_id,
      :track,
      :tracking?,
      :track_not,
      :track_all!,
      :track!,
      :track_methods_for,
      :track_with_source,
      :tracking,
      :track_reserved_methods
    ]
  end

  class UntrackableMethod < StandardError
    def initialize(method_name)
      super "Can't track :#{method_name} because it's not defined on this class or it's instance"
    end
  end
end