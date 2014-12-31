class WatchList::Driver
  include WatchList::Logger::Helper

  def initialize(uptimerobot, opts = {})
    @uptimerobot = uptimerobot
    @options = opts
  end

  def new_alert_contact(attrs)
    updated = false
    log(:info, "Create AlertContact: #{describe_alert_contacts(attrs)}", :color => :cyan)

    unless @options[:dry_run]
      response = @uptimerobot.newAlertContact(
        :alertContactType  => attrs[:Type],
        :alertContactValue => attrs[:Value],
      )

      attrs[:ID] = response['alertcontact']['id']
      updated = true
    end

    updated
  end

  def delete_alert_contact(attrs)
    updated = false
    log(:info, "Delete AlertContact: #{describe_alert_contacts(attrs)}", :color => :red)

    unless @options[:dry_run]
      @uptimerobot.deleteAlertContact(
        :alertContactID => attrs[:ID],
      )

      updated = true
    end

    updated
  end

  def new_monitor(attrs, exist_alert_contacts)
    updated = false
    log(:info, "Create Monitor: #{attrs[:FriendlyName]}", :color => :cyan)

    unless @options[:dry_run]
      normalize_edit_attrs!(attrs)
      params = monitor_to_params(attrs, exist_alert_contacts)
      response = @uptimerobot.newMonitor(params)
      attrs[:ID] = response['monitor']['id']
      updated = true
    end

    updated
  end

  def delete_monitor(attrs)
    updated = false
    log(:info, "Delete Monitor: #{attrs[:FriendlyName]}", :color => :red)

    unless @options[:dry_run]
      @uptimerobot.deleteMonitor(
        :monitorID => attrs[:ID],
      )

      updated = true
    end

    updated
  end

  def edit_monitor(monitor_id, monitor_name, attrs, exist_alert_contacts)
    updated = false
    log(:info, "Update Monitor: #{monitor_name}", :color => :green)

    attrs.each do |key, value|
      log(:info, " set #{key}=#{value}", :color => :green)
    end

    unless @options[:dry_run]
      params = monitor_to_params(attrs, exist_alert_contacts)
      params[:monitorID] = monitor_id
      @uptimerobot.editMonitor(params)
      updated = true
    end

    updated
  end

  def pause_monitor(monitor_id, monitor_name, paused)
    updated = false
    log(:info, (paused ? 'Pause' : 'Unpause') + " Monitor: #{monitor_name}", :color => :green)

    unless @options[:dry_run]
      @uptimerobot.editMonitor(
        :monitorID     => monitor_id,
        :monitorStatus => (paused ? 0 : 1),
      )

      updated = true
    end

    updated
  end

  private

  def describe_alert_contacts(attrs)
    type = WatchList::AlertContact::Type.key(attrs[:Type])
    "#{type}, #{attrs[:Value]}"
  end

  def monitor_to_params(attrs, exist_alert_contacts)
    params = {}
    attrs = attrs.dup
    attrs.delete(:Paused)
    alert_contacts = attrs.delete(:AlertContacts) || []

    attrs.each do |key, value|
      params["monitor#{key}"] = value unless value.nil?
    end

    unless alert_contacts.empty?
      params[:monitorAlertContacts] = alert_contacts.map {|alert_contact|
        exist_alert_contact = exist_alert_contacts.find {|i|
          i.values_at(:Type, :Value) == alert_contact.values_at(:Type, :Value)
        }

        raise "AlertContact does not exist: #{alert_contact.inspect}" unless exist_alert_contact

        exist_alert_contact[:ID]
      }.join(',')
    end

    params
  end

  def normalize_edit_attrs!(attrs)
    # XXX: Other parameter is required in order to update the "HTTPUsername" and "HTTPPassword"
    attrs[:Interval] ||= expected[:Interval]

    # Remove by an empty parameter
    attrs.keys.each do |key|
      attrs[key] ||= ''
    end
  end
end
