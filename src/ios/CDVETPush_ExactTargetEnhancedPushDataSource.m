
#import "CDVETPush_ExactTargetEnhancedPushDataSource.h"

#import "ExactTargetEnhancedPushDataSource.h"

#import "CDVETPush.h"
#import "ETPush.h"
#import "ExactTargetEnhancedPushDataSource.h"
#import "ETMessage.h"


@interface CDVETPush () {}
@end

@implementation CDVETPush_ExactTargetEnhancedPushDataSource

// Get all inbox messages
// self.messages is referenced. CDVETPush_ExactTargetEnhancedPushDataSource
// is a subclass of ExactTargetEnhancedPushDataSource which has a property called messages.
- (NSMutableDictionary *)getInboxMessages {
    NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] init];
    [messageDict setObject:[NSNumber numberWithInt:self.messages.count] forKey:@"count"];
    NSMutableArray *theMessages = [[NSMutableArray alloc] init];
    
    int unread = 0;
    for(int i = 0; i < self.messages.count; i++) {
        ETMessage *myMessage = [ETMessage getMessageByIdentifier:[self.messages[i] messageIdentifier]];
        NSMutableDictionary *aMessage = [[NSMutableDictionary alloc] init];
        [aMessage setObject:[self.messages[i] messageIdentifier] forKey:@"id"];
        [aMessage setObject:[NSNumber numberWithBool:myMessage.read] forKey:@"isRead"];
        if (!myMessage.read) unread++;
        [aMessage setObject:myMessage.subject forKey:@"subject"];
        [aMessage setObject:myMessage.siteUrlAsString forKey:@"webPageUrl"];
        
        [theMessages addObject:aMessage];
    }
    [messageDict setObject:[NSNumber numberWithInt:unread] forKey:@"unread"];
    [messageDict setObject:theMessages forKey:@"messages"];
    return messageDict;
}

- (NSMutableDictionary *)markAsRead:(NSString *)messageId {
    ETMessage *myMessage = [ETMessage getMessageByIdentifier:messageId];
    [myMessage markAsRead];
    return [self getInboxMessages];
}

- (NSMutableDictionary *)markAsDeleted:(NSString *)messageId {
    ETMessage *myMessage = [ETMessage getMessageByIdentifier:messageId];
    [myMessage markAsDeleted];
    return [self getInboxMessages];
}


@end