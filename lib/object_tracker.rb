require "object_tracker/version"

fail "ObjectTracker #{ObjectTracker::VERSION} only supports Ruby 2+" if RUBY_VERSION < '2.0.0'

module ObjectTracker
  def track(*args)
    @__tracking ||= []
    args.each { |arg| @__tracking << arg unless tracking?(arg) }
  end

  def track!(*args)
    track(*args)
    start_tracking!
  end

  def track_all!
    track!(*(methods + instance_methods))
  end

  def tracking?(method_name)
    @__tracking.include?(method_name)
  end

  def start_tracking!
    mod = Module.new
    @__tracking.each do |method_name|
      mod.module_eval <<-RUBY, __FILE__, __LINE__
        def #{method_name}(*args, &block)
          msg = "called #{method_name} "
          msg << "with " << args.join(', ') << " " if args.any?
          msg << "from #{__FILE__}:#{__LINE__}"
          puts msg
          super
        end
      RUBY
    end

    mod.module_eval <<-RUBY, __FILE__, __LINE__
      def self.prepended(base)
        base.extend(self)
      end
    RUBY

    prepend(mod)
  end
end
