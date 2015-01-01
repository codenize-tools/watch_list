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
           :HTTPUsername=>nil,
           :HTTPPassword=>nil,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5},
         "http monitor (basic auth)"=>
          {:FriendlyName=>"http monitor (basic auth)",
           :URL=>"http://example.com",
           :Type=>1,
           :HTTPUsername=>"username",
           :HTTPPassword=>"password",
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5},
         "keyword monitor"=>
          {:FriendlyName=>"keyword monitor",
           :URL=>"http://example.com",
           :Type=>2,
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
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5},
         "port monitor"=>
          {:FriendlyName=>"port monitor",
           :URL=>"example.com",
           :Type=>4,
           :SubType=>1,
           :Port=>80,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5},
         "port monitor (custom)"=>
          {:FriendlyName=>"port monitor (custom)",
           :URL=>"example.com",
           :Type=>4,
           :SubType=>99,
           :Port=>8080,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5}},
       :alert_contacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}]}
    )

    watch_list do
      <<-RUBY
        monitor "http monitor" do
          target "http://example.com/test"
          interval 6
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"
          type :http
        end

        monitor "http monitor2 (basic auth)" do
          target "http://example.com/test"
          interval 7
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

          type :http do
            httpusername "username2"
            httppassword "password2"
          end
        end

        monitor "keyword monitor" do
          target "http://example.com/test"
          interval 8
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

          type :keyword do
            keywordtype :not_exists
            keywordvalue "Example Domain2"
          end
        end

        monitor "keyword monitor (basic auth)" do
          target "http://example.com/test"
          interval 9
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

          type :keyword do
            keywordtype :not_exists
            keywordvalue "(Example Domain2)"
            httpusername "(username2)"
            httppassword "(password2)"
          end
        end

        monitor "ping monitor" do
          target "127.0.0.2"
          interval 10
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"
          type :ping
        end

        monitor "port monitor" do
          target "google.com"
          interval 11
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

          type :port do
            subtype :https
            port 443
          end
        end

        monitor "port monitor (custom)" do
          target "google.com"
          interval 12
          paused false
          alert_contact :email, "#{WATCH_LIST_TEST_EMAIL}"

          type :port do
            subtype :custom
            port 18080
          end
        end

        alert_contact do
          type :email
          value "#{WATCH_LIST_TEST_EMAIL}"
        end
      RUBY
    end

    expect(watch_list_export {|h| h[:monitors]['port monitor (custom)'][:URL] != 'example.com' }).to eq(
      {:monitors=>
        {"http monitor"=>
          {:FriendlyName=>"http monitor",
           :URL=>"http://example.com/test",
           :Type=>1,
           :HTTPUsername=>nil,
           :HTTPPassword=>nil,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>6},
         "keyword monitor"=>
          {:FriendlyName=>"keyword monitor",
           :URL=>"http://example.com/test",
           :Type=>2,
           :KeywordType=>2,
           :KeywordValue=>"Example Domain2",
           :HTTPUsername=>nil,
           :HTTPPassword=>nil,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>8},
         "keyword monitor (basic auth)"=>
          {:FriendlyName=>"keyword monitor (basic auth)",
           :URL=>"http://example.com/test",
           :Type=>2,
           :KeywordType=>2,
           :KeywordValue=>"(Example Domain2)",
           :HTTPUsername=>"(username2)",
           :HTTPPassword=>"(password2)",
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>9},
         "ping monitor"=>
          {:FriendlyName=>"ping monitor",
           :URL=>"127.0.0.2",
           :Type=>3,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>10},
         "port monitor"=>
          {:FriendlyName=>"port monitor",
           :URL=>"google.com",
           :Type=>4,
           :SubType=>2,
           :Port=>443,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>11},
         "port monitor (custom)"=>
          {:FriendlyName=>"port monitor (custom)",
           :URL=>"google.com",
           :Type=>4,
           :SubType=>99,
           :Port=>18080,
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>12},
         "http monitor2 (basic auth)"=>
          {:FriendlyName=>"http monitor2 (basic auth)",
           :URL=>"http://example.com/test",
           :Type=>1,
           :HTTPUsername=>"username2",
           :HTTPPassword=>"password2",
           :AlertContacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>7}},
       :alert_contacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}]}
    )
  end
end
