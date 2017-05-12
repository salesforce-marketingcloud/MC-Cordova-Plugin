#import "CDVETConstants.h"

#pragma mark - App Defaults
CGFloat const kCDVAppCustomTextSize = 15.0;
NSString *const kCDVAppBarcodeFont = @"Free3of9Extended";
NSString *const kCDVAppSettingsPlistName = @"settings.plist";

#pragma mark - Attributes
NSString *const kCDVAttributeFirstName = @"FirstName";
NSString *const kCDVAttributeLastName = @"LastName";

#pragma mark - CloudPage Inbox
NSUInteger const kCDVCloudPageFilterSegmentControlAllIndex = 0;
NSUInteger const kCDVCloudPageFilterSegmentControlUnreadIndex = 1;
NSUInteger const kCDVCloudPageFilterSegmentControlReadIndex = 2;

#pragma mark - Info Table View
NSString *const kCDVInfoAppVersion = @"k_APP_VERSION";
NSString *const kCDVInfoAppBundleID = @"k_APP_BUNDLE_ID";
NSString *const kCDVInfoBuildNumber = @"k_BUILD_NUMBER";
NSString *const kCDVInfoSDKVersion = @"k_SDK_VERSION";
NSString *const kCDVInfoBuildType = @"k_BUILD_TYPE";
NSString *const kCDVInfoConfigName = @"k_CONFIG_NAME";
NSString *const kCDVInfoAppID = @"k_APP_ID";
NSString *const kCDVInfoAccessToken = @"k_ACCESS_TOKEN";
NSString *const kCDVInfoClientID = @"k_CLIENT_ID";
NSString *const kCDVInfoClientSecret = @"k_CLIENT_SECRET";
NSString *const kCDVInfoMessageIDVanilla = @"k_MESSAGE_ID_VANILLA";
NSString *const kCDVInfoMessageIDCloudPage = @"k_MESSAGE_ID_CLOUDPAGE";
NSString *const kCDVInfoPushEnabled = @"k_PUSH_ENABLED";
NSString *const kCDVInfoDeviceToken = @"k_DEVICE_TOKEN";
NSString *const kCDVInfoDeviceID = @"k_DEVICE_ID";
NSString *const kCDVInfoOpenDirectDelegate = @"k_OPENDIRECT_DELEGATE";
NSString *const kCDVInfoLocationEnabled = @"k_LOCATION_ENABLED";
NSString *const kCDVInfoAttributeFirstName = @"k_ATTR_FIRST";
NSString *const kCDVInfoAttributeLastName = @"k_ATTR_LAST";
NSString *const kCDVInfoAttributeActivityTags = @"k_ACTIVITY_TAGS";

#pragma mark - Message Detail Table View

// tags
NSUInteger const kCDVMessageDetailSendButtonTag = 7645745;
NSUInteger const kCDVMessageDetailSwitchTag = 4322;
NSUInteger const kCDVMessageDetailTextFieldTag = 1234324;
NSUInteger const kCDVMessageDetailSegmentedControlTag = 7437381;

// custom keys
NSString *const kCDVMessageDetailCustomKeyDiscountCode = @"discount_code";

// textfield defaults
NSString *const kCDVAppMessageDetailDefaultMessageText = @"Type something...";
NSString *const kCDVMessageDetailDefaultOpenDirect = @"http://www.exacttarget.com";

// push method segment
NSUInteger const kCDVMessageDetailAlertSegmentIndex = 0;
NSUInteger const kCDVMessageDetailAlertCloudPageSegmentIndex = 1;

// custom sound picker
NSUInteger const kCDVMessageDetailPickerSoundDefaultIndex = 0;
NSUInteger const kCDVMessageDetailPickerSoundCustomIndex = 1;
NSUInteger const kCDVMessageDetailPickerSoundNoneIndex = 2;

// custom key picker
NSUInteger const kCDVMessageDetailPickerCustomKeyNoneIndex = 0;
NSUInteger const kCDVMessageDetailPickerCustomKey10Index = 1;
NSUInteger const kCDVMessageDetailPickerCustomKey20Index = 2;
NSUInteger const kCDVMessageDetailPickerCustomKey30Index = 3;

#pragma mark - Messages Payload
NSString *const kCDVMessagePayloadSoundKey = @"sound";
NSString *const kCDVMessagePayloadMessageTextKey = @"messageText";
NSString *const kCDVMessagePayloadOverrideKey = @"override";
NSString *const kCDVMessagePayloadDeviceTokensKey = @"deviceTokens";
NSString *const kCDVMessagePayloadBadgeKey = @"badge";
NSString *const kCDVMessagePayloadTagsKey = @"inclusionTags";
NSString *const kCDVMessagePayloadOpenDirectKey = @"openDirect";
NSString *const kCDVMessagePayloadCustomKeysKey = @"customKeys";
NSString *const kCDVMessagePayloadCloudPageKey = @"cloudPage";

// badge values
NSString *const kCDVMessagePayloadDefaultBadgeValue = @"+0";

