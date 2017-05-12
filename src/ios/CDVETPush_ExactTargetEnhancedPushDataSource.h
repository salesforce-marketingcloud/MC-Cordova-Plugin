
#import <UIKit/UIKit.h>

// Libraries
#import "ExactTargetEnhancedPushDataSource.h"

@class ETMessage;

@interface CDVETPush_ExactTargetEnhancedPushDataSource : ExactTargetEnhancedPushDataSource

- (NSMutableDictionary *)getInboxMessages;
- (NSMutableDictionary *)markAsRead:(NSString *)messageId;
- (NSMutableDictionary *)markAsDeleted:(NSString *)messageId;

@end