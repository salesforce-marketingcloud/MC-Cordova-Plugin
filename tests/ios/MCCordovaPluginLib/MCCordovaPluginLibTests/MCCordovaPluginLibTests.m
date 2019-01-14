// MCCordovaPluginLibTests.m
//
// Copyright (c) 2018 Salesforce, Inc
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer. Redistributions in binary
// form must reproduce the above copyright notice, this list of conditions and
// the following disclaimer in the documentation and/or other materials
// provided with the distribution. Neither the name of the nor the names of
// its contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import <MarketingCloudSDK/MarketingCloudSDK.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "MCCordovaPlugin.h"

@interface MCCordovaPluginLibTests : XCTestCase
@property(strong, nonatomic) id sdk;
@property(strong, nonatomic) MCCordovaPlugin *plugin;
@property(strong, nonatomic) id<CDVCommandDelegate> commandDelegate;
@end

@implementation MCCordovaPluginLibTests

- (void)setUp {
    [super setUp];

    _sdk = OCMClassMock([MarketingCloudSDK class]);
    OCMStub(ClassMethod([_sdk sharedInstance])).andReturn(_sdk);

    _plugin = [MCCordovaPlugin alloc];
    [_plugin pluginInitialize];

    _commandDelegate = OCMProtocolMock(@protocol(CDVCommandDelegate));
    _plugin.commandDelegate = _commandDelegate;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the
    // class.
    [super tearDown];
}

- (void)testEnableVerboseLogging {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"enableVerboseLogging"];

    // WHEN
    [_plugin enableVerboseLogging:command];

    // THEN
    OCMVerify([_sdk sfmc_setDebugLoggingEnabled:YES]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testDisableVerboseLogging {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"disableVerboseLogging"];

    // WHEN
    [_plugin disableVerboseLogging:command];

    // THEN
    OCMVerify([_sdk sfmc_setDebugLoggingEnabled:NO]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testGetSystemToken {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"getSystemToken"];
    OCMStub([_sdk sfmc_deviceToken]).andReturn(@"testSystemToken");

    // WHEN
    [_plugin getSystemToken:command];

    // THEN
    OCMVerify([_sdk sfmc_deviceToken]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK &&
                 [result.message isEqualToString:@"testSystemToken"];
        }]
              callbackId:@"testCallback"]);
}

- (void)testIsPushEnabled_NO {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"isPushEnabled"];
    OCMStub([_sdk sfmc_pushEnabled]).andReturn(NO);

    // WHEN
    [_plugin isPushEnabled:command];

    // THEN
    OCMVerify([_sdk sfmc_pushEnabled]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 0;
        }]
              callbackId:@"testCallback"]);
}

- (void)testIsPushEnabled_YES {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"isPushEnabled"];
    OCMStub([_sdk sfmc_pushEnabled]).andReturn(YES);

    // WHEN
    [_plugin isPushEnabled:command];

    // THEN
    OCMVerify([_sdk sfmc_pushEnabled]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 1;
        }]
              callbackId:@"testCallback"]);
}

- (void)testEnablePush {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"enablePush"];

    // WHEN
    [_plugin enablePush:command];

    // THEN
    OCMVerify([_sdk sfmc_setPushEnabled:YES]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testDisablePush {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"disablePush"];

    // WHEN
    [_plugin disablePush:command];

    // THEN
    OCMVerify([_sdk sfmc_setPushEnabled:NO]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testSetAttribute_success {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"TestKey", @"TestValue" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"setAttribute"];
    OCMStub([_sdk sfmc_setAttributeNamed:[OCMArg any] value:[OCMArg any]]).andReturn(YES);

    // WHEN
    [_plugin setAttribute:command];

    // THEN
    OCMVerify([_sdk sfmc_setAttributeNamed:@"TestKey" value:@"TestValue"]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 1;
        }]
              callbackId:@"testCallback"]);
}

- (void)testSetAttribute_failed {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"TestKey", @"TestValue" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"setAttribute"];
    OCMStub([_sdk sfmc_setAttributeNamed:[OCMArg any] value:[OCMArg any]]).andReturn(NO);

    // WHEN
    [_plugin setAttribute:command];

    // THEN
    OCMVerify([_sdk sfmc_setAttributeNamed:@"TestKey" value:@"TestValue"]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 0;
        }]
              callbackId:@"testCallback"]);
}

