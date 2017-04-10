module ObjectTracker
  class TrackerMethod
    attr_reader :name, :context

    def initialize(context, name)
      @name = name
      @context = context
    end

    def source
      return @source if defined? @source
      @source = source_location
      @source = @source ? @source.join(':').split('/').last(5).join('/') : 'RUBY CORE'
    end

    def source_location
      method_handle = context.method(name)
      method_handle.source_location if method_handle
    end

    def display_name
      return @display_name if defined? @display_name
      if Class === context || Module === context
        obj = context
        prefix = '.'
      elsif context.class === Class
        prefix = '.'
        obj = context.class
      else
        prefix = '#'
        obj = context.class
      end
      @display_name = "#{obj.name}#{prefix}#{@name}"
    end
  end
end
