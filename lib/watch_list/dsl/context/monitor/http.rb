class WatchList::DSL::Context::Monitor
  class HTTP < Type
    def httpusername(value)
      raise %!Monitor `#{@monitor_name}`: "httpusername" is invalid: #{value.inspect}! if value.nil?
      @result[:HTTPUsername] = WatchList::Secure.decrypt_if_possible(value).to_s
    end

    def httppassword(value)
      raise %!Monitor `#{@monitor_name}`: "httppassword" is invalid: #{value.inspect}! if value.nil?
      @result[:HTTPPassword] = WatchList::Secure.decrypt_if_possible(value).to_s
    end
  end
end
