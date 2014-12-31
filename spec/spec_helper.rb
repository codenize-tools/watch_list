require 'watch_list'

TEST_WATCH_LIST_API_KEY = ENV['TEST_WATCH_LIST_API_KEY']

RSpec.configure do |config|
  config.before(:each) do
    cleanup_uptimerobot
  end
end

def cleanup_uptimerobot
  client = UptimeRobot::Client.new(apiKey: TEST_WATCH_LIST_API_KEY)
  p client.getMonitors
end
