//
//  DTAttributedTextView.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 1/12/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//


#import "SEHTMLTextView.h"
#import "SETextView.h"
#import "SEEmotionAttachment.h"
#import "SEHTMLParse.h"


@interface SEHTMLTextView ()
@property (nonatomic, strong) SEHTMLParse *parse;
@end
          
          
@implementation SEHTMLTextView

+ (CGRect)frameRectWithHtmlString:(NSString *)htmStr
                          constraintSize:(CGSize)constraintSize
                             lineSpacing:(CGFloat)lineSpacing
                        paragraphSpacing:(CGFloat)paragraphSpacing
                                    font:(UIFont *)font{
    
    SEHTMLParse *parse = [[SEHTMLParse alloc] init];
    [parse parseHtmlStr:htmStr withAttr:@{NSFontAttributeName:font}];

    return [SETextView frameRectWithAttributtedString:parse.parsedAttr constraintSize:constraintSize lineSpacing:lineSpacing paragraphSpacing:paragraphSpacing font:font];
}



-(void)parseStr:(NSString*)str {
    if (!_parse) {
        _parse = [[SEHTMLParse alloc] init];
    }
    UIFont *font = self.font ? : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    [attr addEntriesFromDictionary:@{NSFontAttributeName:font}];
    if (self.htmlTextColor) {
        [attr addEntriesFromDictionary:@{NSForegroundColorAttributeName:self.htmlTextColor}];
    }
    if (self.editable) {
        [attr addEntriesFromDictionary:@{kTRTextEditable:@YES}];
    }else{
        [attr addEntriesFromDictionary:@{kTRTextEditable:@NO}];
    }
    [attr addEntriesFromDictionary:@{kTRLinkTextColor:kDefaultlinkColor}];
    [_parse parseHtmlStr:str withAttr:attr];

}


// <act type="at" name="好人" id="sdfss">aa</act>
- (void)addAt:(NSString*)name withId:(NSString*)id
{
    NSString *text = [NSString stringWithFormat:@"<act type='at' name='@%@' id='%@'>a</act>", name, id];
    [self appendHtmlStr:text];
}


- (void)replaceWithAt:(NSString*)name withId:(NSString*)id{
   
    NSString *text = [NSString stringWithFormat:@"<act type='at' name='@%@' id='%@'>a</act>", name, id];
    [self parseStr:text];
    [self insertAttributedText:_parse.parsedAttr];
    [_parse.parsedAttachments unionSet:self.attachments];
    self.attachments = _parse.parsedAttachments;
    [_parse clear];
}


- (void)addEmotion:(NSString *)type
{
    NSString *text = [NSString stringWithFormat:@"<e src='%@'>e</e>", type];
    [self appendHtmlStr:text];
}


- (void)replaceWithEmotion:(NSString *)type
{
    NSString *text = [NSString stringWithFormat:@"<e src='%@'>e</e>", type];
    [self parseStr:text];
    [self insertAttributedText:_parse.parsedAttr];
    [_parse.parsedAttachments unionSet:self.attachments];
    self.attachments = _parse.parsedAttachments;
    [_parse clear];
}

- (NSString*)getHtmlStr{
    return [SEHTMLParse getHtmlStr:self.attributedText];
}


- (NSString*)getHtmlPreview{
    return [SEHTMLParse getHtmlPreview:self.attributedText];
}

- (NSArray*)atUserIds
{
    NSMutableArray *ret = [NSMutableArray array];
    NSAttributedString *attributeStr = self.attributedText;
    [attributeStr enumerateAttributesInRange:NSMakeRange(0, attributeStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSDictionary *actInfo = [attrs objectForKey:kTRActInfo];
        if(actInfo){
            NSString *id = [actInfo objectForKey:@"id"];
            NSString *type = [actInfo objectForKey:@"type"];
            if ([type isEqualToString:@"at"]) {
                [ret addObject:id];
            }
        }
    }];
    return ret;
}

- (void)appendHtmlStr:(NSString*)text
{
    [self parseStr:text];
    
    [_parse.parsedAttr insertAttributedString:self.attributedText atIndex:0];
    self.attributedText = _parse.parsedAttr;
    [_parse.parsedAttachments unionSet:self.attachments];
    self.attachments = _parse.parsedAttachments;
    [_parse clear];

}

- (void)setHtmlStr:(NSString*)str{
    [self parseStr:str];
    self.attributedText = _parse.parsedAttr;
    self.attachments = _parse.parsedAttachments;
    [_parse clear];
}


-(CGFloat)newHeightWithMaxSize:(CGSize)maxSize
{
    return [self sizeThatFits:maxSize].height;
}


-(NSInteger)autoRemoveAction{
    
    return 0;
//    NSAttributedString *removed = [SEHTMLParse autoRemoveAction:self.attributedText];
//    NSInteger offset = [SEHTMLParse getNewLocation:self.attributedText withCurLocation:self.selectedRange.location];
//    self.attributedText = removed;
//    
//    self.selectedRange = NSMakeRange(offset, 0);
//    
//    return offset;
}

@end
