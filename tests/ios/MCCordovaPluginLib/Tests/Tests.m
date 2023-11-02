//  Tests.m
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
#import <SFMCSDK/SFMCSDK.h>
#import <XCTest/XCTest.h>
#import "MCCordovaPlugin.h"

@interface Tests : XCTestCase

@property(strong, nonatomic) id push;
@property(strong, nonatomic) id sfmcIdentity;
@property(strong, nonatomic) id sfmcSDK;
@property(strong, nonatomic) MCCordovaPlugin *plugin;
@property(strong, nonatomic) id<CDVCommandDelegate> commandDelegate;

@end

@implementation Tests

- (void)setUp {
    [super setUp];

    _push = OCMClassMock([SFMCSdkPUSH class]);
    _sfmcIdentity = OCMClassMock([SFMCSdkIDENTITY class]);

    _sfmcSDK = OCMClassMock([SFMCSdk class]);
    OCMStub(ClassMethod([_sfmcSDK mp])).andReturn(_push);
    OCMStub(ClassMethod([(Class)_sfmcSDK identity])).andReturn(_sfmcIdentity);

    _plugin = [MCCordovaPlugin alloc];

    _commandDelegate = OCMProtocolMock(@protocol(CDVCommandDelegate));
    NSMutableDictionary *pluginSettings = [NSMutableDictionary dictionary];
    pluginSettings[@"com.salesforce.marketingcloud.app_id"] =
        @"6ff36654-9d38-4199-8bb0-94b950c2f180";
    pluginSettings[@"com.salesforce.marketingcloud.access_token"] = @"zbdvfgg9keuz6egz6rkfr5wc";
    pluginSettings[@"com.salesforce.marketingcloud.tenant_specific_endpoint"] =
        @"https://mcgrjfgk81ckrt0h4rwlnbhmbvf4.device.marketingcloudapis.com/";
    pluginSettings[@"com.salesforce.marketingcloud.analytics"] = @(YES);

    _plugin.commandDelegate = _commandDelegate;
    OCMStub([_commandDelegate settings]).andReturn(pluginSettings);
    [_plugin pluginInitialize];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the
    // class.
    [super tearDown];
}

- (void)testEnableLogging {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"enableLogging"];

    // WHEN
    [_plugin enableLogging:command];

    // THEN
    OCMVerify([_sfmcSDK setLoggerWithLogLevel:SFMCSdkLogLevelDebug logOutputter:[OCMArg any]]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testdisableLogging {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"disableLogging"];
    // WHEN
    [_plugin disableLogging:command];

    // THEN
    OCMVerify([_sfmcSDK setLoggerWithLogLevel:SFMCSdkLogLevelFault logOutputter:[OCMArg any]]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testLogSdkState {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"logSdkState"];

    // WHEN
    [_plugin logSdkState:command];

    // THEN
    OCMVerify([_sfmcSDK state]);
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
    OCMStub([_push deviceToken]).andReturn(@"testSystemToken");

    // WHEN
    [_plugin getSystemToken:command];

    // THEN
    OCMVerify([_push deviceToken]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK &&
                 [result.message isEqualToString:@"testSystemToken"];
        }]
              callbackId:@"testCallback"]);
}

- (void)testGetDeviceId {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"getDeviceId"];
    OCMStub([_push deviceIdentifier]).andReturn(@"testDeviceId");

    // WHEN
    [_plugin getDeviceId:command];

    // THEN
    OCMVerify([_push deviceIdentifier]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK &&
                 [result.message isEqualToString:@"testDeviceId"];
        }]
              callbackId:@"testCallback"]);
}

- (void)testIsPushEnabled_NO {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"isPushEnabled"];
    OCMStub([_push pushEnabled]).andReturn(NO);

    // WHEN
    [_plugin isPushEnabled:command];

    // THEN
    OCMVerify([_push pushEnabled]);
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
    OCMStub([_push pushEnabled]).andReturn(YES);

    // WHEN
    [_plugin isPushEnabled:command];

    // THEN
    OCMVerify([_push pushEnabled]);
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
    OCMVerify([_push setPushEnabled:YES]);
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
    OCMVerify([_push setPushEnabled:NO]);
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
                                                      methodName:@"setProfileAttributes"];
    OCMStub([_sfmcIdentity setProfileAttributes:[OCMArg any]]);

    // WHEN
    [_plugin setAttribute:command];

    // THEN
    OCMVerify([_sfmcIdentity setProfileAttributes:@{@"TestKey" : @"TestValue"}]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 1;
        }]
              callbackId:@"testCallback"]);
}

- (void)testClearAttribute_success {
    [SFMCSdk setLoggerWithLogLevel:SFMCSdkLogLevelDebug
                      logOutputter:[[SFMCSdkLogOutputter alloc] init]];
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"TestKey" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"clearAttribute"];

    OCMStub([_sfmcIdentity clearProfileAttributeWithKey:[OCMArg any]]);

    // WHEN
    [_plugin clearAttribute:command];

    // THEN
    OCMVerify([_sfmcIdentity clearProfileAttributeWithKey:@"TestKey"]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 1;
        }]
              callbackId:@"testCallback"]);
}

