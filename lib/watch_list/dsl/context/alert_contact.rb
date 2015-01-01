class WatchList::DSL::Context::AlertContact
  def initialize(&block)
    @result = {}
    instance_eval(&block)
  end

  def result
    [:Type, :Value].each do |key|
      raise %!AlertContact: "#{key.to_s.downcase}" is required! unless @result[key]
    end

    @result
  end

  def type(value, &block)
    if value.kind_of?(Integer)
      alert_contact_type = value
    else
      alert_contact_type = WatchList::AlertContact::Type[value.to_s]
    end

    unless WatchList::AlertContact::Type.values.include?(alert_contact_type)
      raise %!AlertContact: "type" is invalid: #{value.inspect}!
    end

    @result[:Type] = alert_contact_type
  end

  def value(value)
    raise %!AlertContact: "value" is invalid: #{value.inspect}! if value.nil?
    @result[:Value] = WatchList::Secure.decrypt_if_possible(value).to_s
  end
end
