module Types
  class MutationType < Types::BaseObject
    field :addContestTemplateToPlayground, mutation: Mutations::AddContestTemplateToPlayground
    field :addEventPartyMembers, mutation: Mutations::AddEventPartyMembers
    field :addModerators, mutation: Mutations::AddModerators
    field :alertMod, mutation: Mutations::AlertMod
    field :createContest, mutation: Mutations::CreateContest
    field :createEventParty, mutation: Mutations::CreateEventParty
    field :createOrUpdateMatch, mutation: Mutations::CreateOrUpdateMatch
    field :createPlayground, mutation: Mutations::CreatePlayground
    field :createProfileUpdateRequest, mutation: Mutations::CreateProfileUpdateRequest
    field :endScrimMatchInContest, mutation: Mutations::EndScrimMatchInContest
    field :deleteContest, mutation: Mutations::DeleteContest
    field :deletePlayground, mutation: Mutations::DeletePlayground
    field :editContest, mutation: Mutations::EditContest
    field :editPlayground, mutation: Mutations::EditPlayground
    field :endContest, mutation: Mutations::EndContest
    field :followContest, mutation: Mutations::FollowContest
    field :followUser, mutation: Mutations::FollowUser
    field :joinContest, mutation: Mutations::JoinContest
    field :joinPlayground, mutation: Mutations::JoinPlayground
    field :leavePlayground, mutation: Mutations::LeavePlayground
    field :removeContestTemplateFromPlayground, mutation: Mutations::RemoveContestTemplateFromPlayground
    field :removeEventPartyMember, mutation: Mutations::RemoveEventPartyMember
    field :removeModerator, mutation: Mutations::RemoveModerator
    field :resolveProfileUpdateRequest, mutation: Mutations::ResolveProfileUpdateRequest
    field :startContest, mutation: Mutations::StartContest
    field :unfollowContest, mutation: Mutations::UnfollowContest
    field :unfollowUser, mutation: Mutations::UnfollowUser
    field :updateMatch, mutation: Mutations::UpdateMatch
    field :updateNotificationSetting, mutation: Mutations::UpdateNotificationSetting
    field :updatePartyScoreAdjustment, mutation: Mutations::UpdatePartyScoreAdjustment
    field :updateUserBeaconMessage, mutation: Mutations::UpdateUserBeaconMessage
    field :updateUserBeaconStatus, mutation: Mutations::UpdateUserBeaconStatus
    field :updateUserSettings, mutation: Mutations::UpdateUserSettings
    field :uploadAvatar, mutation: Mutations::UploadAvatar
  end
end
