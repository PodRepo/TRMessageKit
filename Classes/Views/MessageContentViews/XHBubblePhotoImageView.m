//
//  XHBubblePhotoImageView.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-4-28.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "XHBubblePhotoImageView.h"
#import "XHFoundationMacro.h"

#import "TRWebImage.h"
#import "TRCache.h"

#import "UIImage+Resize.h"
#import "XHMessageVideoConverPhotoFactory.h"

@interface XHBubblePhotoImageView ()

@property dispatch_semaphore_t semaphore;

/**
 *  消息类型
 */
@property (nonatomic, assign) XHMessageType bubbleMessageType;


//@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@end

@implementation XHBubblePhotoImageView

- (XHMessageType)getBubbleMessageType {
    return self.bubbleMessageType;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicatorView.hidesWhenStopped = YES;
        _activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight(self.frame) / 2.0);
        [self addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (void)setProgress:(double)progress{
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setMessagePhoto:(UIImage *)messagePhoto {
    _messagePhoto = messagePhoto;
    [self setNeedsDisplay];
}

- (void)setUp{
    if (self.videoPlayImageView){
        [self bringSubviewToFront:self.videoPlayImageView];
    }
}

- (void)clear{
    if (_playerLayer){
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
    
    _playerItem = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playerVideo:(NSString*)originPhotoUrl onBubbleMessageType:(XHMessageType)bubbleMessageType {
    //    originPhotoUrl = @"http://7xiakd.com2.z0.glb.qiniucdn.com/E0E7B982-B49B-4482-9491-68125B886468.MOV";
    NSLog(@"playerVideo %@ ", originPhotoUrl);
    WEAKSELF
    [[TRWebDataManager sharedManager] downloadDataWithURL:[NSURL URLWithString:originPhotoUrl] options:TRWebDataRetryFailed&TRWebDataWaitSaveDiskCompletion progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        NSLog(@" %ld %ld ", (long)receivedSize, (long)expectedSize);
        self.progress = receivedSize * 1.0 / expectedSize;
        
    } completed:^(NSData *data, NSError *error, TRWebDataCacheType cacheType, NSURL *imageURL) {
        self.progress = 0;
        if(error){
            NSLog(@"downloadDataWithURL %@ ", error);
        }
        STRONGSELF
        if (strongSelf) {
            if (originPhotoUrl == strongSelf.videoFileURL) {
                NSString *filePath = [[TRWebDataCache sharedDataCache] diskPathWithKey:originPhotoUrl];
                if (filePath){
                    strongSelf.messagePhoto = [XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:filePath];
                    [strongSelf initAndplayVideoFilePath:filePath];
                }else{
                     NSLog(@"has not stored %@ ", filePath);
                }
            }else{
                NSLog(@"originPhotoUrl %@ originPhotoUrl %@ ", originPhotoUrl, strongSelf.videoFileURL);
            }
        }
        
    }];
}


- (void) asyncPlayWithFilePath:(NSString*)filePath{
    //    filePath = @"/Users/ljc/Documents/d248a6275734625879fac47438d1aa77";
    AVAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    NSArray *requestKeys = [NSArray arrayWithObjects:@"tracks",@"playable",nil];
    [asset loadValuesAsynchronouslyForKeys:requestKeys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(),^{
            //complete block here
            NSError *err = nil;
            AVKeyValueStatus status =[asset statusOfValueForKey:@"playable" error:&err];
            if (err){
                NSLog(@"ppp1 error %@", err);
            }
            
            status =[asset statusOfValueForKey:@"tracks" error:&err];
            if (err){
                NSLog(@"ppp2 error %@", err);
            }
            if(status == AVKeyValueStatusLoaded){
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                AVPlayer *player = [AVPlayer playerWithPlayerItem:self.playerItem];
                [self.playerLayer setPlayer:player];
                
                
                [self.playerItem seekToTime:kCMTimeZero];
                [player play];
                self.videoPlayImageView.alpha = 0.0;
            }else{
                NSLog(@" fail ppp %@ ", filePath);
            }
        });
        
    }];
    
}

- (void) playWithFilePath:(NSString*)filePath{
    self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:filePath]];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self.playerLayer setPlayer:player];
    
    [self.playerItem seekToTime:kCMTimeZero];
    [player play];
    self.videoPlayImageView.alpha = 0.0;
    
}

