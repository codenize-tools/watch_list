class WatchList::DSL::Context::Monitor::Type
  CHILDREN = {}

  class << self
    def inherited(child)
      name = child.to_s.split('::').last.downcase
      CHILDREN[name] = child
    end

    def [](name)
      CHILDREN[name]
    end
  end # of class methods

  def initialize(monitor_name, &block)
    @monitor_name = monitor_name
    @result = {}
    instance_eval(&block) if block
  end

  def result
    @result
  end
end
