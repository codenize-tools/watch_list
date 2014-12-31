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
  ]

  def initialize(options = {})
    @options = options
    @uptimerobot = UptimeRobot::Client.new(:apiKey => options[:apiKey])
    @driver = WatchList::Driver.new(@uptimerobot, options)
  end

  def export
    exported = WatchList::Exporter.export(@uptimerobot, @options)
    WatchList::DSL.convert(exported, @options)
  end

  def apply(file)
    walk(file)
  end

  private

  def walk(file)
    expected = load_file(file)
    actual   = WatchList::Exporter.export(@uptimerobot, @options)

    updated = walk_alert_contacts(expected[:alert_contacts], actual[:alert_contacts])
    walk_monitors(expected[:monitors], actual[:monitors], expected[:alert_contacts]) || updated
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
        updated = @driver.new_alert_contact(expected_alert_contact) || updated
      end
    end

    actual.each do |alert_contact|
      updated = @driver.delete_alert_contact(alert_contact) || updated
    end

    updated
  end

  def walk_monitors(expected, actual, alert_contacts)
    updated = false

    expected.each do |friendlyname, expected_monitor|
      actual_monitor = actual.delete(friendlyname)

      if actual_monitor
        expected_monitor[:ID] = actual_monitor[:ID]
        updated = walk_monitor(expected_monitor, actual_monitor, alert_contacts) || updated
      else
        updated = @driver.new_monitor(expected_monitor, alert_contacts) || updated
      end
    end

    actual.each do |friendlyname, monitor|
      updated = @driver.delete_monitor(monitor) || updated
    end

    updated
  end

  def walk_monitor(expected, actual, alert_contacts)
    updated = false
    delta = diff_monitor(expected, actual)

    unless delta.empty?
      # Other parameter is required in order to update the "HTTPUsername" and "HTTPPassword"
      delta[:Interval] ||= expected[:Interval]

      # Remove by an empty parameter
      delta.keys.each do |key|
        delta[key] ||= ''
      end

      updated = @driver.edit_monitor(expected[:ID], expected[:FriendlyName], delta, alert_contacts)
    end

    walk_monitor_paused(expected, actual) || updated
  end

  def walk_monitor_paused(expected, actual)
    updated = false
    expected_paused = !!expected[:Paused]
    actual_pauced   = (actual[:Status] == UptimeRobot::Monitor::Status::Paused)

    if expected_paused != actual_pauced
      # XXX: updated paused
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