- (void)initAndplayVideoFilePath:(NSString*)filePath{
    NSLog(@"initAndplayVideoFilePath %@ ", filePath);
    if (_playerLayer == nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.frame = CGRectMake(8, 8, 184, 134);
        _playerLayer.cornerRadius = 15.0;
        _playerLayer.masksToBounds = YES;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.layer addSublayer:_playerLayer];
        
        [self playWithFilePath:filePath];
        
    }else{
        [self playWithFilePath:filePath];
    }
    
}

- (void)configureMessageVideo:(NSString *)originPhotoUrl onBubbleMessageType:(XHMessageType)bubbleMessageType {
    //    originPhotoUrl = @"http://7xiakd.com2.z0.glb.qiniucdn.com/E0E7B982-B49B-4482-9491-68125B886468.MOV";
    self.bubbleMessageType = bubbleMessageType;
    self.messagePhoto = [UIImage imageNamed:@"m_avator"];
    _videoFileURL = originPhotoUrl;
    self.videoPlayImageView.alpha = 1.0;
    
    NSLog(@"configureMessageVideo %@ ", originPhotoUrl);
    NSString *filePath = [[TRWebDataCache sharedDataCache] diskPathWithKey:originPhotoUrl];
    if (filePath){
        self.messagePhoto = [XHMessageVideoConverPhotoFactory videoConverPhotoWithVideoPath:filePath];
    }
}

#pragma mark - PlayEndNotification
- (void)avPlayerItemDidPlayToEnd:(NSNotification *)notification
{
    if ((AVPlayerItem *)notification.object != _playerItem) {
        return;
    }
    [self clear];
    [UIView animateWithDuration:0.3f animations:^{
        self.videoPlayImageView.alpha = 1.0;
    }];
}


- (void)configureMessagePhoto:(UIImage *)messagePhoto thumbnailUrl:(NSString *)thumbnailUrl onBubbleMessageType:(XHMessageType)bubbleMessageType {
    self.bubbleMessageType = bubbleMessageType;
    self.messagePhoto = messagePhoto;
    
    //    NSLog(@"sd_downloadURL %@", thumbnailUrl);
    WEAKSELF
    [self.activityIndicatorView startAnimating];
    NSURL *url = [NSURL URLWithString:thumbnailUrl];
    [self sd_downloadURL:url options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (!weakSelf) return;
        if ([imageURL.absoluteString isEqualToString:thumbnailUrl]) {
            
            if (image) {
                // scale image
                //                image = [image thumbnailImage:CGRectGetWidth(weakSelf.bounds) * 2 transparentBorder:0 cornerRadius:0 interpolationQuality:1.0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // if image not nil
                    if (image) {
                        // show image
                        [weakSelf.activityIndicatorView stopAnimating];
                        //                        weakSelf.progress = 0.4;
                        weakSelf.messagePhoto = image;
                        
                    }
                });
            }
        }
        
    }];
    //    [[TRWebImageManager getManager] setImageWithImageView:self.messagePhoto oringinalUrl:thumbnailUrl placeholder:messagePhoto];
    //
    //    if (thumbnailUrl) {
    //        WEAKSELF
    //        [self addSubview:self.activityIndicatorView];
    //        [self.activityIndicatorView startAnimating];
    //        [self setImageWithURL:[NSURL URLWithString:thumbnailUrl] placeholer:nil showActivityIndicatorView:NO completionBlock:^(UIImage *image, NSURL *url, NSError *error) {
    //            if ([url.absoluteString isEqualToString:thumbnailUrl]) {
    //
    //                if (CGRectEqualToRect(weakSelf.bounds, CGRectZero)) {
    //                    if (weakSelf) {
    //                        weakSelf.semaphore = dispatch_semaphore_create(0);
    //                        dispatch_semaphore_wait(weakSelf.semaphore, DISPATCH_TIME_FOREVER);
    //                        weakSelf.semaphore = nil;
    //                    }
    //                }
    //
    //                // if image not nil
    //                if (image) {
    //                    // scale image
    //                    image = [image thumbnailImage:CGRectGetWidth(weakSelf.bounds) * 2 transparentBorder:0 cornerRadius:0 interpolationQuality:1.0];
    //                    dispatch_async(dispatch_get_main_queue(), ^{
    //                        // if image not nil
    //                        if (image) {
    //                            // show image
    //                            weakSelf.messagePhoto = image;
    //                            [weakSelf.activityIndicatorView stopAnimating];
    //                        }
    //                    });
    //                }
    //            }
    //        }];
    //    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
    }
    _activityIndicatorView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc {
    _messagePhoto = nil;
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView = nil;
    [self sd_cancelImageLoadOperationWithKey:@"UIViewImageLoad"];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}


//- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx {
//    [super drawLayer:layer inContext:ctx];
//    [self drawRect1:self.frame];
//}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    rect.origin = CGPointZero;
    [self.messagePhoto drawInRect:rect];
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height+1;//莫名其妙会出现绘制底部有残留 +1像素遮盖
    // 简便起见，这里把圆角半径设置为长和宽平均值的1/10
    CGFloat radius = 6;
    CGFloat margin = 8;//留出上下左右的边距
    
    CGFloat triangleSize = 8;//三角形的边长
    CGFloat triangleMarginTop = 8;//三角形距离圆角的距离
    
    CGFloat borderOffset = 3;//阴影偏移量
    UIColor *borderColor = [UIColor blackColor];//阴影的颜色
    
    // 获取CGContext，注意UIKit里用的是一个专门的函数
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSetRGBStrokeColor(context,0,0,0,1);//画笔颜色
    CGContextSetLineWidth(context, 1);//画笔宽度
    // 移动到初始点
    CGContextMoveToPoint(context, radius + margin, margin);
    // 绘制第1条线和第1个1/4圆弧
    CGContextAddLineToPoint(context, width - radius - margin, margin);
    CGContextAddArc(context, width - radius - margin, radius + margin, radius, -0.5 * M_PI, 0.0, 0);
    CGContextAddLineToPoint(context, width, margin + radius);
    CGContextAddLineToPoint(context, width, 0);
    CGContextAddLineToPoint(context, radius + margin,0);
    // 闭合路径
    CGContextClosePath(context);
    // 绘制第2条线和第2个1/4圆弧
    CGContextMoveToPoint(context, width - margin, margin + radius);
    CGContextAddLineToPoint(context, width, margin + radius);
    CGContextAddLineToPoint(context, width, height - margin - radius);
    CGContextAddLineToPoint(context, width - margin, height - margin - radius);
    
    float arcSize = 3;//角度的大小
    
    if (self.bubbleMessageType == XHMessageType_Sending) {
        float arcStartY = margin + radius + triangleMarginTop + triangleSize - (triangleSize - arcSize / margin * triangleSize) / 2;//圆弧起始Y值
        float arcStartX = width - arcSize;//圆弧起始X值
        float centerOfCycleX = width - arcSize - pow(arcSize / margin * triangleSize / 2, 2) / arcSize;//圆心的X值
        float centerOfCycleY = margin + radius + triangleMarginTop + triangleSize / 2;//圆心的Y值
        float radiusOfCycle = hypotf(arcSize / margin * triangleSize / 2, pow(arcSize / margin * triangleSize / 2, 2) / arcSize);//半径
        float angelOfCycle = asinf(0.5 * (arcSize / margin * triangleSize) / radiusOfCycle) * 2;//角度
        //绘制右边三角形
        CGContextAddLineToPoint(context, width - margin , margin + radius + triangleMarginTop + triangleSize);
        CGContextAddLineToPoint(context, arcStartX , arcStartY);
        CGContextAddArc(context, centerOfCycleX, centerOfCycleY, radiusOfCycle, angelOfCycle / 2, 0.0 - angelOfCycle / 2, 1);
        CGContextAddLineToPoint(context, width - margin , margin + radius + triangleMarginTop);
    }
    
    
    CGContextMoveToPoint(context, width - margin, height - radius - margin);
    CGContextAddArc(context, width - radius - margin, height - radius - margin, radius, 0.0, 0.5 * M_PI, 0);
    CGContextAddLineToPoint(context, width - margin - radius, height);
    CGContextAddLineToPoint(context, width, height);
    CGContextAddLineToPoint(context, width, height - radius - margin);
    
    
    // 绘制第3条线和第3个1/4圆弧
    CGContextMoveToPoint(context, width - margin - radius, height - margin);
    CGContextAddLineToPoint(context, width - margin - radius, height);
    CGContextAddLineToPoint(context, margin, height);
    CGContextAddLineToPoint(context, margin, height - margin);
    
    
    CGContextMoveToPoint(context, margin, height-margin);
    CGContextAddArc(context, radius + margin, height - radius - margin, radius, 0.5 * M_PI, M_PI, 0);
    CGContextAddLineToPoint(context, 0, height - margin - radius);
    CGContextAddLineToPoint(context, 0, height);
    CGContextAddLineToPoint(context, margin, height);
    
    
    // 绘制第4条线和第4个1/4圆弧
    CGContextMoveToPoint(context, margin, height - margin - radius);
    CGContextAddLineToPoint(context, 0, height - margin - radius);
    CGContextAddLineToPoint(context, 0, radius + margin);
    CGContextAddLineToPoint(context, margin, radius + margin);
    
    if (!self.bubbleMessageType == XHMessageType_Sending) {
        float arcStartY = margin + radius + triangleMarginTop + (triangleSize - arcSize / margin * triangleSize) / 2;//圆弧起始Y值
        float arcStartX = arcSize;//圆弧起始X值
        float centerOfCycleX = arcSize + pow(arcSize / margin * triangleSize / 2, 2) / arcSize;//圆心的X值
        float centerOfCycleY = margin + radius + triangleMarginTop + triangleSize / 2;//圆心的Y值
        float radiusOfCycle = hypotf(arcSize / margin * triangleSize / 2, pow(arcSize / margin * triangleSize / 2, 2) / arcSize);//半径
        float angelOfCycle = asinf(0.5 * (arcSize / margin * triangleSize) / radiusOfCycle) * 2;//角度
        //绘制左边三角形
        CGContextAddLineToPoint(context, margin , margin + radius + triangleMarginTop);
        CGContextAddLineToPoint(context, arcStartX , arcStartY);
        CGContextAddArc(context, centerOfCycleX, centerOfCycleY, radiusOfCycle, M_PI + angelOfCycle / 2, M_PI - angelOfCycle / 2, 1);
        CGContextAddLineToPoint(context, margin , margin + radius + triangleMarginTop + triangleSize);
    }
    CGContextMoveToPoint(context, margin, radius + margin);
    CGContextAddArc(context, radius + margin, margin + radius, radius, M_PI, 1.5 * M_PI, 0);
    CGContextAddLineToPoint(context, margin + radius, 0);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, radius + margin);
    
    
    //
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), borderOffset, borderColor.CGColor);//阴影
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    
    CGContextDrawPath(context, kCGPathFill);
    
    //    [self drawProgress:self.progress inrect:rect];
    
    //    UIColor * redColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    CGContextSetBlendMode (context, kCGBlendModeSourceAtop);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.5);
    CGContextSetAlpha(context, 0.5);
    CGRect blaceRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + (1 - self.progress) * CGRectGetHeight(rect), CGRectGetWidth(rect), CGRectGetHeight(rect));
    CGContextFillRect(context, blaceRect);
    
    UIGraphicsPopContext();
}

@end
