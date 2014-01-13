//
//  UMSNSService.h
//  SNS
//
//  Created by liu yu on 9/15/11.
//  Copyright 2011 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol UMSNSOauthDelegate;
@protocol UMSNSDataSendDelegate;
@protocol UMSNSViewDisplayDelegate;
@protocol UMSNSShowActionSheetDelegate;

/*
 All the possible returned result after share to the sns platform
 */

typedef enum {
    UMReturnStatusTypeUpdated = 0,			//success update a new status or send a prvate message
    UMReturnStatusTypeRepeated,				//repeated send, when the current status content is the same to the last one in certain time
    UMReturnStatusTypeFileToLarge,			//image file to be shared is too large, just check the file size, and the uplimit is 2M
    UMReturnStatusTypeExtendSendLimit,		//sending time extend the allowed limit per hour
	UMReturnStatusTypeAccessTokenInvalid,	//accesstoken invalid from oauth 2.0
    UMReturnStatusTypeUnknownError			//sending failed for network problem, platform error or others
} UMReturnStatusType;

/*
 All the supported platform currently
 */

typedef enum {
    UMShareToTypeSina = 0,              //sina weibo
    UMShareToTypeTenc,                  //tencent weibo
    UMShareToTypeRenr,                  //renren
    UMShareToTypeCount                  //count the number of sns,now is 3
} UMShareToType;

/** 
 
 UMSNSService SDK 
 
 */

@interface UMSNSService : NSObject

/**  
 This method set the dalegate for oauth progress, if set, related method defined in protocol UMSNSOauthDelegate will be called 
 when oauth finished successfully or failed, else just return from the oauth view.
 
 @param delegate entity An object that conforms to the UMSNSOauthDelegate protocol
 */
+ (void) setOauthDelegate:(id<UMSNSOauthDelegate>)delegate;

/**  
 This method set the dalegate for data send progress, if set, related method defined in protocol UMSNSDataSendDelegate 
 will be called when data send finished, else nothing happened
 
 @param delegate entity An object that conforms to the UMSNSDataSendDelegate protocol
 */
+ (void) setDataSendDelegate:(id<UMSNSDataSendDelegate>)delegate;

/** 
 This method set the delegate for view display of the default share edit page
 
 @param delegate entity An object that conforms to the UMSNSViewDisplayDelegate protocol
 */
+ (void) setViewDisplayDelegate:(id<UMSNSViewDisplayDelegate>)delegate;


/**  
 This method set the delegate for the actionSheet
 
 @param delegate entity An object that conforms to the UMSNSShowActionSheetDelegate protocol
 */
+ (void) setUMSNSActionSheetDelegate:(id<UMSNSShowActionSheetDelegate>)delegate;

#pragma mark -
#pragma mark - show UIActionSheet

/**  
 This method share image and message to sns platforms we support now
 
 @param  controller Show SNSActionSheet in the viewController
 @param  appkey     Appkey get from www.umeng.com
 @param  status     Status will be shared
 @param  image      Image will be shared, you can pass nil when don't use image
 */
+(void) showSNSActionSheetInController:(UIViewController *)controller
                                appkey:(NSString *)appkey
                                status:(NSString *)status
                                 image:(UIImage *)image;
    
/**  
 This method share image and message to sns platforms we support now
 
 @param  controller       Show SNSActionSheet in the viewController
 @param  appkey           Appkey get from www.umeng.com
 @param  contentTemplate  The dictionary used to fill the content template in www.umeng.com
 @param  image            Image will be shared, you can pass nil when don't use image
 */
+(void) showSNSActionSheetInController:(UIViewController *)controller
                                appkey:(NSString *)appkey
                       contentTemplate:(NSDictionary *)contentTmplate
                                 image:(UIImage *)image;
    

#pragma mark - present UIViewController

/**  
 This method share image and message to sns platforms we support now
 
 @param  controller Present in the viewController
 @param  appkey     Appkey get from www.umeng.com
 @param  status     Status will be shared
 @param  image      Image will be shared, you can pass nil when don't use image
 @param  platform   To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 */
+(void) presentSNSInController:(UIViewController *)controller
                        appkey:(NSString *)appkey
                        status:(NSString *)status
                         image:(UIImage *)image
                      platform:(UMShareToType)platform;


