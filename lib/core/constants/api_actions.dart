class ApiActions {
  ApiActions._();

  // Auth
  static const String login = 'LOGIN';
  static const String register = 'REGISTER';
  static const String changePassword = 'CHANGE_PASSWORD';
  static const String ping = 'PING';

  // User data
  static const String fetchUserData = 'FETCH_USER_DATA';
  static const String fetchAllUsers = 'FETCH_ALL_USERS';
  static const String fullSyncPull = 'FULL_SYNC_PULL';
  static const String updateUserSheet = 'UPDATE_USER_SHEET';

  // Admin
  static const String adminUpdateUser = 'ADMIN_UPDATE_USER';
  static const String adminApprove = 'ADMIN_APPROVE';
  static const String adminDeleteUser = 'ADMIN_DELETE_USER';
  static const String approveProgram = 'APPROVE_PROGRAM';

  // Subscription
  static const String subRequest = 'SUB_REQUEST';
  static const String getSubRequests = 'GET_SUB_REQUESTS';
  static const String updateSubRequest = 'UPDATE_SUB_REQUEST';
  static const String subConfig = 'SUB_CONFIG';

  // Chat
  static const String fetchMsgs = 'FETCH_MSGS';
  static const String sendMsg = 'SEND_MSG';
  static const String deleteMsg = 'DELETE_MSG';
  static const String editMsg = 'EDIT_MSG';
  static const String pinMsg = 'PIN_MSG';
  static const String unpinMsg = 'UNPIN_MSG';
  static const String getPinned = 'GET_PINNED';
  static const String chatBan = 'CHAT_BAN';
  static const String chatMute = 'CHAT_MUTE';
  static const String sendFileMsg = 'SEND_FILE_MSG';

  // Promo codes
  static const String promoCheck = 'PROMO_CHECK';
  static const String promoCreate = 'PROMO_CREATE';
  static const String promoList = 'PROMO_LIST';
  static const String promoDelete = 'PROMO_DELETE';

  // Guest codes
  static const String guestCreate = 'GUEST_CREATE';
  static const String guestList = 'GUEST_LIST';
  static const String guestDelete = 'GUEST_DELETE';

  // Profile & Media
  static const String saveProfilePic = 'SAVE_PROFILE_PIC';

  // Force logout & ban
  static const String forceLogoutUser = 'FORCE_LOGOUT_USER';
  static const String forceLogoutAll = 'FORCE_LOGOUT_ALL';
  static const String banIdentity = 'BAN_IDENTITY';
  static const String unbanIdentity = 'UNBAN_IDENTITY';
  static const String listBanned = 'LIST_BANNED';
  static const String checkBan = 'CHECK_BAN';

  // Referral
  static const String getReferralStats = 'GET_REFERRAL_STATS';

  // Version check
  static const String versionCheck = 'VERSION_CHECK';
}
