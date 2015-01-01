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

  context 'when with encrypt' do
    let(:pass) { '**secret password**' }
    let(:salt) { 'nU0+G1icf70=' }
    let(:encrypted_password) { 'A4wjNcr8xl71wVXqsIYuYQ==' }

    let(:dsl_with_secure) do
      <<-RUBY
monitor "http monitor" do
  target "http://example.com"
  interval 5
  paused false
  alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

  type :http do
    httpusername "username"
    httppassword :secure=>"#{encrypted_password}"
  end
end

alert_contact do
  type :email
  value "sugawara.genki@gmail.com"
end
      RUBY
    end

    before do
      system(%!git config watch-list.pass "#{pass}"!)
      system(%!git config watch-list.salt "#{salt}"!)
    end

    after do
      system('git config --remove-section watch-list')
    end

    it do
      watch_list do
        <<-RUBY
          monitor "http monitor" do
            target "http://example.com"
            interval 5
            paused false
            alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

            type :http do
              httpusername "username"
              httppassword "password"
            end
          end

          alert_contact do
            type :email
            value "#{WATCH_LIST_TEST_EMAIL}"
          end
        RUBY
      end

      wait_until {|h| h[:monitors].length > 0 }

      expect(watch_list_client.export).to eq dsl_with_secure.strip
    end

    it do
      watch_list { dsl_with_secure }

      wait_until {|h| h[:monitors].length > 0 }

      expect(watch_list_client.export).to eq dsl_with_secure.strip
    end
  end
end
