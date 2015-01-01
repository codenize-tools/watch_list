describe 'monitor paused' do
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

    exported = watch_list_export(skip_normalize: true) {|h| h[:monitors].length > 0 }
    expect(exported[:monitors]['http monitor'][:Status]).to_not eq UptimeRobot::Monitor::Status::Paused

    watch_list do
      <<-RUBY
        monitor "http monitor" do
          target "http://example.com"
          interval 5
          paused true
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"
          type :http
        end

        alert_contact do
          type :email
          value "#{WATCH_LIST_TEST_EMAIL}"
        end
      RUBY
    end

    exported = watch_list_export(skip_normalize: true) {|h|
      h[:monitors]['http monitor'][:Status] == UptimeRobot::Monitor::Status::Paused
    }

    expect(exported[:monitors]['http monitor'][:Status]).to eq UptimeRobot::Monitor::Status::Paused

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

    exported = watch_list_export(skip_normalize: true) {|h|
      h[:monitors]['http monitor'][:Status] != UptimeRobot::Monitor::Status::Paused
    }

    expect(exported[:monitors]['http monitor'][:Status]).to_not eq UptimeRobot::Monitor::Status::Paused
  end
end
