class WatchList::DSL::Converter
  TYPE_ATTRS = [
    :SubType,
    :Port,
    :KeywordType,
    :KeywordValue,
    :HTTPUsername,
    :HTTPPassword,
  ]

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
    [
      output_monitors(@exported[:monitors]),
      output_alert_contacts(@exported[:alert_contacts]),
    ].join("\n\n")
  end

  private

  def output_monitors(monitors)
    (monitors || []).map {|monitor|
      output_monitor(monitor)
    }.join("\n\n")
  end

  def output_monitor(monitor)
    alert_contacts = monitor[:AlertContacts]
    has_type_attr  = TYPE_ATTRS.any? {|i| monitor[i] }
    monitor_type = WatchList::Monitor::Type.key(monitor[:Type]).to_sym.inspect

    output {|buf|
      buf << "monitor #{monitor[:Friendlyname].inspect} do"
      buf << "  url #{monitor[:URL].inspect}"
      buf << "  interval #{monitor[:Interval].inspect}"
      buf << "  paused #{monitor[:Status].zero?}"

      unless alert_contacts.empty?
        output_monitor_alert_contacts(alert_contacts, buf)
      end

      buf << ""
      buf << "  type #{monitor_type}" + (has_type_attr ? " do" : "")

      if has_type_attr
        output_monitor_type_attrs(monitor, buf)
        buf << "  end"
      end

      buf << "end"
    }.join("\n")
  end

  def output_monitor_alert_contacts(alert_contacts, buf)
    alert_contacts.each do |alert_contact|
      type = alert_contact[:Type]
      type = WatchList::AlertContact::Type.key(type).to_sym.inspect
      value = alert_contact[:Value].inspect
      buf << "  alert_contact #{type}, #{value}"
    end
  end

  def output_monitor_type_attrs(monitor, buf)
    TYPE_ATTRS.each do |key|
      value = monitor[key]
      next unless value

      if WatchList::Monitor.const_defined?(key)
        const = WatchList::Monitor.const_get(key)
        buf << "    #{key.to_s.downcase} " + const.key(value).to_sym.inspect
      else
        buf << "    #{key.to_s.downcase} #{value.inspect}"
      end
    end
  end

  def output_alert_contacts(alert_contacts)
    (alert_contacts || []).map {|alert_contact|
      output_alert_contact(alert_contact)
    }.join("\n\n")
  end

  def output_alert_contact(alert_contact)
    alert_contact_type = WatchList::AlertContact::Type.key(alert_contact[:Type]).to_sym.inspect

    output {|buf|
      buf << "alertcontact do"
      buf << "  type #{alert_contact_type}"
      buf << "  value #{alert_contact[:Value].inspect}"
      buf << "end"
    }.join("\n")
  end

  def output(buf = [])
    yield(buf)
    buf
  end
end
