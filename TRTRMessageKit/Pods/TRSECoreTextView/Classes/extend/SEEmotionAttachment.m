//
//  SETextAttachment.m
//  SECoreTextView-iOS
//
//  Created by kishikawa katsumi on 2013/04/26.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "SEEmotionAttachment.h"
#import "SEHTMLTextView.h"
#import "SEHTMLParse.h"

static void EmotionRunDelegateDeallocateCallback(void *refCon)
{
//    NSLog(@"EmotionRunDelegateDeallocateCallback");
}

static CGFloat EmotionRunDelegateGetAscentCallback(void *refCon)
{
//    SEEmotionAttachment *object = (__bridge SEEmotionAttachment *)refCon;
    UIFont *font = [SEHTMLTextView appearance].font;
    if(!font){
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    return font.ascender;
}

static CGFloat EmotionRunDelegateGetDescentCallback(void *refCon)
{
    UIFont *font = [SEHTMLTextView appearance].font;
    if(!font){
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    return -font.descender;
}

static CGFloat EmotionRunDelegateGetWidthCallback(void *refCon)
{
//    SEEmotionAttachment *object = (__bridge SEEmotionAttachment *)refCon;
    UIFont *font = [SEHTMLTextView appearance].font;
    if(!font){
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    CGFloat width = font.ascender - font.descender;
    return width;
}

//@interface SEEmotionAttachment()
//@property(nonatomic) CGSize emotionSize;
//@end

@implementation SEEmotionAttachment


- (id)initWithAttr:(NSDictionary*)attr range:(NSRange)range
{
    UIFont *font = [SEHTMLTextView appearance].font;
    if(!font){
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    }
    CGFloat width = font.ascender - font.descender;
    
    NSString *src = [attr objectForKey:@"src"];
    id object = [UIImage imageNamed:src];
    self = [super initWithObject:object size:CGSizeMake(width, width) range:range];
    if (self){
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:OBJECT_REPLACEMENT_CHARACTER];
        self.originalAttributedString = attributedString;
        self.replacedString = OBJECT_REPLACEMENT_CHARACTER;
        
        CTRunDelegateCallbacks callbacks = self.callbacks;
        CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void*)self);
        [attributedString addAttributes:@{(id)kCTRunDelegateAttributeName: (__bridge id)runDelegate, kTREmotionInfo:attr} range:NSMakeRange(0, attributedString.length)];
        CFRelease(runDelegate);
    }
    return self;
}

-(UIImage*)emotionAttachmentImage{
    return self.object;
}

- (CTRunDelegateCallbacks)callbacks
{
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.dealloc = EmotionRunDelegateDeallocateCallback;
    callbacks.getAscent = EmotionRunDelegateGetAscentCallback;
    callbacks.getDescent = EmotionRunDelegateGetDescentCallback;
    callbacks.getWidth = EmotionRunDelegateGetWidthCallback;
    
    return callbacks;
}




@end
