class Types::User::UserBeaconStatus < Types::BaseEnum
  description "user#beacon_status"
  User::BEACON_STATUSES.each{|s| value s}

end