/** 
 This method share image and message to sns platforms we support now
 content of the message get according to the share template set on www.umeng.com and shareMap
 
 @param  controller         Present in the viewController
 @param  appkey             Appkey get from www.umeng.com
 @param  contentTemplate    The dictionary used to fill the content template in www.umeng.com
 @param  image              Image will be shared, you can pass nil when don't use image
 @param  platform           To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 */
+ (void) presentSNSInController:(UIViewController *)controller
                         appkey:(NSString *)appkey
                contentTemplate:(NSDictionary *)contentTemplate
                          image:(UIImage *)image
                       platform:(UMShareToType)platform;

#pragma mark -
#pragma mark - Data Interface

/**  
 This method guide user to do oauth for sns platforms we support now 
 
 @param  controller  Present in the viewController
 @param  appkey      Appkey get from www.umeng.com
 @param  platform    To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 */
+ (void) oauthInController:(UIViewController *)viewController
                    appkey:(NSString *)appkey
                  platform:(UMShareToType)platform;


/** 
 This method share a image and a string object as the description to sns platform directly, Return a UMReturnStatusType variable
 
 @param  appkey     Appkey get from www.umeng.com
 @param  status     Status will be shared
 @param  image      Image will be shared, you can pass nil if no image 
 @param  uid        Uid in the platform that you want to share 
 @param  platform   To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 @param  error      If error occured, you can print it, and get the error information
 
 @return UMReturnStatusType
 */
+ (UMReturnStatusType) updateStatusWithAppkey:(NSString *)appkey
                                       status:(NSString *)status
                                        image:(UIImage *)image
                                          uid:(NSString *)uid
                                     platform:(UMShareToType)platform
                                  error:(NSError *)error;

/** 
 This method share a image and a string object as the description to sns platform we support currently
 the string content is filled according to the share template set at umeng.com and the shareMap object, Return a UMReturnStatusType variable
 
 @param  appkey           Appkey get from www.umeng.com
 @param  contentTemplate  The dictionary used to fill the content template in www.umeng.com
 @param  image            Image will be shared, you can pass nil if no image 
 @param  uid              Uid in the platform that you want to share
 @param  platform         To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 @param  error            If error occured, you can print it, and get the error information
 
 @return UMReturnStatusType
 */
+ (UMReturnStatusType) updateStatusWithAppkey:(NSString *)appkey
                              contentTemplate:(NSDictionary *)contentTemplate
                                        image:(UIImage *)image
                                          uid:(NSString *)uid
                                     platform:(UMShareToType)platform
                                        error:(NSError *)error;


#pragma mark -
#pragma mark - Other Utils Interface
/**  
 This method return the hot topics of the sns platform currently, Return a NSString array variable, autorelease
 
 @param  platform     To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 @param  appkey       Appkey get from www.umeng.com
 @param  uid          Uid in the platform that you want to share,you can get it use getUid method
 @param  error        If error occured, you can print it, and get the error information
 
 @return A NSString array, nil when error occured
 */
+ (NSArray *)  getTopicListWithPlatform:(UMShareToType)platform
                         appkey:(NSString *)appkey
                            uid:(NSString *)uid
                          error:(NSError *)error;

/** 
 This method return the share template set at www.umeng.com for the selected platform, Return a NSString variable, autorelease
 
 @param  appkey       Appkey get from www.umeng.com
 @param  platform     To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 @param  error        If error occured, you can print it, and get the error information
 
 @return template set on www.umeng.com, can set different template for different platform, nil when error occured
 */
+ (NSString *) getContentTemplateWithAppkey:(NSString *)appkey
                                   platform:(UMShareToType)platform
                                      error:(NSError *)error;

/** 
 This method return the uid for the current user for the selected platform, Return a NSString variable, autorelease
 
 @param  appkey        Appkey get from www.umeng.com
 @param  platform      To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTen
 @param  error         If error occured, you can print it, and get the error information
 
 @return mark for a oauthed user, nil when error occured
 */
+ (NSString *) getUidWithAppkey:(NSString *)appkey
                       platform:(UMShareToType)platform
                          error:(NSError *)error;


/**  
 This method return the nickname for the current user for the selected platform, Return a NSString variable, autorelease
 
 @param  appkey        Appkey get from www.umeng.com
 @param  uid           Uid in the platform that you want to share,you can get it use getUid method
 @param  platform      To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 @param  error         If error occured, you can print it, and get the error information
 
 @return nickname related to the current binded account, nil when error occured
 */
