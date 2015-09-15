//
//  XHBubblePhotoImageView.h
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-4-28.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHMessageBubbleFactory.h"

@interface XHBubbleMsgImageView : UIView

/**
 *  发送后，需要显示的图片消息的图片，或者是视频的封面
 */
@property (nonatomic, strong) UIImage *messagePhoto;
@property (nonatomic, assign) double progress;


- (void)playerVideo:(NSString*)originPhotoUrl onBubbleMessageType:(XHMessageType)bubbleMessageType;
- (void)configureMessageVideo:(NSString *)originPhotoUrl onBubbleMessageType:(XHMessageType)bubbleMessageType;
- (void)configureMessagePhoto:(UIImage *)messagePhoto thumbnailUrl:(NSString *)thumbnailUrl onBubbleMessageType:(XHMessageType)bubbleMessageType;
- (XHMessageType)getBubbleMessageType;


@end
