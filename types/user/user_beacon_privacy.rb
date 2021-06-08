class Types::User::UserBeaconPrivacy < Types::BaseEnum
  description "user#beacon_privacy"
  User::BEACON_PRIVACIES.each{|s| value s}

end
