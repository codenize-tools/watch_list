module WatchList
  module Monitor
    Type = WatchList::Utils.const_to_hash(UptimeRobot::Monitor::Type)

    SubType = WatchList::Utils.const_to_hash(UptimeRobot::Monitor::SubType)

    KeywordType = WatchList::Utils.const_to_hash(UptimeRobot::Monitor::KeywordType)
  end

  module AlertContact
    Type = WatchList::Utils.const_to_hash(UptimeRobot::AlertContact::Type)
  end
end
