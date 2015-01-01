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

        monitor "http monitor (basic auth)" do
          target "http://example.com"
          interval 5
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

          type :http do
            httpusername "username"
            httppassword "password"
          end
        end

        monitor "keyword monitor" do
          target "http://example.com"
          interval 5
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

          type :keyword do
            keywordtype :exists
            keywordvalue "Example Domain"
          end
        end

        monitor "keyword monitor (basic auth)" do
          target "http://example.com"
          interval 5
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

          type :keyword do
            keywordtype :exists
            keywordvalue "(Example Domain)"
            httpusername "(username)"
            httppassword "(password)"
          end
        end

        monitor "ping monitor" do
          target "127.0.0.1"
          interval 5
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"
          type :ping
        end

        monitor "port monitor" do
          target "example.com"
          interval 5
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

          type :port do
            subtype :http
            port 80
          end
        end

        monitor "port monitor (custom)" do
          target "example.com"
          interval 5
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

          type :port do
            subtype :custom
            port 8080
          end
        end

        alert_contact do
          type :email
          value "#{WATCH_LIST_TEST_EMAIL}"
        end
      RUBY
    end

    expect(watch_list_export {|h| h[:monitors].length > 0 }).to eq(
      {:monitors=>
        {"http monitor"=>
          {:FriendlyName=>"http monitor",
           :URL=>"http://example.com",
           :Type=>1,
           :SubType=>0,
           :Port=>0,
           :KeywordType=>nil,
           :KeywordValue=>nil,
           :HTTPUsername=>nil,
           :HTTPPassword=>nil,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5},
         "http monitor (basic auth)"=>
          {:FriendlyName=>"http monitor (basic auth)",
           :URL=>"http://example.com",
           :Type=>1,
           :SubType=>0,
           :Port=>0,
           :KeywordType=>nil,
           :KeywordValue=>nil,
           :HTTPUsername=>"username",
           :HTTPPassword=>"password",
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5},
         "keyword monitor"=>
          {:FriendlyName=>"keyword monitor",
           :URL=>"http://example.com",
           :Type=>2,
           :SubType=>0,
           :Port=>0,
           :KeywordType=>1,
           :KeywordValue=>"Example Domain",
           :HTTPUsername=>nil,
           :HTTPPassword=>nil,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5},
         "keyword monitor (basic auth)"=>
          {:FriendlyName=>"keyword monitor (basic auth)",
           :URL=>"http://example.com",
           :Type=>2,
           :SubType=>0,
           :Port=>0,
           :KeywordType=>1,
           :KeywordValue=>"(Example Domain)",
           :HTTPUsername=>"(username)",
           :HTTPPassword=>"(password)",
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5},
         "ping monitor"=>
          {:FriendlyName=>"ping monitor",
           :URL=>"127.0.0.1",
           :Type=>3,
           :SubType=>0,
           :Port=>0,
           :KeywordType=>nil,
           :KeywordValue=>nil,
           :HTTPUsername=>nil,
           :HTTPPassword=>nil,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5},
         "port monitor"=>
          {:FriendlyName=>"port monitor",
           :URL=>"example.com",
           :Type=>4,
           :SubType=>1,
           :Port=>80,
           :KeywordType=>nil,
           :KeywordValue=>nil,
           :HTTPUsername=>nil,
           :HTTPPassword=>nil,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5},
         "port monitor (custom)"=>
          {:FriendlyName=>"port monitor (custom)",
           :URL=>"example.com",
           :Type=>4,
           :SubType=>99,
           :Port=>8080,
           :KeywordType=>nil,
           :KeywordValue=>nil,
           :HTTPUsername=>nil,
           :HTTPPassword=>nil,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5}},
       :alert_contacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}]}
    )
  end
end
