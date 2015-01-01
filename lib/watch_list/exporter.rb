class WatchList::Exporter
  class << self
    def export(uptimerobot, opts = {})
      self.new(uptimerobot, opts).export
    end

    def export_status(uptimerobot, opts = {})
      self.new(uptimerobot, opts).export_status
    end
  end # of class methods

  def initialize(uptimerobot, options = {})
    @uptimerobot = uptimerobot
    @options = options
  end

  def export
    monitors = @uptimerobot.getMonitors(showMonitorAlertContacts: 1)
    alert_contacts = @uptimerobot.getAlertContacts

    {
      :monitors       => normalize_monitors(monitors),
      :alert_contacts => normalize_alert_contacts(alert_contacts),
    }
  end

  def export_status
    monitors = @uptimerobot.getMonitors(
      :logs                 => 1,
      :responseTimes        => 1,
      :showTimezone         => 1,
    )

    {
      :timezone => monitors['timezone'],
      :monitors => normalize_monitors_status(monitors),
    }
  end

  private

  def normalize_monitors(monitors)
    monitors = monitors.fetch('monitors', {}).fetch('monitor', [])
    monitor_hash = {}

    monitors.each do |monitor|
      friendlyname = monitor['friendlyname']
      type = monitor['type'].to_i

      monitor_hash[friendlyname] = {
        :ID            => monitor['id'],
        :FriendlyName  => friendlyname,
        :URL           => monitor['url'],
        :Type          => type,
        :AlertContacts => monitor.fetch('alertcontact', []).map {|alert_contact|
          {
            :Type  => alert_contact['type'].to_i,
            :Value => alert_contact['value'],
          }
        },
        :Interval      => nil_if_blank(monitor['interval'], :to_i) / 60,
        :Status        => monitor['status'].to_i,
      }

      case WatchList::Monitor::Type.key(type)
      when 'http'
        monitor_hash[friendlyname].update(
          :HTTPUsername => nil_if_blank(monitor['httpusername']),
          :HTTPPassword => nil_if_blank(monitor['httppassword']),
        )
      when 'keyword'
        monitor_hash[friendlyname].update(
          :KeywordType  => nil_if_blank(monitor['keywordtype'], :to_i),
          :KeywordValue => nil_if_blank(monitor['keywordvalue']),
          :HTTPUsername => nil_if_blank(monitor['httpusername']),
          :HTTPPassword => nil_if_blank(monitor['httppassword']),
        )
      when 'ping'
      when 'port'
        monitor_hash[friendlyname].update(
          :SubType => nil_if_blank(monitor['subtype'], :to_i),
          :Port    => nil_if_blank(monitor['port'], :to_i),
        )
      end
    end

    monitor_hash
  end

  def normalize_alert_contacts(alert_contacts)
    alert_contacts = alert_contacts.fetch('alertcontacts', {}).fetch('alertcontact', [])

    alert_contacts.map do |alert_contact|
      {
        :ID    => alert_contact['id'],
        :Type  => alert_contact['type'].to_i,
        :Value => alert_contact['value'],
      }
    end
  end

  def normalize_monitors_status(monitors)
    monitors = monitors.fetch('monitors', {}).fetch('monitor', [])
    monitor_hash = {}

    monitors.each do |monitor|
      friendlyname = monitor['friendlyname']

      monitor_hash[friendlyname] = {
        :status             => WatchList::Monitor::Status.key(monitor['status'].to_i),
        :alltimeuptimeratio => monitor['alltimeuptimeratio'].to_i,
        :log                => normalize_monitor_log(monitor),
        :responsetime       => normalize_monitor_responsetime(monitor),
      }
    end

    monitor_hash
  end

  def normalize_monitor_log(monitor)
    monitor['log'].map do |log|
      {
        :datetime => log['datetime'],
        :type     => WatchList::Log::Type.key(log['type'].to_i),
      }
    end
  end

  def normalize_monitor_responsetime(monitor)
    monitor['responsetime'].map do |responsetime|
      {
        :datetime => responsetime['datetime'],
        :value    => responsetime['value'].to_i,
      }
    end
  end

  def nil_if_blank(str, conv = nil)
    if str.empty?
      nil
    else
      conv ? str.send(conv) : str
    end
  end
end
