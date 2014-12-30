class WatchList::Exporter
  class << self
    def export(uptimerobot, opts = {})
      self.new(uptimerobot, opts).export
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

  private

  def normalize_monitors(monitors)
    monitors = monitors.fetch('monitors', {}).fetch('monitor', [])
    monitor_hash = {}

    monitors.each do |monitor|
      friendlyname = monitor['friendlyname']

      monitor_hash[friendlyname] = {
        :ID            => monitor['id'],
        :FriendlyName  => friendlyname,
        :URL           => monitor['url'],
        :Type          => monitor['type'].to_i,
        :SubType       => nil_if_blank(monitor['subtype'], :to_i),
        :Port          => nil_if_blank(monitor['port'], :to_i),
        :KeywordType   => nil_if_blank(monitor['keywordtype'], :to_i),
        :KeywordValue  => nil_if_blank(monitor['keywordvalue']),
        :HTTPUsername  => nil_if_blank(monitor['httpusername']),
        :HTTPPassword  => nil_if_blank(monitor['httppassword']),
        :AlertContacts => monitor.fetch('alertcontact', []).map {|alert_contact|
          {
            :Type => alert_contact['type'].to_i,
            :Value => alert_contact['value'],
          }
        },
        :Interval      => nil_if_blank(monitor['interval'], :to_i),
        :Status        => monitor['status'].to_i,
      }
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

  def nil_if_blank(str, conv = nil)
    if str.empty?
      nil
    else
      conv ? str.send(conv) : str
    end
  end
end
