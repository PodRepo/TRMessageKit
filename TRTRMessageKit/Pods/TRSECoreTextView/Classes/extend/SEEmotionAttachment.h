//
//  SETextAttachment.h
//  SECoreTextView-iOS
//
//  Created by kishikawa katsumi on 2013/04/26.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "SETextAttachment.h"

@interface SEEmotionAttachment : SETextAttachment

@property (nonatomic, readonly) CTRunDelegateCallbacks callbacks;
- (id)initWithAttr:(NSDictionary*)attr range:(NSRange)range;

@end
