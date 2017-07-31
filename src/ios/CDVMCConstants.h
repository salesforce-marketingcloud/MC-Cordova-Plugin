#pragma mark - Defines

#define IOS_PRE_7_0 (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)

#pragma mark - TypeDefs
typedef CGFloat (^CellHeightBlock)();
typedef void (^ConfigureCellBlock)(UITableViewCell *);
typedef void (^PickerViewRowSelectedBlock)(UIPickerView *);
typedef void (^SwitchValueChangedBlock)(UISwitch *);
typedef void (^TextFieldDidEndEditingBlock)(UITextField *);
typedef void (^SegmentedControlerValueChangedBlock)(UISegmentedControl *);

#pragma mark - App Defaults
extern CGFloat const kCDVAppCustomTextSize;
extern NSString *const kCDVAppBarcodeFont;
extern NSString *const kCDVAppSettingsPlistName;

#pragma mark - Attributes
extern NSString *const kCDVAttributeFirstName;
extern NSString *const kCDVAttributeLastName;

#pragma mark - CloudPage Inbox
extern NSUInteger const kCDVCloudPageFilterSegmentControlAllIndex;
extern NSUInteger const kCDVCloudPageFilterSegmentControlUnreadIndex;
extern NSUInteger const kCDVCloudPageFilterSegmentControlReadIndex;

#pragma mark - Info Table View
extern NSString *const kCDVInfoAppVersion;
extern NSString *const kCDVInfoAppBundleID;
extern NSString *const kCDVInfoBuildNumber;
extern NSString *const kCDVInfoSDKVersion;
extern NSString *const kCDVInfoBuildType;
extern NSString *const kCDVInfoConfigName;
extern NSString *const kCDVInfoAppID;
extern NSString *const kCDVInfoAccessToken;
extern NSString *const kCDVInfoClientID;
extern NSString *const kCDVInfoClientSecret;
extern NSString *const kCDVInfoMessageIDVanilla;
extern NSString *const kCDVInfoMessageIDCloudPage;
extern NSString *const kCDVInfoPushEnabled;
extern NSString *const kCDVInfoDeviceToken;
extern NSString *const kCDVInfoDeviceID;
extern NSString *const kCDVInfoOpenDirectDelegate;
extern NSString *const kCDVInfoLocationEnabled;
extern NSString *const kCDVInfoAttributeFirstName;
extern NSString *const kCDVInfoAttributeLastName;
extern NSString *const kCDVInfoAttributeActivityTags;

#pragma mark - Message Detail Table View

// tags
extern NSUInteger const kCDVMessageDetailSendButtonTag;
extern NSUInteger const kCDVMessageDetailSwitchTag;
extern NSUInteger const kCDVMessageDetailTextFieldTag;
extern NSUInteger const kCDVMessageDetailSegmentedControlTag;

// custom keys
extern NSString *const kCDVMessageDetailCustomKeyDiscountCode;

// textfield defaults
extern NSString *const kCDVAppMessageDetailDefaultMessageText;
extern NSString *const kCDVMessageDetailDefaultOpenDirect;

// push method segment
extern NSUInteger const kCDVMessageDetailAlertSegmentIndex;
extern NSUInteger const kCDVMessageDetailAlertCloudPageSegmentIndex;

// custom sound picker
extern NSUInteger const kCDVMessageDetailPickerSoundDefaultIndex;
extern NSUInteger const kCDVMessageDetailPickerSoundCustomIndex;
extern NSUInteger const kCDVMessageDetailPickerSoundNoneIndex;

// custom key picker
extern NSUInteger const kCDVMessageDetailPickerCustomKeyNoneIndex;
extern NSUInteger const kCDVMessageDetailPickerCustomKey10Index;
extern NSUInteger const kCDVMessageDetailPickerCustomKey20Index;
extern NSUInteger const kCDVMessageDetailPickerCustomKey30Index;

#pragma mark - Messages Payload
extern NSString *const kCDVMessagePayloadSoundKey;
extern NSString *const kCDVMessagePayloadMessageTextKey;
extern NSString *const kCDVMessagePayloadOverrideKey;
extern NSString *const kCDVMessagePayloadDeviceTokensKey;
extern NSString *const kCDVMessagePayloadBadgeKey;
extern NSString *const kCDVMessagePayloadTagsKey;
extern NSString *const kCDVMessagePayloadOpenDirectKey;
extern NSString *const kCDVMessagePayloadCustomKeysKey;
extern NSString *const kCDVMessagePayloadCloudPageKey;

