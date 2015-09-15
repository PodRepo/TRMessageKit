//
//  XHMessageVoiceFactory.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-4-28.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessageVoiceFactory.h"

@implementation XHMessageVoiceFactory

+ (UIImageView *)messageVoiceAnimationImageViewWithBubbleMessageType:(XHMessageType)type {
    UIImageView *messageVoiceAniamtionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    NSString *imageSepatorName;
    switch (type) {
        case XHMessageType_Sending:
            imageSepatorName = @"Sender";
            break;
        case XHMessageType_Receiving:
            imageSepatorName = @"Receiver";
            break;
        default:
            break;
    }
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:4];
    for (NSInteger i = 0; i < 4; i ++) {
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"m_%@VoiceNodePlaying00%ld", imageSepatorName, (long)i]];
        if (image)
            [images addObject:image];
    }
    
    messageVoiceAniamtionImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"m_%@VoiceNodePlaying", imageSepatorName]];
    messageVoiceAniamtionImageView.animationImages = images;
    messageVoiceAniamtionImageView.animationDuration = 1.0;
    [messageVoiceAniamtionImageView stopAnimating];
    
    return messageVoiceAniamtionImageView;
}

@end
