describe 'alert contact' do
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

    expect(watch_list_export {|h| h[:alert_contacts].length > 1 }).to eq(
      {:monitors=>{},
       :alert_contacts=>
        [{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL},
         {:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL2}]}
    )

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
           :AlertContacts=>
            [{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL},
             {:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL2}],
           :Interval=>5}},
       :alert_contacts=>
        [{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL},
         {:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL2}]}
    )

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

        alert_contact do
          type :email
          value "#{WATCH_LIST_TEST_EMAIL2}"
        end
      RUBY
    end

    expect(watch_list_export {|h| h[:monitors]['http monitor'][:AlertContacts].length < 2 }).to eq(
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
           :AlertContacts=>
            [{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}],
           :Interval=>5}},
       :alert_contacts=>
        [{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL},
         {:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL2}]}
    )

    watch_list do
      <<-RUBY
        monitor "http monitor" do
          target "http://example.com"
          interval 5
          paused false
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

    expect(watch_list_export {|h| h[:monitors]['http monitor'][:AlertContacts][0][:Value] != WATCH_LIST_TEST_EMAIL }).to eq(
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
           :AlertContacts=>
            [{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL2}],
           :Interval=>5}},
       :alert_contacts=>
        [{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL},
         {:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL2}]}
    )

    watch_list do
      <<-RUBY
        alert_contact do
          type :email
          value "#{WATCH_LIST_TEST_EMAIL}"
        end
      RUBY
    end

    expect(watch_list_export {|h| h[:monitors].length < 1 }).to eq(
      {:monitors=>{}, :alert_contacts=>[{:Type=>2, :Value=>WATCH_LIST_TEST_EMAIL}]}
    )
  end
end
