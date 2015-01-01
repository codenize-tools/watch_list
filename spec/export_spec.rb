describe 'export' do
  it do
    watch_list do
      <<-RUBY
        alert_contact do
          type :email
          value "#{WATCH_LIST_TEST_EMAIL}"
        end

        alert_contact do
          type :email
          value "#{WATCH_LIST_TEST_EMAIL2}"
        end
      RUBY
    end

    wait_until {|h| h[:alert_contacts].length > 1 }

    expect(watch_list_client.export).to eq <<-RUBY.strip
alert_contact do
  type :email
  value "#{WATCH_LIST_TEST_EMAIL}"
end

alert_contact do
  type :email
  value "#{WATCH_LIST_TEST_EMAIL2}"
end
    RUBY

    watch_list do
      <<-RUBY
        monitor "http monitor" do
          target "http://example.com"
          interval 5
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL2}"
          type :http
        end

        alert_contact do
          type :email
          value "#{WATCH_LIST_TEST_EMAIL}"
        end

        alert_contact do
          type :email
          value "#{WATCH_LIST_TEST_EMAIL2}"
        end
      RUBY
    end

    wait_until {|h| h[:monitors].length > 0 }

    expect(watch_list_client.export).to eq <<-RUBY.strip
monitor "http monitor" do
  target "http://example.com"
  interval 5
  paused false
  alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"
  alert_contact :email, "#{WATCH_LIST_TEST_EMAIL2}"

  type :http
end

alert_contact do
  type :email
  value "#{WATCH_LIST_TEST_EMAIL}"
end

alert_contact do
  type :email
  value "#{WATCH_LIST_TEST_EMAIL2}"
end
    RUBY
  end
end