- (void)testClearAttribute_success {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"TestKey" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"clearAttribute"];
    OCMStub([_sdk sfmc_clearAttributeNamed:[OCMArg any]]).andReturn(YES);

    // WHEN
    [_plugin clearAttribute:command];

    // THEN
    OCMVerify([_sdk sfmc_clearAttributeNamed:@"TestKey"]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 1;
        }]
              callbackId:@"testCallback"]);
}

- (void)testClearAttribute_failed {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"TestKey" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"clearAttribute"];
    OCMStub([_sdk sfmc_clearAttributeNamed:[OCMArg any]]).andReturn(NO);

    // WHEN
    [_plugin clearAttribute:command];

    // THEN
    OCMVerify([_sdk sfmc_clearAttributeNamed:@"TestKey"]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 0;
        }]
              callbackId:@"testCallback"]);
}

- (void)testGetAttributes {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"getAttributes"];
    OCMStub([_sdk sfmc_attributes]).andReturn(@{@"TestKey" : @"TestVal"});

    // WHEN
    [_plugin getAttributes:command];

    // THEN
    OCMVerify([_sdk sfmc_attributes]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return
              [result.status intValue] == CDVCommandStatus_OK &&
              [[(NSDictionary *)result.message valueForKey:@"TestKey"] isEqualToString:@"TestVal"];
        }]
              callbackId:@"testCallback"]);
}

- (void)testGetAttributes_nil {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"getAttributes"];
    OCMStub([_sdk sfmc_attributes]).andReturn(nil);

    // WHEN
    [_plugin getAttributes:command];

    // THEN
    OCMVerify([_sdk sfmc_attributes]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && result.message != nil &&
                 [(NSDictionary *)result.message count] == 0;
        }]
              callbackId:@"testCallback"]);
}

- (void)testGetContactKey {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"getContactKey"];
    OCMStub([_sdk sfmc_contactKey]).andReturn(@"testContactKey");

    // WHEN
    [_plugin getContactKey:command];

    // THEN
    OCMVerify([_sdk sfmc_contactKey]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK &&
                 [result.message isEqualToString:@"testContactKey"];
        }]
              callbackId:@"testCallback"]);
}

- (void)testSetContactKey_success {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"testContactKey" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"setContactKey"];
    OCMStub([_sdk sfmc_setContactKey:[OCMArg any]]).andReturn(YES);

    // WHEN
    [_plugin setContactKey:command];

    // THEN
    OCMVerify([_sdk sfmc_setContactKey:@"testContactKey"]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 1;
        }]
              callbackId:@"testCallback"]);
}

- (void)testSetContactKey_failed {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"testContactKey" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"setContactKey"];
    OCMStub([_sdk sfmc_setContactKey:[OCMArg any]]).andReturn(NO);

    // WHEN
    [_plugin setContactKey:command];

    // THEN
    OCMVerify([_sdk sfmc_setContactKey:@"testContactKey"]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 0;
        }]
              callbackId:@"testCallback"]);
}

- (void)testAddTag_success {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"testTag" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"addTag"];
    OCMStub([_sdk sfmc_addTag:[OCMArg any]]).andReturn(YES);

    // WHEN
    [_plugin addTag:command];

    // THEN
    OCMVerify([_sdk sfmc_addTag:@"testTag"]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 1;
        }]
              callbackId:@"testCallback"]);
}

- (void)testAddTag_failed {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"testTag" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"addTag"];
    OCMStub([_sdk sfmc_addTag:[OCMArg any]]).andReturn(NO);

    // WHEN
    [_plugin addTag:command];

    // THEN
    OCMVerify([_sdk sfmc_addTag:@"testTag"]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 0;
        }]
              callbackId:@"testCallback"]);
}

- (void)testRemoveTag_success {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"testTag" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"removeTag"];
    OCMStub([_sdk sfmc_removeTag:[OCMArg any]]).andReturn(YES);

    // WHEN
    [_plugin removeTag:command];

    // THEN
    OCMVerify([_sdk sfmc_removeTag:@"testTag"]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 1;
        }]
              callbackId:@"testCallback"]);
}

- (void)testRemoveTag_failed {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"testTag" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"removeTag"];
    OCMStub([_sdk sfmc_removeTag:[OCMArg any]]).andReturn(NO);

    // WHEN
    [_plugin removeTag:command];

    // THEN
    OCMVerify([_sdk sfmc_removeTag:@"testTag"]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 0;
        }]
              callbackId:@"testCallback"]);
}

