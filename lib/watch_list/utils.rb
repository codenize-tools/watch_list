class WatchList::Utils
  class << self
    def const_to_hash(const)
      hash = {}

      const.constants.map do |c|
        key = c.to_s.gsub(/[A-Z]+/, '_\0').sub(/\A_/, '').downcase
        hash[key] = const.const_get(c)
      end

      hash
    end
  end # of class methods
end