- (void)testGetAttributes {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"getAttributes"];
    OCMStub([(SFMCSdkPUSH *)_push attributes]).andReturn(@{@"TestKey" : @"TestVal"});

    // WHEN
    [_plugin getAttributes:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push attributes]);
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
    OCMStub([(SFMCSdkPUSH *)_push attributes]).andReturn(nil);

    // WHEN
    [_plugin getAttributes:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push attributes]);
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
    OCMStub([_push contactKey]).andReturn(@"testContactKey");

    // WHEN
    [_plugin getContactKey:command];

    // THEN
    OCMVerify([_push contactKey]);
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
    OCMStub([_sfmcIdentity setProfileId:[OCMArg any]]);

    // WHEN
    [_plugin setContactKey:command];

    // THEN
    OCMVerify([_sfmcIdentity setProfileId:@"testContactKey"]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK && [result.message intValue] == 1;
        }]
              callbackId:@"testCallback"]);
}

- (void)testAddTag_success {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ @"testTag" ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"addTag"];
    OCMStub([(SFMCSdkPUSH *)_push addTag:[OCMArg any]]).andReturn(YES);

    // WHEN
    [_plugin addTag:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push addTag:@"testTag"]);
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
    OCMStub([(SFMCSdkPUSH *)_push addTag:[OCMArg any]]).andReturn(NO);

    // WHEN
    [_plugin addTag:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push addTag:@"testTag"]);
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
    OCMStub([(SFMCSdkPUSH *)_push removeTag:[OCMArg any]]).andReturn(YES);

    // WHEN
    [_plugin removeTag:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push removeTag:@"testTag"]);
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
    OCMStub([(SFMCSdkPUSH *)_push removeTag:[OCMArg any]]).andReturn(NO);

    // WHEN
    [_plugin removeTag:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push removeTag:@"testTag"]);
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
    OCMStub([(SFMCSdkPUSH *)_push tags]).andReturn(tags);

    // WHEN
    [_plugin getTags:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push tags]);
    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          NSArray *resultTags = (NSArray *)result.message;
          return [result.status intValue] == CDVCommandStatus_OK && resultTags != nil &&
                 [[resultTags objectAtIndex:0] isEqualToString:@"Tag1"] &&
                 [[resultTags objectAtIndex:1] isEqualToString:@"Tag2"];
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackCustomEvent {
    // GIVEN
    NSDictionary *customEvent = @{
        @"category" : @"engagement",
        @"name" : @"Purchase",
        @"attributes" : @{@"attributeKey" : @"attributeValue"},
        @"objType" : @"CustomEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ customEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkCustomEvent class]], @"Not SFMCSdkCustomEvent");
          SFMCSdkCustomEvent *event = obj;

          XCTAssertTrue([@"Purchase" isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);
          XCTAssertTrue([customEvent[@"attributes"] isEqualToDictionary:event.attributes]);
          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackSystemEvent {
    // GIVEN
    NSDictionary *systemEvent = @{
        @"category" : @"system",
        @"name" : @"eventName",
        @"attributes" : @{@"attributeKey" : @"attributeValue"},
        @"objType" : @"SystemEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ systemEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                          NSLog(@"OCMVerify %@", obj);
                          XCTAssertTrue([obj isKindOfClass:[SFMCSdkSystemEvent class]]);
                          SFMCSdkSystemEvent *event = obj;

                          XCTAssertTrue([@"eventName" isEqualToString:event.name]);
                          XCTAssertEqual(SFMCSdkEventCategorySystem, [event category]);
                          XCTAssertTrue(
                              [systemEvent[@"attributes"] isEqualToDictionary:event.attributes]);
                          return YES;
                        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackIdentityEventWithAttributes {
    // GIVEN
    NSDictionary *identityEvent = @{
        @"category" : @"identity",
        @"name" : @"IdentityEvent",
        @"attributes" : @{@"attributeKey" : @"attributeValue"},
        @"objType" : @"IdentityEvent"
    };
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ identityEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                          NSLog(@"OCMVerify %@", obj);
                          XCTAssertTrue([obj isKindOfClass:[SFMCSdkIdentityEvent class]]);
                          SFMCSdkIdentityEvent *event = obj;
                          NSLog(@"SFMCSdkIdentityEvent %@", event.name);

                          XCTAssertTrue([@"IdentityEvent" isEqualToString:event.name]);
                          XCTAssertEqual(SFMCSdkEventCategoryIdentity, [event category]);
                          XCTAssertTrue(
                              [identityEvent[@"attributes"] isEqualToDictionary:event.attributes]);
                          return YES;
                        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackIdentityEventWithProfileId {
    // GIVEN
    NSDictionary *identityEvent = @{
        @"category" : @"identity",
        @"name" : @"IdentityEvent",
        @"profileId" : @"test@gmail.com",
        @"objType" : @"IdentityEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ identityEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                          NSLog(@"OCMVerify %@", obj);
                          XCTAssertTrue([obj isKindOfClass:[SFMCSdkIdentityEvent class]]);
                          SFMCSdkIdentityEvent *event = obj;

                          XCTAssertTrue([@"IdentityEvent" isEqualToString:event.name]);
                          XCTAssertEqual(SFMCSdkEventCategoryIdentity, [event category]);
                          XCTAssertTrue(
                              [identityEvent[@"profileId"] isEqualToString:event.profileId]);
                          return YES;
                        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackIdentityEventWithProfileAttributes {
    // GIVEN
    NSDictionary *identityEvent = @{
        @"category" : @"identity",
        @"name" : @"IdentityEvent",
        @"profileAttributes" : @{@"profileAttributeKey" : @"profileAttributeValue"},
        @"objType" : @"IdentityEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ identityEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                          NSLog(@"OCMVerify %@", obj);
                          XCTAssertTrue([obj isKindOfClass:[SFMCSdkIdentityEvent class]]);
                          SFMCSdkIdentityEvent *event = obj;

                          XCTAssertTrue([@"IdentityEvent" isEqualToString:event.name]);
                          XCTAssertEqual(SFMCSdkEventCategoryIdentity, [event category]);
                          XCTAssertTrue([identityEvent[@"profileAttributes"]
                              isEqualToDictionary:event.profileAttributes]);
                          return YES;
                        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackAddToCartEvent {
    // GIVEN
    NSDictionary *lineItem = @{
        @"catalogObjectType" : @"catalogObjectTypeValue",
        @"catalogObjectId" : @"catalogObjectIdValue",
        @"quantity" : @1,
        @"price" : @100,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"LineItem"
    };

    NSDictionary *cartEvent = @{
        @"category" : @"engagement",
        @"name" : @"Add To Cart",
        @"lineItems" : @[ lineItem ],
        @"objType" : @"CartEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ cartEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkAddToCartEvent class]]);
          SFMCSdkAddToCartEvent *event = obj;

          XCTAssertTrue([@"Add To Cart" isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkLineItem *item = [event.lineItems firstObject];
          XCTAssertTrue([lineItem[@"catalogObjectType"] isEqualToString:item.catalogObjectType]);
          XCTAssertTrue([lineItem[@"catalogObjectId"] isEqualToString:item.catalogObjectId]);
          XCTAssertEqual([lineItem[@"quantity"] integerValue], item.quantity);

          XCTAssertTrue([lineItem[@"price"] isEqualToNumber:item.price]);
          XCTAssertTrue([lineItem[@"currency"] isEqualToString:item.currency]);
          XCTAssertTrue([lineItem[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackRemoveFromCartEvent {
    // GIVEN
    NSDictionary *lineItem = @{
        @"catalogObjectType" : @"catalogObjectTypeValue",
        @"catalogObjectId" : @"catalogObjectIdValue",
        @"quantity" : @1,
        @"price" : @100,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"LineItem"
    };

    NSDictionary *cartEvent = @{
        @"category" : @"engagement",
        @"name" : @"Remove From Cart",
        @"lineItems" : @[ lineItem ],
        @"objType" : @"CartEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ cartEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkRemoveFromCartEvent class]]);
          SFMCSdkRemoveFromCartEvent *event = obj;

          XCTAssertTrue([@"Remove From Cart" isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkLineItem *item = [event.lineItems firstObject];
          XCTAssertTrue([lineItem[@"catalogObjectType"] isEqualToString:item.catalogObjectType]);
          XCTAssertTrue([lineItem[@"catalogObjectId"] isEqualToString:item.catalogObjectId]);
          XCTAssertEqual([lineItem[@"quantity"] integerValue], item.quantity);

          XCTAssertTrue([lineItem[@"price"] isEqualToNumber:item.price]);
          XCTAssertTrue([lineItem[@"currency"] isEqualToString:item.currency]);
          XCTAssertTrue([lineItem[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackReplaceCartEvent {
    // GIVEN
    NSDictionary *lineItem = @{
        @"catalogObjectType" : @"catalogObjectTypeValue",
        @"catalogObjectId" : @"catalogObjectIdValue",
        @"quantity" : @1,
        @"price" : @100,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"LineItem"
    };

    NSDictionary *cartEvent = @{
        @"category" : @"engagement",
        @"name" : @"Replace Cart",
        @"lineItems" : @[ lineItem, lineItem ],
        @"objType" : @"CartEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ cartEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkReplaceCartEvent class]]);
          SFMCSdkReplaceCartEvent *event = obj;

          XCTAssertTrue([@"Replace Cart" isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkLineItem *item = event.lineItems[0];
          XCTAssertTrue([lineItem[@"catalogObjectType"] isEqualToString:item.catalogObjectType]);
          XCTAssertTrue([lineItem[@"catalogObjectId"] isEqualToString:item.catalogObjectId]);
          XCTAssertEqual([lineItem[@"quantity"] integerValue], item.quantity);

          XCTAssertTrue([lineItem[@"price"] isEqualToNumber:item.price]);
          XCTAssertTrue([lineItem[@"currency"] isEqualToString:item.currency]);
          XCTAssertTrue([lineItem[@"attributes"] isEqualToDictionary:item.attributes]);

          item = event.lineItems[1];
          XCTAssertTrue([lineItem[@"catalogObjectType"] isEqualToString:item.catalogObjectType]);
          XCTAssertTrue([lineItem[@"catalogObjectId"] isEqualToString:item.catalogObjectId]);
          XCTAssertEqual([lineItem[@"quantity"] integerValue], item.quantity);

          XCTAssertTrue([lineItem[@"price"] isEqualToNumber:item.price]);
          XCTAssertTrue([lineItem[@"currency"] isEqualToString:item.currency]);
          XCTAssertTrue([lineItem[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackCommentCatalogObjectEvent {
    // GIVEN
    NSDictionary *catalogObject = @{
        @"type" : @"objectType",
        @"id" : @"objectId",
        @"attributes" : @{@"key" : @"value"},
        @"relatedCatalogObjects" : @{},
        @"objType" : @"CatalogObject"
    };

    NSDictionary *catalogObjectEvent = @{
        @"category" : @"engagement",
        @"name" : @"Comment Catalog Object",
        @"catalogObject" : catalogObject,
        @"objType" : @"CatalogObjectEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ catalogObjectEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];
    
    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkCommentCatalogObjectEvent class]]);
          SFMCSdkCommentCatalogObjectEvent *event = obj;

          XCTAssertTrue([catalogObjectEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkCatalogObject *item = event.catalogObject;
          XCTAssertTrue([catalogObject[@"type"] isEqualToString:item.type]);
          XCTAssertTrue([catalogObject[@"id"] isEqualToString:item.id]);
          XCTAssertTrue([catalogObject[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackViewCatalogObjectDetailEvent {
    // GIVEN
    NSDictionary *catalogObject = @{
        @"type" : @"objectType",
        @"id" : @"objectId",
        @"attributes" : @{@"key" : @"value"},
        @"relatedCatalogObjects" : @{},
        @"objType" : @"CatalogObject"
    };

    NSDictionary *catalogObjectEvent = @{
        @"category" : @"engagement",
        @"name" : @"View Catalog Object Detail",
        @"catalogObject" : catalogObject,
        @"objType" : @"CatalogObjectEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ catalogObjectEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkViewCatalogObjectDetailEvent class]]);
          SFMCSdkViewCatalogObjectDetailEvent *event = obj;

          XCTAssertTrue([catalogObjectEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkCatalogObject *item = event.catalogObject;
          XCTAssertTrue([catalogObject[@"type"] isEqualToString:item.type]);
          XCTAssertTrue([catalogObject[@"id"] isEqualToString:item.id]);
          XCTAssertTrue([catalogObject[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackFavoriteCatalogObjectDetailEvent {
    // GIVEN
    NSDictionary *catalogObject = @{
        @"type" : @"objectType",
        @"id" : @"objectId",
        @"attributes" : @{@"key" : @"value"},
        @"relatedCatalogObjects" : @{},
        @"objType" : @"CatalogObject"
    };

    NSDictionary *catalogObjectEvent = @{
        @"category" : @"engagement",
        @"name" : @"Favorite Catalog Object",
        @"catalogObject" : catalogObject,
        @"objType" : @"CatalogObjectEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ catalogObjectEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkFavoriteCatalogObjectEvent class]]);
          SFMCSdkFavoriteCatalogObjectEvent *event = obj;

          XCTAssertTrue([catalogObjectEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkCatalogObject *item = event.catalogObject;
          XCTAssertTrue([catalogObject[@"type"] isEqualToString:item.type]);
          XCTAssertTrue([catalogObject[@"id"] isEqualToString:item.id]);
          XCTAssertTrue([catalogObject[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackShareCatalogObjectDetailEvent {
    // GIVEN
    NSDictionary *catalogObject = @{
        @"type" : @"objectType",
        @"id" : @"objectId",
        @"attributes" : @{@"key" : @"value"},
        @"relatedCatalogObjects" : @{},
        @"objType" : @"CatalogObject"
    };

    NSDictionary *catalogObjectEvent = @{
        @"category" : @"engagement",
        @"name" : @"Share Catalog Object",
        @"catalogObject" : catalogObject,
        @"objType" : @"CatalogObjectEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ catalogObjectEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];
    
    // THEN
    OCMVerify([_sfmcSDK trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                          NSLog(@"OCMVerify %@", obj);
                          XCTAssertTrue([obj isKindOfClass:[SFMCSdkShareCatalogObjectEvent class]]);
                          SFMCSdkShareCatalogObjectEvent *event = obj;

                          XCTAssertTrue([catalogObjectEvent[@"name"] isEqualToString:event.name]);
                          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

                          SFMCSdkCatalogObject *item = event.catalogObject;
                          XCTAssertTrue([catalogObject[@"type"] isEqualToString:item.type]);
                          XCTAssertTrue([catalogObject[@"id"] isEqualToString:item.id]);
                          XCTAssertTrue(
                              [catalogObject[@"attributes"] isEqualToDictionary:item.attributes]);

                          return YES;
                        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackReviewCatalogObjectDetailEvent {
    // GIVEN
    NSDictionary *catalogObject = @{
        @"type" : @"objectType",
        @"id" : @"objectId",
        @"attributes" : @{@"key" : @"value"},
        @"relatedCatalogObjects" : @{},
        @"objType" : @"CatalogObject"
    };

    NSDictionary *catalogObjectEvent = @{
        @"category" : @"engagement",
        @"name" : @"Review Catalog Object",
        @"catalogObject" : catalogObject,
        @"objType" : @"CatalogObjectEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ catalogObjectEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkReviewCatalogObjectEvent class]]);
          SFMCSdkReviewCatalogObjectEvent *event = obj;

          XCTAssertTrue([catalogObjectEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkCatalogObject *item = event.catalogObject;
          XCTAssertTrue([catalogObject[@"type"] isEqualToString:item.type]);
          XCTAssertTrue([catalogObject[@"id"] isEqualToString:item.id]);
          XCTAssertTrue([catalogObject[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackViewCatalogObjectEvent {
    // GIVEN
    NSDictionary *catalogObject = @{
        @"type" : @"objectType",
        @"id" : @"objectId",
        @"attributes" : @{@"key" : @"value"},
        @"relatedCatalogObjects" : @{},
        @"objType" : @"CatalogObject"
    };

    NSDictionary *catalogObjectEvent = @{
        @"category" : @"engagement",
        @"name" : @"View Catalog Object",
        @"catalogObject" : catalogObject,
        @"objType" : @"CatalogObjectEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ catalogObjectEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
                          NSLog(@"OCMVerify %@", obj);
                          XCTAssertTrue([obj isKindOfClass:[SFMCSdkViewCatalogObjectEvent class]]);
                          SFMCSdkViewCatalogObjectEvent *event = obj;
                          NSLog(@"OCMVerify--> %@ %@", event.name, catalogObject[@"name"]);

                          XCTAssertTrue([catalogObjectEvent[@"name"] isEqualToString:event.name]);
                          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

                          SFMCSdkCatalogObject *item = event.catalogObject;
                          XCTAssertTrue([catalogObject[@"type"] isEqualToString:item.type]);
                          XCTAssertTrue([catalogObject[@"id"] isEqualToString:item.id]);
                          XCTAssertTrue(
                              [catalogObject[@"attributes"] isEqualToDictionary:item.attributes]);

                          return YES;
                        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackQuickViewCatalogObjectDetailEvent {
    // GIVEN
    NSDictionary *catalogObject = @{
        @"type" : @"objectType",
        @"id" : @"objectId",
        @"attributes" : @{@"key" : @"value"},
        @"relatedCatalogObjects" : @{},
        @"objType" : @"CatalogObject"
    };

    NSDictionary *catalogObjectEvent = @{
        @"category" : @"engagement",
        @"name" : @"Quick View Catalog Object",
        @"catalogObject" : catalogObject,
        @"objType" : @"CatalogObjectEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ catalogObjectEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkQuickViewCatalogObjectEvent class]]);
          SFMCSdkQuickViewCatalogObjectEvent *event = obj;

          XCTAssertTrue([catalogObjectEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkCatalogObject *item = event.catalogObject;
          XCTAssertTrue([catalogObject[@"type"] isEqualToString:item.type]);
          XCTAssertTrue([catalogObject[@"id"] isEqualToString:item.id]);
          XCTAssertTrue([catalogObject[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackPurchaseOrderEvent {
    // GIVEN
    NSDictionary *lineItem = @{
        @"catalogObjectType" : @"catalogObjectTypeValue",
        @"catalogObjectId" : @"catalogObjectIdValue",
        @"quantity" : @1,
        @"price" : @100,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"LineItem"
    };

    NSDictionary *order = @{
        @"id" : @"orderId",
        @"lineItems" : @[ lineItem ],
        @"totalValue" : @500,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"Order"
    };

    NSDictionary *orderEvent = @{
        @"category" : @"engagement",
        @"name" : @"Purchase",
        @"order" : order,
        @"objType" : @"OrderEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ orderEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkPurchaseOrderEvent class]]);
          SFMCSdkPurchaseOrderEvent *event = obj;

          XCTAssertTrue([orderEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkOrder *eventOrder = event.order;
          XCTAssertTrue([order[@"id"] isEqualToString:eventOrder.id]);
          XCTAssertTrue([order[@"totalValue"] isEqualToNumber:eventOrder.totalValue]);
          XCTAssertTrue([order[@"currency"] isEqualToString:eventOrder.currency]);
          XCTAssertTrue([order[@"attributes"] isEqualToDictionary:eventOrder.attributes]);

          SFMCSdkLineItem *item = event.order.lineItems[0];
          XCTAssertTrue([lineItem[@"catalogObjectType"] isEqualToString:item.catalogObjectType]);
          XCTAssertTrue([lineItem[@"catalogObjectId"] isEqualToString:item.catalogObjectId]);
          XCTAssertEqual([lineItem[@"quantity"] integerValue], item.quantity);

          XCTAssertTrue([lineItem[@"price"] isEqualToNumber:item.price]);
          XCTAssertTrue([lineItem[@"currency"] isEqualToString:item.currency]);
          XCTAssertTrue([lineItem[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackPreorderOrderEvent {
    // GIVEN
    NSDictionary *lineItem = @{
        @"catalogObjectType" : @"catalogObjectTypeValue",
        @"catalogObjectId" : @"catalogObjectIdValue",
        @"quantity" : @1,
        @"price" : @100,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"LineItem"
    };

    NSDictionary *order = @{
        @"id" : @"orderId",
        @"lineItems" : @[ lineItem ],
        @"totalValue" : @500,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"Order"
    };

    NSDictionary *orderEvent = @{
        @"category" : @"engagement",
        @"name" : @"Preorder",
        @"order" : order,
        @"objType" : @"OrderEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ orderEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkPreorderEvent class]]);
          SFMCSdkPreorderEvent *event = obj;

          XCTAssertTrue([orderEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkOrder *eventOrder = event.order;
          XCTAssertTrue([order[@"id"] isEqualToString:eventOrder.id]);
          XCTAssertTrue([order[@"totalValue"] isEqualToNumber:eventOrder.totalValue]);
          XCTAssertTrue([order[@"currency"] isEqualToString:eventOrder.currency]);
          XCTAssertTrue([order[@"attributes"] isEqualToDictionary:eventOrder.attributes]);

          SFMCSdkLineItem *item = event.order.lineItems[0];
          XCTAssertTrue([lineItem[@"catalogObjectType"] isEqualToString:item.catalogObjectType]);
          XCTAssertTrue([lineItem[@"catalogObjectId"] isEqualToString:item.catalogObjectId]);
          XCTAssertEqual([lineItem[@"quantity"] integerValue], item.quantity);

          XCTAssertTrue([lineItem[@"price"] isEqualToNumber:item.price]);
          XCTAssertTrue([lineItem[@"currency"] isEqualToString:item.currency]);
          XCTAssertTrue([lineItem[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackCancelOrderEvent {
    // GIVEN
    NSDictionary *lineItem = @{
        @"catalogObjectType" : @"catalogObjectTypeValue",
        @"catalogObjectId" : @"catalogObjectIdValue",
        @"quantity" : @1,
        @"price" : @100,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"LineItem"
    };

    NSDictionary *order = @{
        @"id" : @"orderId",
        @"lineItems" : @[ lineItem ],
        @"totalValue" : @500,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"Order"
    };

    NSDictionary *orderEvent = @{
        @"category" : @"engagement",
        @"name" : @"Cancel",
        @"order" : order,
        @"objType" : @"OrderEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ orderEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkCancelOrderEvent class]]);
          SFMCSdkCancelOrderEvent *event = obj;

          XCTAssertTrue([orderEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkOrder *eventOrder = event.order;
          XCTAssertTrue([order[@"id"] isEqualToString:eventOrder.id]);
          XCTAssertTrue([order[@"totalValue"] isEqualToNumber:eventOrder.totalValue]);
          XCTAssertTrue([order[@"currency"] isEqualToString:eventOrder.currency]);
          XCTAssertTrue([order[@"attributes"] isEqualToDictionary:eventOrder.attributes]);

          SFMCSdkLineItem *item = event.order.lineItems[0];
          XCTAssertTrue([lineItem[@"catalogObjectType"] isEqualToString:item.catalogObjectType]);
          XCTAssertTrue([lineItem[@"catalogObjectId"] isEqualToString:item.catalogObjectId]);
          XCTAssertEqual([lineItem[@"quantity"] integerValue], item.quantity);

          XCTAssertTrue([lineItem[@"price"] isEqualToNumber:item.price]);
          XCTAssertTrue([lineItem[@"currency"] isEqualToString:item.currency]);
          XCTAssertTrue([lineItem[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackDeliverOrderEvent {
    // GIVEN
    NSDictionary *lineItem = @{
        @"catalogObjectType" : @"catalogObjectTypeValue",
        @"catalogObjectId" : @"catalogObjectIdValue",
        @"quantity" : @1,
        @"price" : @100,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"LineItem"
    };

    NSDictionary *order = @{
        @"id" : @"orderId",
        @"lineItems" : @[ lineItem ],
        @"totalValue" : @500,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"Order"
    };

    NSDictionary *orderEvent = @{
        @"category" : @"engagement",
        @"name" : @"Deliver",
        @"order" : order,
        @"objType" : @"OrderEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ orderEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkDeliverOrderEvent class]]);
          SFMCSdkDeliverOrderEvent *event = obj;

          XCTAssertTrue([orderEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkOrder *eventOrder = event.order;
          XCTAssertTrue([order[@"id"] isEqualToString:eventOrder.id]);
          XCTAssertTrue([order[@"totalValue"] isEqualToNumber:eventOrder.totalValue]);
          XCTAssertTrue([order[@"currency"] isEqualToString:eventOrder.currency]);
          XCTAssertTrue([order[@"attributes"] isEqualToDictionary:eventOrder.attributes]);

          SFMCSdkLineItem *item = event.order.lineItems[0];
          XCTAssertTrue([lineItem[@"catalogObjectType"] isEqualToString:item.catalogObjectType]);
          XCTAssertTrue([lineItem[@"catalogObjectId"] isEqualToString:item.catalogObjectId]);
          XCTAssertEqual([lineItem[@"quantity"] integerValue], item.quantity);

          XCTAssertTrue([lineItem[@"price"] isEqualToNumber:item.price]);
          XCTAssertTrue([lineItem[@"currency"] isEqualToString:item.currency]);
          XCTAssertTrue([lineItem[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackExchangeOrderEvent {
    // GIVEN
    NSDictionary *lineItem = @{
        @"catalogObjectType" : @"catalogObjectTypeValue",
        @"catalogObjectId" : @"catalogObjectIdValue",
        @"quantity" : @1,
        @"price" : @100,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"LineItem"
    };

    NSDictionary *order = @{
        @"id" : @"orderId",
        @"lineItems" : @[ lineItem ],
        @"totalValue" : @500,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"Order"
    };

    NSDictionary *orderEvent = @{
        @"category" : @"engagement",
        @"name" : @"Exchange",
        @"order" : order,
        @"objType" : @"OrderEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ orderEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkExchangeOrderEvent class]]);
          SFMCSdkExchangeOrderEvent *event = obj;

          XCTAssertTrue([orderEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkOrder *eventOrder = event.order;
          XCTAssertTrue([order[@"id"] isEqualToString:eventOrder.id]);
          XCTAssertTrue([order[@"totalValue"] isEqualToNumber:eventOrder.totalValue]);
          XCTAssertTrue([order[@"currency"] isEqualToString:eventOrder.currency]);
          XCTAssertTrue([order[@"attributes"] isEqualToDictionary:eventOrder.attributes]);

          SFMCSdkLineItem *item = event.order.lineItems[0];
          XCTAssertTrue([lineItem[@"catalogObjectType"] isEqualToString:item.catalogObjectType]);
          XCTAssertTrue([lineItem[@"catalogObjectId"] isEqualToString:item.catalogObjectId]);
          XCTAssertEqual([lineItem[@"quantity"] integerValue], item.quantity);

          XCTAssertTrue([lineItem[@"price"] isEqualToNumber:item.price]);
          XCTAssertTrue([lineItem[@"currency"] isEqualToString:item.currency]);
          XCTAssertTrue([lineItem[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackReturnOrderEvent {
    // GIVEN
    NSDictionary *lineItem = @{
        @"catalogObjectType" : @"catalogObjectTypeValue",
        @"catalogObjectId" : @"catalogObjectIdValue",
        @"quantity" : @1,
        @"price" : @100,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"LineItem"
    };

    NSDictionary *order = @{
        @"id" : @"orderId",
        @"lineItems" : @[ lineItem ],
        @"totalValue" : @500,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"Order"
    };

    NSDictionary *orderEvent = @{
        @"category" : @"engagement",
        @"name" : @"Return",
        @"order" : order,
        @"objType" : @"OrderEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ orderEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK
        trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkReturnOrderEvent class]]);
          SFMCSdkReturnOrderEvent *event = obj;

          XCTAssertTrue([orderEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkOrder *eventOrder = event.order;
          XCTAssertTrue([order[@"id"] isEqualToString:eventOrder.id]);
          XCTAssertTrue([order[@"totalValue"] isEqualToNumber:eventOrder.totalValue]);
          XCTAssertTrue([order[@"currency"] isEqualToString:eventOrder.currency]);
          XCTAssertTrue([order[@"attributes"] isEqualToDictionary:eventOrder.attributes]);

          SFMCSdkLineItem *item = event.order.lineItems[0];
          XCTAssertTrue([lineItem[@"catalogObjectType"] isEqualToString:item.catalogObjectType]);
          XCTAssertTrue([lineItem[@"catalogObjectId"] isEqualToString:item.catalogObjectId]);
          XCTAssertEqual([lineItem[@"quantity"] integerValue], item.quantity);

          XCTAssertTrue([lineItem[@"price"] isEqualToNumber:item.price]);
          XCTAssertTrue([lineItem[@"currency"] isEqualToString:item.currency]);
          XCTAssertTrue([lineItem[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testTrackReturnShipEvent {
    // GIVEN
    NSDictionary *lineItem = @{
        @"catalogObjectType" : @"catalogObjectTypeValue",
        @"catalogObjectId" : @"catalogObjectIdValue",
        @"quantity" : @1,
        @"price" : @100,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"LineItem"
    };

    NSDictionary *order = @{
        @"id" : @"orderId",
        @"lineItems" : @[ lineItem ],
        @"totalValue" : @500,
        @"currency" : @"USD",
        @"attributes" : @{@"key" : @"value"},
        @"objType" : @"Order"
    };

    NSDictionary *orderEvent = @{
        @"category" : @"engagement",
        @"name" : @"Ship",
        @"order" : order,
        @"objType" : @"OrderEvent"
    };

    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[ orderEvent ]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"trackEvent"];

    // WHEN
    [_plugin track:command];

    // THEN
    OCMVerify([_sfmcSDK trackWithEvent:[OCMArg checkWithBlock:^BOOL(id obj) {
          NSLog(@"OCMVerify %@", obj);
          XCTAssertTrue([obj isKindOfClass:[SFMCSdkShipOrderEvent class]]);
          SFMCSdkShipOrderEvent *event = obj;

          XCTAssertTrue([orderEvent[@"name"] isEqualToString:event.name]);
          XCTAssertEqual(SFMCSdkEventCategoryEngagement, [event category]);

          SFMCSdkOrder *eventOrder = event.order;
          XCTAssertTrue([order[@"id"] isEqualToString:eventOrder.id]);
          XCTAssertTrue([order[@"totalValue"] isEqualToNumber:eventOrder.totalValue]);
          XCTAssertTrue([order[@"currency"] isEqualToString:eventOrder.currency]);
          XCTAssertTrue([order[@"attributes"] isEqualToDictionary:eventOrder.attributes]);

          SFMCSdkLineItem *item = event.order.lineItems[0];
          XCTAssertTrue([lineItem[@"catalogObjectType"] isEqualToString:item.catalogObjectType]);
          XCTAssertTrue([lineItem[@"catalogObjectId"] isEqualToString:item.catalogObjectId]);
          XCTAssertEqual([lineItem[@"quantity"] integerValue], item.quantity);
          XCTAssertTrue([lineItem[@"price"] isEqualToNumber:item.price]);
          XCTAssertTrue([lineItem[@"currency"] isEqualToString:item.currency]);
          XCTAssertTrue([lineItem[@"attributes"] isEqualToDictionary:item.attributes]);

          return YES;
        }]]);

    OCMVerify([_commandDelegate
        sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
          return [result.status intValue] == CDVCommandStatus_OK;
        }]
              callbackId:@"testCallback"]);
}

- (void)testGetTags_nil {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"getTags"];
    OCMStub([(SFMCSdkPUSH *)_push tags]).andReturn(nil);

    // WHEN
    [_plugin getTags:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push tags]);
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
    [_plugin registerEventsChannel:[Tests eventCallbackCommand]];

    // WHEN
    [_plugin subscribe:[Tests notificationOpenedSubscribeCommand]];

    // THEN
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg any] callbackId:@"eventCallback"]);
}

- (void)
    testNotificationReceived_afterEventCallbackCalled_beforeSubscribeCalled_shouldBeDeliveredWhenSubscribed {
    // GIVEN
    [_plugin registerEventsChannel:[Tests eventCallbackCommand]];
    [self sendTestNotification:@{@"aps" : @{}}];

    // WHEN
    [_plugin subscribe:[Tests notificationOpenedSubscribeCommand]];

    // THEN
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg any] callbackId:@"eventCallback"]);
}

- (void)
    testNotificationReceived_afterEventCallbackCalled_afterSubscribeCalled_shouldBeDeliveredImmediately {
    // GIVEN
    [_plugin registerEventsChannel:[Tests eventCallbackCommand]];
    [_plugin subscribe:[Tests notificationOpenedSubscribeCommand]];

    // WHEN
    [self sendTestNotification:@{@"aps" : @{}}];

    // THEN
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg any] callbackId:@"eventCallback"]);
}

- (void)testNotificationReceived_OD_withAlertTitleSubTitle {
    // GIVEN
    [_plugin registerEventsChannel:[Tests eventCallbackCommand]];
    [_plugin subscribe:[Tests notificationOpenedSubscribeCommand]];

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
    [_plugin registerEventsChannel:[Tests eventCallbackCommand]];
    [_plugin subscribe:[Tests notificationOpenedSubscribeCommand]];

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
    [_plugin registerEventsChannel:[Tests eventCallbackCommand]];
    [_plugin subscribe:[Tests notificationOpenedSubscribeCommand]];

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
    [_plugin registerEventsChannel:[Tests eventCallbackCommand]];
    [_plugin subscribe:[Tests notificationOpenedSubscribeCommand]];

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

- (void)testSetAnalyticsEnabledAsYes {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[@(YES)]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"setAnalyticsEnabled"];

    // WHEN
    [_plugin setAnalyticsEnabled:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push setAnalyticsEnabled:YES]);
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
        return [result.status intValue] == CDVCommandStatus_OK;
    }] callbackId:@"testCallback"]);
}

- (void)testSetAnalyticsEnabledAsNo {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[@(NO)]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"setAnalyticsEnabled"];

    // WHEN
    [_plugin setAnalyticsEnabled:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push setAnalyticsEnabled:NO]);
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
        return [result.status intValue] == CDVCommandStatus_OK;
    }] callbackId:@"testCallback"]);
}

- (void)testIsAnalyticsEnabledAsYes {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"isAnalyticsEnabled"];
    OCMStub([_push isAnalyticsEnabled]).andReturn(YES);

    // WHEN
    [_plugin isAnalyticsEnabled:command];

    // THEN
    OCMVerify([_push isAnalyticsEnabled]);
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
        return [result.status intValue] == CDVCommandStatus_OK &&
               [result.message boolValue] == YES;
    }] callbackId:@"testCallback"]);
}

- (void)testIsAnalyticsEnabledAsNo {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"isAnalyticsEnabled"];
    OCMStub([_push isAnalyticsEnabled]).andReturn(NO);

    // WHEN
    [_plugin isAnalyticsEnabled:command];

    // THEN
    OCMVerify([_push isAnalyticsEnabled]);
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
        return [result.status intValue] == CDVCommandStatus_OK &&
               [result.message boolValue] == NO;
    }] callbackId:@"testCallback"]);
}

- (void)testSetPiAnalyticsEnabledAsYes {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[@(YES)]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"setPiAnalyticsEnabled"];

    // WHEN
    [_plugin setPiAnalyticsEnabled:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push setPiAnalyticsEnabled:YES]);
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
        return [result.status intValue] == CDVCommandStatus_OK;
    }] callbackId:@"testCallback"]);
}

- (void)testSetPiAnalyticsEnabledAsNo {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[@(NO)]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"setPiAnalyticsEnabled"];

    // WHEN
    [_plugin setPiAnalyticsEnabled:command];

    // THEN
    OCMVerify([(SFMCSdkPUSH *)_push setPiAnalyticsEnabled:NO]);
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
        return [result.status intValue] == CDVCommandStatus_OK;
    }] callbackId:@"testCallback"]);
}

- (void)testIsPiAnalyticsEnabledAsNo {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"isPiAnalyticsEnabled"];
    OCMStub([_push isPiAnalyticsEnabled]).andReturn(NO);

    // WHEN
    [_plugin isPiAnalyticsEnabled:command];

    // THEN
    OCMVerify([_push isPiAnalyticsEnabled]);
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
        return [result.status intValue] == CDVCommandStatus_OK &&
               [result.message boolValue] == NO;
    }] callbackId:@"testCallback"]);
}

- (void)testIsPiAnalyticsEnabledAsYes {
    // GIVEN
    id command = [[CDVInvokedUrlCommand alloc] initWithArguments:@[]
                                                      callbackId:@"testCallback"
                                                       className:@"MCCordovaPlugin"
                                                      methodName:@"isPiAnalyticsEnabled"];
    OCMStub([_push isPiAnalyticsEnabled]).andReturn(YES);

    // WHEN
    [_plugin isPiAnalyticsEnabled:command];

    // THEN
    OCMVerify([_push isPiAnalyticsEnabled]);
    OCMVerify([_commandDelegate sendPluginResult:[OCMArg checkWithBlock:^BOOL(CDVPluginResult *result) {
        return [result.status intValue] == CDVCommandStatus_OK &&
               [result.message boolValue] == YES;
    }] callbackId:@"testCallback"]);
}

@end