+ (NSString *) getNicknameWithAppkey:(NSString *)appkey
                                 uid:(NSString *)uid
                            platform:(UMShareToType)platform
                               error:(NSError *)error;

/** 
 This method send private message for a list of users for the selected platform, Return a NSString variable, autorelease
 
 @param  appkey        Appkey get from www.umeng.com
 @param  uid           Uid in the platform that you want to share,you can get it use getUid method
 @param  invitedUid    Uid of user to be invited
 @param  inviteContent Invitation content
 @param  platform      To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 @param  error         If error occured, you can print it, and get the error information
 
 @return UMReturnStatusType define above
 */
+ (UMReturnStatusType) sendInvitationWithAppkey:(NSString *)appkey
                                    uid:(NSString *)uid
                             invitedUid:(NSString *)invitedUid
                          inviteContent:(NSString *)inviteContent
                               platform:(UMShareToType)platform
                                  error:(NSError *)error;


/**  
 This method return access token for the uid for the selected platform, Return a NSDictionary object, autorelease
 
 @param  userPlatform platform releated to the uid
 
 @return return access token for the current user, return nil if the has not oauthed for the userPlatform
 */
+ (NSDictionary *) getAccessToken:(UMShareToType)platform;


/** 
 This method write-off account for the selected platform
 
 @param  userPlatform releated account for the platform will write-off, if no account bind to the platform, nothing happend 
 */
+ (void) writeOffAccounts:(UMShareToType)platform;


/** 
 
 This method get the uid for the platform, which cache in local
 
 @param  userPlatform releated to the uid
 */
+ (NSString *) getLocalUid:(UMShareToType)platform;


/**  
 This method return current SDK version
 
 @return SDK version
 */
+ (NSString *) currentSDKVersion;

#pragma mark - friendship releated
/** 
 This method return the friends list for the uid for the selected platform
 the keys of the returned dictionary is the friend ids, while the value the nicknames, Return a NSDictionary object, autorelease
 
 @param  appkey        Appkey get from www.umeng.com
 @param  platform      To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 @param  uid           Uid in the platform that you want to share,you can get it use getUid method
 @param  error         If error occured, you can print it, and get the error information
 
 @return a NSDictionary object, nil when error occured
 */
+ (NSDictionary *) getFriendsListWithAppkey:(NSString *)appkey
                                   platform:(UMShareToType)platform
                                        uid:(NSString *)uid
                                      error:(NSError *)error;


/**  
 This method get friendship between two users
 
 @param  appkey        Appkey get from www.umeng.com
 @param  platform      To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 @param  uid           Uid in the platform that you want to share,you can get it use getUid method
 @param  anotherUid    Uid for another user
 @param  error         If error occured, you can print it, and get the error information
 
 @return result, nil when error occured
 */
+ (NSString *) getFriendshipWithAppkey:(NSString *)appkey
                              platform:(UMShareToType)platform
                                   uid:(NSString *)uid
                            anotherUid:(NSString *)anotherUid
                                 error:(NSError *)error;

/**  
 This method create friendship between two users
 
 @param  appkey        Appkey get from www.umeng.com
 @param  platform      To share platform. UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 @param  uid           Uid in the platform that you want to share,you can get it use getUid method
 @param  anotherUid    Uid for another user
 @param  error         If error occured, you can print it, and get the error information
 
 @return result, nil when error occured
 */
+ (NSString *) createFriendshipWithAppkey:(NSString *)appkey
                                 platform:(UMShareToType)platform
                                      uid:(NSString *)uid
                               anotherUid:(NSString *)anotherUid
                                    error:(NSError *)error;


@end

#pragma mark -
#pragma mark - Protocol definition

/** 
 this protocol provide switches for some functions on the default share edit page
 */

@protocol UMSNSViewDisplayDelegate <NSObject> 

@optional

/** 
 This method return a bool result to indicate whether show insert topic button on the bottom of the main page 
 
 @param platfrom all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 @return result, True to enable insert topic, no to disable, default is true
 */
- (BOOL)insertTopicEnabled:(UMShareToType)platfrom;


/** 
 This method return a bool result to indicate whether show @ somebody button on the bottom of the main page 
 
 @param platfrom all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 @return result, True to enable @ somebody, no to disable, default is true 
 */
