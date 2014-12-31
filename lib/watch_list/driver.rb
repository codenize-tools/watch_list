class WatchList::Driver
  def initialize(uptimerobot, opts = {})
    @uptimerobot = uptimerobot
    @options = opts
  end

  def new_alert_contact(attrs)
    response = @uptimerobot.newAlertContact(
      :alertContactType  => attrs[:Type],
      :alertContactValue => attrs[:Value],
    )

    attrs[:ID] = response['alertcontact']['id']
  end

  def delete_alert_contact(attrs)
    @uptimerobot.deleteAlertContact(
      :alertContactID => attrs[:ID],
    )
  end
end