- (void)testGetTags {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"getTags"];
    NSArray *tags = @[ @"Tag1", @"Tag2" ];
    OCMStub([_sdk sfmc_tags]).andReturn(tags);

    // WHEN
    [_plugin getTags:command];

    // THEN
    OCMVerify([_sdk sfmc_tags]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          NSArray *resultTags = (NSArray *)result.message;
          return [result.status intValue] == CDVCommandStatus_OK && resultTags != nil &&
                 [[resultTags objectAtIndex:0] isEqualToString:@"Tag1"] &&
                 [[resultTags objectAtIndex:1] isEqualToString:@"Tag2"];
        }]
              callbackId:@"testCallback"]);
}

- (void)testGetTags_nil {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"getTags"];
    OCMStub([_sdk sfmc_tags]).andReturn(nil);

    // WHEN
    [_plugin getTags:command];

    // THEN
    OCMVerify([_sdk sfmc_tags]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && result.message != nil &&
                 [(NSArray *)result.message count] == 0;
        }]
              callbackId:@"testCallback"]);
}

- (void)
    testNotificationReceived_beforeEventCallbackCalled_beforeSubscribeCalled_shouldBeDeliveredWhenSubscribed {
    // GIVEN
    [self sendTestNotification:@{@"aps" : @{}}];
    [_plugin registerEventsChannel:[MCCordovaPluginLibTests eventCallbackCommand]];

    // WHEN
    [_plugin subscribe:[MCCordovaPluginLibTests notificationOpenedSubscribeCommand]];

    // THEN
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg any] callbackId:@"eventCallback"]);
}

- (void)
    testNotificationReceived_afterEventCallbackCalled_beforeSubscribeCalled_shouldBeDeliveredWhenSubscribed {
    // GIVEN
    [_plugin registerEventsChannel:[MCCordovaPluginLibTests eventCallbackCommand]];
    [self sendTestNotification:@{@"aps" : @{}}];

    // WHEN
    [_plugin subscribe:[MCCordovaPluginLibTests notificationOpenedSubscribeCommand]];

    // THEN
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg any] callbackId:@"eventCallback"]);
}

- (void)
    testNotificationReceived_afterEventCallbackCalled_afterSubscribeCalled_shouldBeDeliveredImmediately {
    // GIVEN
    [_plugin registerEventsChannel:[MCCordovaPluginLibTests eventCallbackCommand]];
    [_plugin subscribe:[MCCordovaPluginLibTests notificationOpenedSubscribeCommand]];

    // WHEN
    [self sendTestNotification:@{@"aps" : @{}}];

    // THEN
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg any] callbackId:@"eventCallback"]);
}

- (void)testNotificationReceived_OD_withAlertTitleSubTitle {
    // GIVEN
    [_plugin registerEventsChannel:[MCCordovaPluginLibTests eventCallbackCommand]];
    [_plugin subscribe:[MCCordovaPluginLibTests notificationOpenedSubscribeCommand]];

    NSDictionary *payload = @{
        @"_sid" : @"SFMC",
        @"_m" : @"messageId",
        @"_od" : @"http://salesforce.com",
        @"aps" : @{
            @"alert" : @{
                @"body" : @"Alert Body",
                @"title" : @"Alert Title",
                @"subtitle" : @"Alert Subtitle"
            }
        }
    };

    // WHEN
    [self sendTestNotification:payload];

    // THEN
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [self validateResult:result forOpenedNotification:payload];
        }]
              callbackId:@"eventCallback"]);
}

- (void)testNotificationReceived_CP_withAlert_old {
    // GIVEN
    [_plugin registerEventsChannel:[MCCordovaPluginLibTests eventCallbackCommand]];
    [_plugin subscribe:[MCCordovaPluginLibTests notificationOpenedSubscribeCommand]];

    NSDictionary *payload = @{
        @"_sid" : @"SFMC",
        @"_m" : @"messageId",
        @"_x" : @"http://salesforce.com",
        @"aps" : @{@"alert" : @"Alert Body"}
    };

    // WHEN
    [self sendTestNotification:payload];

    // THEN
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [self validateResult:result forOpenedNotification:payload];
        }]
              callbackId:@"eventCallback"]);
}

