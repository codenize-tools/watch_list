class WatchList::DSL::Context::Monitor::Type
  CHILDREN = {}

  class << self
    def inherited(child)
      CHILDREN[child.to_s.downcase] = child
    end

    def [](name)
      CHILDREN[name]
    end
  end # of class methods

  def initialize(monitor_name)
    @monitor_name = monitor_name
    @result = {}
  end

  def result
    @result
  end
end
