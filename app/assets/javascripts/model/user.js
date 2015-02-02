function User(item) {
  this.name = item.name
  this.email = item.email
  this.displayName = item.display_name
  this.avatarUrl = item.avatar_url

  this.smallAvatarUrl = item.small_avatar_url
  this.mediumAvatarUrl = item.medium_avatar_url
  this.largeAvatarUrl = item.large_avatar_url

  this.isCurrent = item.is_current
  this.roles = item.roles
  this.isLocked = item.is_locked
  this.isConfirmed = item.is_confirmed
}