- (void)testNotificationReceived_noUrl_withAlertTitle {
    // GIVEN
    [_plugin registerEventsChannel:[MCCordovaPluginLibTests eventCallbackCommand]];
    [_plugin subscribe:[MCCordovaPluginLibTests notificationOpenedSubscribeCommand]];

    NSDictionary *payload = @{
        @"_sid" : @"SFMC",
        @"_m" : @"messageId",
        @"aps" : @{@"alert" : @{@"body" : @"Alert Body", @"title" : @"Alert Title"}}
    };

    // WHEN
    [self sendTestNotification:payload];

    // THEN
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [self validateResult:result forOpenedNotification:payload];
        }]
              callbackId:@"eventCallback"]);
}

- (void)testNotificationReceived_silentPush_notSentToCordova {
    // GIVEN
    [_plugin registerEventsChannel:[MCCordovaPluginLibTests eventCallbackCommand]];
    [_plugin subscribe:[MCCordovaPluginLibTests notificationOpenedSubscribeCommand]];

    NSDictionary *payload =
        @{@"_sid" : @"SFMC", @"_m" : @"messageId", @"aps" : @{@"content-available" : @1}};

    // Hack in failure when sendPluginResult it called.  Couldn't seem to get OCMock's `reject` to
    // work...
    OCMStub([_commandDelegate sendPluginResult:[OCMArg any] callbackId:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
          XCTFail("sendPluginResult should not be called");
        });

    // WHEN
    [self sendTestNotification:payload];
}

- (void)sendTestNotification:(NSDictionary *)notification {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.userInfo = notification;
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"NDY5NjoxMTQ6MA"
                                                                          content:content
                                                                          trigger:nil];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:SFMCFoundationUNNotificationReceivedNotification
                      object:self
                    userInfo:@{
                        @"SFMCFoundationUNNotificationReceivedNotificationKeyUNNotificationReques"
                        @"t" : request
                    }];
}

- (BOOL)validateResult:(CDVPluginResult *)result
    forOpenedNotification:(NSDictionary *)notification {
    XCTAssertEqual([result.status intValue], CDVCommandStatus_OK);
    XCTAssertTrue([result.message isKindOfClass:[NSDictionary class]]);
    XCTAssertTrue(result.keepCallback);

    NSDictionary *message = result.message;
    XCTAssertTrue([[message objectForKey:@"timeStamp"] isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects([message objectForKey:@"type"], @"notificationOpened");
    XCTAssertTrue([[message objectForKey:@"values"] isKindOfClass:[NSDictionary class]]);
    NSDictionary *values = [message objectForKey:@"values"];

    NSSet *notificationKeys = [NSSet setWithArray:notification.allKeys];
    Boolean hadUrl = false;
    for (id key in notificationKeys) {
        if ([key isEqualToString:@"aps"]) {
            NSDictionary *aps = [notification objectForKey:key];
            if ([[aps objectForKey:@"alert"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *alert = [aps objectForKey:@"alert"];
                NSSet *alertKeys = [NSSet setWithArray:alert.allKeys];
                for (id alertKey in alertKeys) {
                    NSString *valuesKey = [alertKeys isEqual:@"body"] ? @"alert" : valuesKey;
                    XCTAssertEqualObjects([values objectForKey:valuesKey],
                                          [aps objectForKey:alertKey]);
                }
            } else {
                XCTAssertEqualObjects([values objectForKey:@"alert"], [aps objectForKey:@"alert"]);
            }

        } else if ([key isEqualToString:@"_od"]) {
            XCTAssertEqualObjects([values objectForKey:@"url"], [notification objectForKey:key]);
            XCTAssertEqualObjects([values objectForKey:@"type"], @"openDirect");
            hadUrl = true;
        } else if ([key isEqualToString:@"_x"]) {
            XCTAssertEqualObjects([values objectForKey:@"url"], [notification objectForKey:key]);
            XCTAssertEqualObjects([values objectForKey:@"type"], @"cloudPage");
            hadUrl = true;
        } else {
            XCTAssertEqualObjects([values objectForKey:key], [notification objectForKey:key]);
        }
    }

    if (!hadUrl) {
        XCTAssertNil([values objectForKey:@"url"]);
        XCTAssertEqualObjects([values objectForKey:@"type"], @"other");
    }
    return YES;
}

+ (CDVInvokedUrlCommand *)eventCallbackCommand {
    return [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                callbackId:@"eventCallback"
                                                 className:@"MCCordovaPlugin"
                                                methodName:@"registerEventsChannel"];
}

+ (CDVInvokedUrlCommand *)notificationOpenedSubscribeCommand {
    return [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"notificationOpened" ]
                                                callbackId:@"subCallback"
                                                 className:@"MCCordovaPlugin"
                                                methodName:@"subscribe"];
}

@end
