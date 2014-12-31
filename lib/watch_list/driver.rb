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

  private

  def describe_alert_contacts(attrs)
    type = WatchList::AlertContact::Type.key(attrs[:Type])
    "#{type}, #{attrs[:Value]}"
  end
end
