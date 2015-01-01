describe 'monitor' do
  it do
    watch_list do
      <<-RUBY
        monitor "http monitor" do
          target "http://example.com"
          interval 5
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"
          type :http
        end

        alert_contact do
          type :email
          value "#{WATCH_LIST_TEST_EMAIL}"
        end
      RUBY
    end

    wait_until {|h| h[:monitors].length > 0 }

    status = watch_list_client.status
    monitor = status[:monitors]['http monitor']

    expect(status).to have_key(:timezone)
    expect(monitor).to have_key(:status)
    expect(monitor).to have_key(:alltimeuptimeratio)
    expect(monitor).to have_key(:log)
    expect(monitor).to have_key(:responsetime)
  end
end
