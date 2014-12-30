class WatchList::DSL::Converter
  class << self
    def convert(exported, opts = {})
      self.new(exported, opts).convert
    end
  end # of class methods

  def initialize(exported, options = {})
    @exported = exported
    @options = options
  end

  def convert
  end
end
