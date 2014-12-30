class WatchList::Client
  MONITOR_ATTRS = [
    :URL,
    :Type,
    :SubType,
    :Port,
    :KeywordType,
    :KeywordValue,
    :HTTPUsername,
    :HTTPPassword,
    :AlertContacts,
    :Interval,
    :Status,
  ]

  def initialize(options = {})
    @options = options
    @uptimerobot = UptimeRobot::Client.new(:apiKey => options[:apiKey])
  end

  def export(opts = {})
    exported = WatchList::Exporter.export(@uptimerobot, @options.merge(opts))
    WatchList::DSL.convert(exported, @options.merge(opts))
  end

  def apply(file, opts = {})
    walk(file, opts)
  end

  private

  def walk(file, opts = {})
    expected = load_file(file)
    actual   = WatchList::Exporter.export(@uptimerobot, @options.merge(opts))

    updated = walk_alert_contacts(expected[:alert_contacts], actual[:alert_contacts])
    walk_monitors(expected[:monitors], actual[:monitors]) || updated
  end

  def walk_alert_contacts(expected, actual)
    updated = false

    expected.each do |expected_alert_contact|
      selector = proc do |i|
        i.values_at(:Type, :Value) == expected_alert_contact.values_at(:Type, :Value)
      end

      actual_alert_contact = actual.find(&selector)

      if actual_alert_contact
        expected_alert_contact[:ID] = actual_alert_contact[:ID]
        actual.delete_if(&selector)
      else
        # XXX: create alert_contact
        updated = true
      end
    end

    actual.each do |alert_contact|
      # XXX: alert_contact
      updated = true
    end

    updated
  end

  def walk_monitors(expected, actual)
    updated = false

    expected.each do |friendlyname, expected_monitor|
      actual_monitor = actual.delete(friendlyname)

      if actual_monitor
        expected_monitor[:ID] = actual_monitor[:ID]
        updated = walk_monitor(expected_monitor, actual_monitor) || updated
      else
        # XXX: create monitor
        updated = true
      end
    end

    actual.each do |friendlyname, monitor|
      # XXX: delete monitor
      updated = true
    end

    updated
  end

  def walk_monitor(expected, actual)
    updated = false
    delta = diff_monitor(expected, actual)

    unless delta.empty?
      # XXX: update monitor
      updated = true
    end

    updated
  end

  def diff_monitor(expected, actual)
    delta = {}

    MONITOR_ATTRS.each do |key|
      expected_value = expected[key]
      actual_value   = actual[key]
      next if expected_value.nil? && actual_value.nil?

      if expected_value.kind_of?(Array)
        expected_value = expected_value.sort_by {|i| i.to_s }
      end

      if actual_value.kind_of?(Array)
        actual_value = actual_value.sort_by {|i| i.to_s }
      end

      if expected_value != actual_value
        delta[key] = expected_value
      end
    end

    delta
  end

  def load_file(file)
    if file.kind_of?(String)
      open(file) do |f|
        WatchList::DSL.parse(f.read, file)
      end
    elsif [File, Tempfile].any? {|i| file.kind_of?(i) }
      WatchList::DSL.parse(file.read, file.path)
    else
      raise TypeError, "can't convert #{file} into File"
    end
  end
end
