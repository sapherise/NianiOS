//
//  UpYun.h
//  UpYunSDK2.0
//
//  Created by jack zhou on 13-8-6.
//  Copyright (c) 2013年 upyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Base64/MF_Base64Additions.h>
#import <NSData+MD5Digest/NSData+MD5Digest.h>
#import <AFNetworking/AFNetworking.h>
#import "NSData+Utils.h"
/**
 *	@brief 默认空间名（必填项），可在init之后修改bucket的值来更改
 */

#define DEFAULT_BUCKET @"nianimg"
/**
 *	@brief	默认表单API功能密钥 （必填项），可在init之后修改passcode的值来更改
 */
#define DEFAULT_PASSCODE @"UVvH8brDCR+B03GMP6aqZeldtS4="

/**
 *	@brief	默认当前上传授权的过期时间，单位为“秒” （必填项，较大文件需要较长时间)，可在init之后修改expiresIn的值来更改
 */
//#error 必填项
#define DEFAULT_EXPIRES_IN 600

#define API_DOMAIN @"http://v0.api.upyun.com/"

typedef void(^SUCCESS_BLOCK)(id result);
typedef void(^FAIL_BLOCK)(NSError * error);
typedef void(^PROGRESS_BLOCK)(CGFloat percent,long long requestDidSendBytes);

@interface UpYun : NSObject

@property (nonatomic, copy) NSString *bucket;

@property (nonatomic, assign) NSTimeInterval expiresIn;

@property (nonatomic, copy) NSMutableDictionary *params;

@property (nonatomic, copy) NSString *passcode;

@property (nonatomic, copy) SUCCESS_BLOCK   successBlocker;

@property (nonatomic, copy) FAIL_BLOCK      failBlocker;

@property (nonatomic, copy) PROGRESS_BLOCK  progressBlocker;


/**********************/
/**以下新增接口 建议使用**/
/**
 *	@brief	上传文件
 *
 *	@param 	file 	文件信息 可用值:  1、UIImage(会转成PNG格式，需要其他格式请先转成NSData传入 或者 传入文件路径)、
 2、NSData、
 3、NSString(文件路径)
 *	@param 	saveKey 	由开发者自定义的saveKey
 */
-(void)uploadFile:(id)file saveKey:(NSString *)saveKey;

/**以上新增接口 建议使用**/
/**********************/


/**
 *	@brief	上传图片接口
 *
 *	@param 	image 	图片
 *	@param 	savekey 	savekey
 */
- (void) uploadImage:(UIImage *)image savekey:(NSString *)savekey;

/**
 *	@brief	上传图片接口
 *
 *	@param 	path 	图片path
 *	@param 	savekey 	savekey
 */
- (void) uploadImagePath:(NSString *)path savekey:(NSString *)savekey;


/**
 *	@brief	上传图片接口
 *
 *	@param 	data 	图片data
 *	@param 	savekey 	savekey
 */
- (void) uploadImageData:(NSData *)data savekey:(NSString *)savekey;

@end
