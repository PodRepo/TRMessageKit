//
//  XHBubblePhotoImageView.h
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-4-28.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHMessageBubbleFactory.h"

@interface XHBubblePhotoImageView : UIView

/**
 *  发送后，需要显示的图片消息的图片，或者是视频的封面
 */
@property (nonatomic, strong) UIImage *messagePhoto;

@property (nonatomic, strong) UIImageView *videoPlayImageView;
@property (nonatomic, strong) UILabel *geolocationsLabel;
/**
 *  加载网络图片的时候，需要用到转圈的控件
 */
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, assign) double progress;

@property (strong, nonatomic) NSString *videoFileURL;
- (void)setUp;
- (void)clear;
- (void)playerVideo:(NSString*)originPhotoUrl onBubbleMessageType:(XHBubbleMessageType)bubbleMessageType;
- (void)configureMessageVideo:(NSString *)originPhotoUrl onBubbleMessageType:(XHBubbleMessageType)bubbleMessageType;
    
/**
 *
 *
 *  @param messagePhoto
 *  @param bubbleMessageType
 */
/**
 *  根据目标图片配置三角形具体位置
 *
 *  @param messagePhoto      目标图片
 *  @param thumbnailUrl      目标图片缩略图的URL链接
 *  @param originPhotoUrl    目标图片原图的URL链接
 *  @param bubbleMessageType 目标消息类型
 */
- (void)configureMessagePhoto:(UIImage *)messagePhoto thumbnailUrl:(NSString *)thumbnailUrl onBubbleMessageType:(XHBubbleMessageType)bubbleMessageType;

/**
 *  获取消息类型比如发送或接收
 *
 *  @return 消息类型
 */
- (XHBubbleMessageType)getBubbleMessageType;

@end
