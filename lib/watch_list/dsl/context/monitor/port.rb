class WatchList::DSL::Context::Monitor
  class Port < Type
    def result
      [:SubType, :Port].each do |key|
        raise %!Monitor `#{@monitor_name}`: "#{key.to_s.downcase}" is required! unless @result[key]
      end

      super
    end

    def subtype(value)
      if value.kind_of?(Integer)
        type = value
      else
        type = WatchList::Monitor::SubType[value.to_s]
      end

      unless WatchList::Monitor::SubType.values.include?(type)
        raise %!Monitor `#{@monitor_name}`: "subtype" is invalid: #{value.inspect}!
      end

      @result[:SubType] = type
    end

    def port(value)
      raise %!Monitor `#{@monitor_name}`: "port" is invalid: #{value.inspect}! unless value.kind_of?(Integer)
      @result[:Port] = value
    end
  end
end
