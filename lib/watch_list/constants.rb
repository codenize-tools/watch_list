module WatchList
  module Monitor
    Type        = WatchList::Utils.const_to_hash(UptimeRobot::Monitor::Type)
    SubType     = WatchList::Utils.const_to_hash(UptimeRobot::Monitor::SubType)
    KeywordType = WatchList::Utils.const_to_hash(UptimeRobot::Monitor::KeywordType)
    Status      = WatchList::Utils.const_to_hash(UptimeRobot::Monitor::Status)
  end

  module Log
    Type = WatchList::Utils.const_to_hash(UptimeRobot::Log::Type)
  end

  module AlertContact
    Type = WatchList::Utils.const_to_hash(UptimeRobot::AlertContact::Type)
  end
end