- (BOOL)atSomebodyEnabled:(UMShareToType)platfrom;


/** 
 This method return a bool result to indicate whether show insert emotion button on the bottom of the main page 
 
 @param platfrom all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 @return result, True to enable insert emotion, no to disable, default is true
 */
- (BOOL)insertEmotionEnabled:(UMShareToType)platfrom;


/** 
 This method return a bool result to indicate whether show private message button on the bottom of the main page 
 
 @param platfrom all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 @return result, True to enable private message, no to disable, default is true
 */
- (BOOL)priviteMessageEnabled:(UMShareToType)platfrom;


/**  
 This method return a bool result to indicate the text count check on or off, default is on, that is text count will be checked before sending, if the text count exceeds the limit(140), send will be canceled, currently no special check for url
 
 @param platfrom all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 @return result, True to enable text count check, no to disable, default is true
 */
- (BOOL)textCountCheckEnabled:(UMShareToType)platfrom;

/**  
 This method custom your Navigation Bar style
 
 @param navigationBar in this SDK
 
 @return result, UIColor
 */
- (void)customNavigationBar:(UINavigationBar *)navBar withViewController:(UIViewController *)viewController_;
- (void)customNavigationBarTitleView:(UILabel *)label_;
@end


/** @name UMSNSOauthDelegate */

/**
 
 this protocol provide interface for the oauth progress for the sns platform when oauth successfully finished 
 or failed for some error
 
 */

@protocol UMSNSOauthDelegate <NSObject> 

@optional

/**
 This method called when oauth progress finished successfully
 
 @param uid uid for the oauthed account
 @param accessToken access token for the oauthed account
 @param platfrom platform for the oauth, all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 */
- (void)oauthDidFinish:(NSString *)uid andAccessToken:(NSDictionary *)accessToken andPlatformType:(UMShareToType)platfrom;


/**  
 This method called when oauth progress failed
 
 @param error error that cause the oauth progress failed
 @param platfrom platform for the oauth, all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 */
- (void)oauthDidFailWithError:(NSError *)error andPlatformType:(UMShareToType)platfrom;

@end


/** 
 this protocol provide interface the data send progress for the sns platform when data send finished successfully or failed for some reason;
 protocol also provide interface for set the default private message content
 */
@protocol UMSNSDataSendDelegate <NSObject> 

@optional

/** 
 This method called when data send finished successfully or failed for some reason
 
 @param viewController controller of the data send view
 @param returnStatus data send return result
 @param platfrom platform for the data send to, all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 */
- (void)dataSendDidFinish:(UIViewController *)viewController andReturnStatus:(UMReturnStatusType)returnStatus andPlatformType:(UMShareToType)platfrom;

/** 
 This method called when data send failed for error occured
 
 @param error error that cause data send failed
 @param platfrom platform for the data send to, all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 */
- (void)dataSendFailWithError:(NSError *)error andPlatformType:(UMShareToType)platfrom;

/** 
 This method return the default private message content
 
 @param  platfrom platform for the private message send to, all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 @result default private message content  
 */
- (NSString *)invitationContent:(UMShareToType)platfrom;


/**  
 This method return a bool result to indicate whether show appinfo on the account management page
 
 @param  platfrom all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 @result YES to show the appinfo, No to not show
 */
- (BOOL)shouldShowAppInfor:(UMShareToType)platfrom;


/**  
 This method return a NSDictionary object, must contain these four keys:@"name", @"location", @"description", @"uid"
 
 @param  platfrom all the three possible value: UMShareToTypeRenr, UMShareToTypeSina, UMShareToTypeTenc
 
 @result appinfo, a NSDictionary object
 */
- (NSDictionary *)appInfor:(UMShareToType)platfrom;


/** 
 This method called after The share ViewController showed and get the status words.
 
 @param status the SNS status which will sended
 */
- (void)willSendStatus:(NSString *)status;

@end

/** 
 use this protocol, you can set the platform which it will show in showSNSActionSheetInController
 */
@protocol UMSNSShowActionSheetDelegate <NSObject>

/**  
 set the platform should not show in the actionSheet
 
 @param platform    Set the platform show or disappear in the actionSheet
 @result            show or disappear
 */
- (BOOL)shouldShowInActionSeet:(UMShareToType)platform;

@end