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
    ].join("\n\n").strip
  end

  private

  def output_monitors(monitors)
    (monitors || []).map {|friendlyname, monitor|
      output_monitor(monitor)
    }.join("\n\n")
  end

  def output_monitor(monitor)
    alert_contacts = monitor[:AlertContacts]
    has_type_attr  = TYPE_ATTRS.any? {|i| monitor[i] }
    monitor_type = WatchList::Monitor::Type.key(monitor[:Type]).to_sym
    paused = (monitor[:Status] == UptimeRobot::Monitor::Status::Paused)

    output {|buf|
      buf << "monitor #{monitor[:FriendlyName].inspect} do"
      buf << "  target #{monitor[:URL].inspect}"
      buf << "  interval #{monitor[:Interval].inspect}"
      buf << "  paused #{paused.inspect}"

      unless alert_contacts.empty?
        output_monitor_alert_contacts(alert_contacts, buf)
      end

      buf << ""
      buf << "  type #{monitor_type.inspect}" + (has_type_attr ? " do" : "")

      if has_type_attr
        output_monitor_type_attrs(monitor, buf)
        buf << "  end"
      end

      buf << "end"
    }.join("\n")
  end

  def output_monitor_alert_contacts(alert_contacts, buf)
    alert_contacts.each do |alert_contact|
      type = WatchList::AlertContact::Type.key(alert_contact[:Type]).to_sym
      buf << "  alert_contact #{type.inspect}, #{alert_contact[:Value].inspect}"
    end
  end

  def output_monitor_type_attrs(monitor, buf)
    TYPE_ATTRS.each do |key|
      value = monitor[key]
      next unless value

      if WatchList::Monitor.const_defined?(key)
        const = WatchList::Monitor.const_get(key)
        buf << "    #{key.to_s.downcase} " + const.key(value).to_sym.inspect
      elsif key == :HTTPPassword and WatchList::Secure.git_encryptable?
        value = WatchList::Secure.git_encrypt(value).inspect.sub(/\A\{/, '').sub(/\}\z/, '')
        buf << "    #{key.to_s.downcase} #{value}"
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
    alert_contact_type = WatchList::AlertContact::Type.key(alert_contact[:Type]).to_sym

    output {|buf|
      buf << "alert_contact do"
      buf << "  type #{alert_contact_type.inspect}"
      buf << "  value #{alert_contact[:Value].inspect}"
      buf << "end"
    }.join("\n")
  end

  def output(buf = [])
    yield(buf)
    buf
  end
end
