class WatchList::DSL::Context::Monitor
  class Keyword < HTTP
    def result
      [:KeywordType, :KeywordValue].each do |key|
        raise %!Monitor `#{@monitor_name}`: "#{key.to_s.downcase}" is required! unless @result[key]
      end

      super
    end

    def keywordtype(value)
      if value.kind_of?(Integer)
        type = value
      else
        type = WatchList::Monitor::KeywordType[value.to_s]
      end

      unless WatchList::Monitor::KeywordType.values.include?(type)
        raise %!Monitor `#{@monitor_name}`: "keywordtype" is invalid: #{value.inspect}!
      end

      @result[:KeywordType] = type
    end

    def keywordvalue(value)
      raise %!Monitor `#{@monitor_name}`: "keywordvalue" is invalid: #{value.inspect}! if value.nil?
      @result[:KeywordValue] = WatchList::Secure.decrypt_if_possible(value).to_s
    end
  end
end
