class WatchList::DSL::Context::Monitor
  def initialize(name, &block)
    @name = name

    @result = {
      :FriendlyName  => name,
      :Paused        => false,
      :AlertContacts => [],
    }

    instance_eval(&block)
  end

  def result
    [:URL, :Interval, :Type].each do |key|
      raise %!Monitor `#{@name}`: "#{key.to_s.downcase}" is required! unless @result[key]
    end

    @result
  end

  def url(value)
    raise %!Monitor `#{@name}`: "url" is invalid: #{value.inspect}! if value.nil?
    @result[:URL] = value.to_s
  end

  def interval(value)
    raise %!Monitor `#{@name}`: "interval" is invalid: #{value.inspect}! unless value.kind_of?(Integer)
    @result[:Interval] = value
  end

  def paused(value)
    unless [TrueClass, FalseClass].any? {|i| value.kind_of?(i) }
      raise %!Monitor `#{@name}`: "paused" is invalid: #{value.inspect}!
    end

    @result[:Paused] = value
  end

  def alert_contact(type, value)
    if type.kind_of?(Integer)
      alert_contact_type = type
    else
      alert_contact_type = WatchList::AlertContact::Type[type.to_s]
    end

    unless WatchList::AlertContact::Type.values.include?(alert_contact_type)
      raise %!Monitor `#{@name}`: "alert_contact" type is invalid: #{type.inspect}!
    end

    raise %!Monitor `#{@name}`: "alert_contact" value is invalid: #{value.inspect}! if value.nil?

    hash = {:Type => alert_contact_type, :Value => value.to_s}

    if @result[:AlertContacts].include?(hash)
      raise %!Monitor `#{@name}`: "alert_contact"(#{type}, #{value}) is already defined!
    end

    @result[:AlertContacts] << hash
  end

  def type(value, &block)
    if value.kind_of?(Integer)
      monitor_type = value
    else
      monitor_type = WatchList::Monitor::Type[value.to_s]
    end

    unless WatchList::Monitor::Type.values.include?(monitor_type)
      raise %!Monitor `#{@name}`: "type" is invalid: #{value.inspect}!
    end

    @result[:Type] = monitor_type

    type_class = WatchList::DSL::Context::Monitor::Type[value.to_s]
    raise "Monitor `#{@name}`: #{value.inspect} is unimplemented type" unless type_class

    @result.update(type_class.new(@name, &block).result)
  end
end
