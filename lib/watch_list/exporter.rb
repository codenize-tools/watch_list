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
    @uptimerobot.getMonitors(showMonitorAlertContacts: 1)
  end
end