// sound values
NSString *const kCDVMessagePayloadSoundDefault = @"default";
NSString *const kCDVMessagePayloadSoundCustom = @"custom.caf";
NSString *const kCDVMessagePayloadSoundNone = nil;

// custom key values
NSString *const kCDVMessagePayloadCustomKeyNone = @"None";
NSString *const kCDVMessagePayloadCustomKey10 = @"10%";
NSString *const kCDVMessagePayloadCustomKey20 = @"20%";
NSString *const kCDVMessagePayloadCustomKey30 = @"30%";

#pragma mark - Messages Table View
NSUInteger const kCDVMessagesLastReceivedSectionIndex = 0;
NSUInteger const kCDVMessagesPushTestsSectionIndex = 1;

#pragma mark - Message Types
NSString *const kCDVMessageTypeLocation = @"Location";
NSString *const kCDVMessageTypeOutbound = @"Outbound";

#pragma mark - Push Defines
NSString *const kCDVPushDefineOpenDirectPayloadKey = @"_od";
NSString *const kCDVPushDefineCloudPagePayloadKey = @"_x";

#pragma mark - Reuse Identifiers
NSString *const kCDVReuseIdentifierDiscountCell = @"ruid_discountCell";
NSString *const kCDVReuseIdentifierInfoCell = @"ruid_infoCell";
NSString *const kCDVReuseIdentifierMessageCell = @"ruid_messageCell";
NSString *const kCDVReuseIdentifierMessageDetailCell = @"ruid_messageDetailCell";
NSString *const kCDVReuseIdentifierPushReceivedCell = @"ruid_pushReceivedCell";
NSString *const kCDVReuseIdentifierSettingCell = @"ruid_settingCell";
NSString *const kCDVReuseIdentifierTagCell = @"ruid_tagCell";
NSString *const kCDVReuseIdentifierCloudPageInboxCell = @"ruid_cloudPageInboxCell";
NSString *const kCDVReuseIdentifierPushConfigCell = @"ruid_pushConfigCell";

#pragma mark - Segues
NSString *const kCDVSegueMessagesToLastReceivedPush = @"seg_messagesToLastReceivedPush";
NSString *const kCDVSegueMessagesToMessageDetail = @"seg_messagesToMessagesDetail";
NSString *const kCDVSeguePushReceivedToDiscount = @"seg_pushReceivedToDiscount";

#pragma mark - Settings Table View
NSUInteger const kCDVSettingsPersonalInformationSectionIndex = 0;
NSUInteger const kCDVSettingsActivitySectionIndex = 1;

#pragma mark - Storyboard Identifiers
NSString *const kCDVStoryboardIdentifierPushReceivedTableViewController = @"sb_pushReceivedTableViewController";
NSString *const kCDVStoryboardIdentifierDiscountCodeViewController = @"sb_discountCodeViewController";
NSString *const kCDVStoryboardIdentifierPushConfigTable = @"sb_pushConfigTableViewController";

#pragma mark - Storyboard Name
NSString *const kCDVStoryboardMain = @"Main";

#pragma mark - Tags
NSString *const kCDVTagCampingGear = @"Camping Gear";
NSString *const kCDVTagHikingSupplies= @"Hiking Supplies";
NSString *const kCDVTagBoatingGear = @"Boating Gear";
NSString *const kCDVTagFishingSupplies = @"Fishing Supplies";
NSString *const kCDVTagHuntingGear = @"Hunting Gear";

#pragma mark - User Defaults
NSString *const kCDVUserDefaultsFirstName = @"ud_firstName";
NSString *const kCDVUserDefaultsLastName = @"ud_lastName";
NSString *const kCDVUserDefaultsLastPushReceivedDate = @"ud_lastPushReceivedDate";
NSString *const kCDVUserDefaultsPushUserInfo = @"ud_pushUserInfo";
NSString *const kCDVUserDefaultsMessageType = @"ud_messageType";
NSString *const kCDVUserDefaultsAlertText = @"ud_alertText";

#pragma mark - Configs UserDefaults
NSString *const kCDVUserDefaultsConfigName = @"ud_configName";
NSString *const kCDVUserDefaultsAppID = @"ud_appId";
NSString *const kCDVUserDefaultsAccessToken = @"ud_accessToken";
NSString *const kCDVUserDefaultsClientID = @"ud_clientId";
NSString *const kCDVUserDefaultsClientSecret = @"ud_clientSecret";
NSString *const kCDVUserDefaultsMessageIDVanilla = @"ud_standardMessageId";
NSString *const kCDVUserDefaultsMessageIDCloudPage = @"ud_CloudpageMessageId";
NSString *const kCDVUserDefaultsRestUrl = @"ud_RestUrl";

#pragma mark - Configs Table View
NSUInteger const kCDVConfigsDefaultIndex = 0;
//NSUInteger const kCDVConfigsCustomIndex = 1;

#pragma mark - Notifications
NSString *const kCDVPushConfigChangedNotification = @"PushConfigChangedNotification";
NSString *const kCDVNewPushConfigAddedNotication =  @"PushConfigAddedNotification";
NSString *const kCDVPreferencesChanged =  @"PreferencesChanged";