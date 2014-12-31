require 'watch_list'
require 'tempfile'

WATCH_LIST_TEST_API_KEY = ENV['WATCH_LIST_TEST_API_KEY']
WATCH_LIST_TEST_PRIMARY_ALERT_CONTACT_ID = ENV['WATCH_LIST_TEST_PRIMARY_ALERT_CONTACT_ID']
WATCH_LIST_TEST_EMAIL = ENV['WATCH_LIST_TEST_EMAIL']
APPLY_WAIT = 30

RSpec.configure do |config|
  config.before(:each) do
    cleanup_uptimerobot
  end

  config.after(:all) do
    cleanup_uptimerobot(skip_wait: true)
  end
end

def watch_list_client(options = {})
  options = {
    apiKey: WATCH_LIST_TEST_API_KEY,
  }.merge(options)

  if ENV['DEBUG'] == '1'
    options[:debug] = true
  else
    options[:logger] = Logger.new('/dev/null')
  end

  WatchList::Client.new(options)
end

def watch_list(options = {})
  client = watch_list_client(options)

  tempfile(yield) do |f|
    client.apply(f.path)
  end
end

def wait_until(options, client = uptimerobot_client)
  export = proc do
    WatchList::Exporter.export(client, options)
  end

  exported = nil

  loop do
    exported = export.call
    break if yield(exported)
    sleep 1
  end

  exported
end

def watch_list_export(options = {}, &block)
  block ||= proc do |h|
    h[:monitors].length > 0
  end

  exported = wait_until(options, &block)

  unless options[:skip_normalize]
    exported[:monitors].each do |name, attrs|
      attrs.delete(:ID)
      attrs.delete(:Status)
    end

    exported[:alert_contacts].each do |alert_contact|
      alert_contact.delete(:ID)
    end
  end

  exported
end

def tempfile(content, options = {})
  basename = "#{File.basename __FILE__}.#{$$}"
  basename = [basename, options[:ext]] if options[:ext]

  Tempfile.open(basename) do |f|
    f.puts(content)
    f.flush
    f.rewind
    yield(f)
  end
end

def uptimerobot_client(options = {})
  options = {
    apiKey: WATCH_LIST_TEST_API_KEY,
  }.merge(options)

  UptimeRobot::Client.new(apiKey: WATCH_LIST_TEST_API_KEY)
end

def cleanup_uptimerobot(options = {})
  client = uptimerobot_client
  cleanup_uptimerobot_monitor(client, options)
  cleanup_uptimerobot_alert_contact(client, options)
end

def cleanup_uptimerobot_monitor(client, options = {})
  get_monitors = proc do
    client.getMonitors['monitors']['monitor']
  end

  get_monitors.call.each do |monitor|
    client.deleteMonitor(monitorID: monitor['id'])
  end

  return if options[:skip_wait]

  loop do
    break if get_monitors.call.length.zero?
    sleep 1
  end
end

def cleanup_uptimerobot_alert_contact(client, options = {})
  get_alert_contacts = proc do
    alert_contacts = client.getAlertContacts['alertcontacts']['alertcontact']
    alert_contacts.select {|i| i['id'] != WATCH_LIST_TEST_PRIMARY_ALERT_CONTACT_ID }
  end

  get_alert_contacts.call.each do |alert_contact|
    client.deleteAlertContact(alertContactID: alert_contact['id'])
  end

  return if options[:skip_wait]

  loop do
    break if get_alert_contacts.call.length.zero?
    sleep 1
  end
end
