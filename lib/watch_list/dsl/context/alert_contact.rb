class WatchList::DSL::Context::AlertContent
  def initialize(&block)
    @result = {}
  end

  def result
    [:Type, :Value].each do |key|
      raise %!AlertContent: "#{key.to_s.downcase}" is required! unless @result[key]
    end

    @result
  end

  def type(value, &block)
    if value.kind_of?(Integer)
      alert_contact_type = value
    else
      alert_contact_type = WatchList::AlertContent::Type[value.to_s]
    end

    unless WatchList::AlertContent::Type.values.include?(alert_contact_type)
      raise %!AlertContent: "type" is invalid: #{value.inspect}!
    end

    @result[:Type] = alert_contact_type
  end

  def value(value)
    raise %!AlertContent: "value" is invalid: #{value.inspect}! if value.nil?
    @result[:Value] = value.to_s
  end
end
