module ObjectTracker
  class InstanceTrackerMethod < TrackerMethod
    def context
      super.respond_to?(:allocate) ? super.allocate : super
    end

    def source_location
      method_handle = context.method(name)
      method_handle.source_location if method_handle
    end
  end
end
