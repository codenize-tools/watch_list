class WatchList::DSL
  class << self
    def convert(exported, opts = {})
      WatchList::DSL::Converter.convert(exported, opts)
    end

    def parse(dsl, path, opts = {})
    end
  end # of class methods
end