// badge values
extern NSString *const kCDVMessagePayloadDefaultBadgeValue;

// sound values
extern NSString *const kCDVMessagePayloadSoundDefault;
extern NSString *const kCDVMessagePayloadSoundCustom;
extern NSString *const kCDVMessagePayloadSoundNone;

// custom key values
extern NSString *const kCDVMessagePayloadCustomKeyNone;
extern NSString *const kCDVMessagePayloadCustomKey10;
extern NSString *const kCDVMessagePayloadCustomKey20;
extern NSString *const kCDVMessagePayloadCustomKey30;

#pragma mark - Messages Table View
extern NSUInteger const kCDVMessagesLastReceivedSectionIndex;
extern NSUInteger const kCDVMessagesPushTestsSectionIndex;

#pragma mark - Message Types
extern NSString *const kCDVMessageTypeLocation;
extern NSString *const kCDVMessageTypeOutbound;

#pragma mark - Push Defines
extern NSString *const kCDVPushDefineOpenDirectPayloadKey;
extern NSString *const kCDVPushDefineCloudPagePayloadKey;

#pragma mark - Reuse Identifiers
extern NSString *const kCDVReuseIdentifierDiscountCell;
extern NSString *const kCDVReuseIdentifierInfoCell;
extern NSString *const kCDVReuseIdentifierMessageCell;
extern NSString *const kCDVReuseIdentifierMessageDetailCell;
extern NSString *const kCDVReuseIdentifierPushReceivedCell;
extern NSString *const kCDVReuseIdentifierSettingCell;
extern NSString *const kCDVReuseIdentifierTagCell;
extern NSString *const kCDVReuseIdentifierCloudPageInboxCell;
extern NSString *const kCDVReuseIdentifierPushConfigCell;

#pragma mark - Segues
extern NSString *const kCDVSegueMessagesToLastReceivedPush;
extern NSString *const kCDVSegueMessagesToMessageDetail;
extern NSString *const kCDVSeguePushReceivedToDiscount;

#pragma mark - Settings Table View
extern NSUInteger const kCDVSettingsPushConfigSectionIndex;
extern NSUInteger const kCDVSettingsPersonalInformationSectionIndex;
extern NSUInteger const kCDVSettingsActivitySectionIndex;

#pragma mark - Storyboard Identifiers
extern NSString *const kCDVStoryboardIdentifierPushReceivedTableViewController;
extern NSString *const kCDVStoryboardIdentifierDiscountCodeViewController;
extern NSString *const kCDVStoryboardIdentifierPushConfigTable;

#pragma mark - Storyboard Name
extern NSString *const kCDVStoryboardMain;

#pragma mark - Tags
extern NSString *const kCDVTagCampingGear;
extern NSString *const kCDVTagHikingSupplies;
extern NSString *const kCDVTagBoatingGear;
extern NSString *const kCDVTagFishingSupplies;
extern NSString *const kCDVTagHuntingGear;

#pragma mark - User Defaults
extern NSString *const kCDVUserDefaultsFirstName;
extern NSString *const kCDVUserDefaultsLastName;
extern NSString *const kCDVUserDefaultsLastPushReceivedDate;
extern NSString *const kCDVUserDefaultsPushUserInfo;
extern NSString *const kCDVUserDefaultsMessageType;
extern NSString *const kCDVUserDefaultsAlertText;

#pragma mark - Configs Table View
extern NSUInteger const kCDVConfigsDefaultIndex;
//extern NSUInteger const kCDVConfigsCustomIndex;

#pragma mark - Configs UserDefaults
extern NSString *const kCDVUserDefaultsConfigName;
extern NSString *const kCDVUserDefaultsAppID;
extern NSString *const kCDVUserDefaultsAccessToken;
extern NSString *const kCDVUserDefaultsClientID;
extern NSString *const kCDVUserDefaultsClientSecret;
extern NSString *const kCDVUserDefaultsMessageIDVanilla;
extern NSString *const kCDVUserDefaultsMessageIDCloudPage;
extern NSString *const kCDVUserDefaultsRestUrl;

#pragma mark - Notifications
extern NSString *const kCDVPushConfigChangedNotification;
extern NSString *const kCDVNewPushConfigAddedNotication;
extern NSString *const kCDVPreferencesChanged;