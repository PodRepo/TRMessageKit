//
//  DTAttributedTextView.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 1/12/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "SEHTMLTextView+UITextView.h"


@implementation UITextView (SEHTMLView)

@dynamic parser;

-(void)setParser:(id)p
{
    objc_setAssociatedObject(self, @selector(parser), p, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(SEHTMLParse*)parser {
    return objc_getAssociatedObject(self, @selector(parser));
}


-(void)parseStr:(NSString*)str {
    if (!self.parser) {
        self.parser = [[SEHTMLParse alloc] init];
    }
    
    UIFont *font = self.font ? : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    [attr addEntriesFromDictionary:@{NSFontAttributeName:font, @"NSOriginalFont":font}];
    if (self.textColor) {
        [attr addEntriesFromDictionary:@{NSForegroundColorAttributeName:self.textColor}];
    }
    if (self.editable) {
        [attr addEntriesFromDictionary:@{kTRTextEditable:@YES}];
    }else{
        [attr addEntriesFromDictionary:@{kTRTextEditable:@NO}];
    }
    [attr addEntriesFromDictionary:@{kTRLinkTextColor:kDefaultlinkColor}];
    [self.parser parseHtmlStrToIOSFormat:str withAttr:attr]; // 添加<body>,xml
}

-(void)addAtWithoutPrefix:(NSString *)name withId:(NSString *)id
{
    NSString *action = [NSString stringWithFormat:@"<act type=\"at\" name=\"%@\" id=\"%@\">a</act>", name, id];
    [self addAtWithAction:action];
}
// <act type="at" name="好人" id="sdfss">aa</act>
- (void)addAt:(NSString*)name withId:(NSString*)id
{
	NSString *action = [NSString stringWithFormat:@"<act type=\"at\" name=\"@%@\" id=\"%@\">a</act>", name, id];
    [self addAtWithAction:action];
}

-(void)addAtWithAction:(NSString *)action{
    [self parseStr:action];
    [self.textStorage beginEditing];
    [self.textStorage appendAttributedString:self.parser.parsedAttr];
    [self.textStorage endEditing];
    self.selectedRange = NSMakeRange(self.text.length, 0);
    [self.parser clear];
}
-(void)insertWithAction:(NSString *)action {
    [self parseStr:action];
    [self.textStorage beginEditing];
    [self.textStorage insertAttributedString:self.parser.parsedAttr atIndex:0];
    [self.textStorage endEditing];
    self.selectedRange = NSMakeRange(self.text.length, 0);
    [self.parser clear];
}

- (void)replaceWithAt:(NSString*)name withId:(NSString*)id{
  
    NSString *action = [NSString stringWithFormat:@"<act type=\"at\" name=\"@%@\" id=\"%@\">a</act> ", name, id];
    [self parseStr:action]; // 设置字体、颜色等属性
    [self.textStorage beginEditing];
    [self.textStorage replaceCharactersInRange:self.selectedRange withAttributedString:self.parser.parsedAttr];
    [self.textStorage endEditing];
    self.selectedRange = NSMakeRange(self.selectedRange.location + self.parser.parsedAttr.length, 0);
    [self.parser clear];
}

// topic
-(void)addTopic:(NSString *)name withId:(NSString *)id
{
    [self deletePreTopIfExist];
    NSString *action = [NSString stringWithFormat:@"<act type=\"topic\" name=\"#%@#\" id=\"%@\">a</act>", name, id];
    [self insertWithAction:action];
    
}

-(void)deletePreTopIfExist
{
    __block NSUInteger topicNameLen = 0;
    if([self isExistTopic]) { // delete if exist
        NSAttributedString *attributeStr = self.attributedText;
        [attributeStr enumerateAttributesInRange:NSMakeRange(0, attributeStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            NSDictionary *actInfo = [attrs objectForKey:kTRActInfo];
            if(actInfo){
                NSString *type = [actInfo objectForKey:@"type"];
                NSString *topicName = [actInfo objectForKey:@"name"];
                if ([type isEqualToString:@"topic"]) {
                    topicNameLen = topicName.length;
                    *stop = YES;
                }
            }
        }];
        if(topicNameLen > 0) {
            self.selectedRange = NSMakeRange(1, 0); // 1
            [self deleteBackward];
        }
    }
}

-(BOOL)isExistTopic
{
    return [SEHTMLParse isExistTopic:self.attributedText];
}

- (void)addEmotion:(NSString *)type
{
    NSString *text = [NSString stringWithFormat:@"<e src='%@'>e</e>", type];
    [self parseStr:text];
    [self.textStorage beginEditing];
    [self.textStorage appendAttributedString:self.parser.parsedAttr];
    [self.textStorage endEditing];
//    self.attributedText = [self.textStorage attributedSubstringFromRange:NSMakeRange(0, self.textStorage.length)];
    self.selectedRange = NSMakeRange(self.text.length, 0);
    [self.parser clear];
}


- (void)replaceWithEmotion:(NSString *)type
{
    NSString *text = [NSString stringWithFormat:@"<e src='%@'>e</e>", type];
    [self parseStr:text];
    [self.textStorage beginEditing];
    [self.textStorage replaceCharactersInRange:self.selectedRange withAttributedString:self.parser.parsedAttr];
    [self.textStorage endEditing];
    self.selectedRange = NSMakeRange(self.selectedRange.location + 1, 0);
//    self.attributedText = [self.textStorage attributedSubstringFromRange:NSMakeRange(0, self.textStorage.length)];
    [self.parser clear];
}

- (NSString*)getHtmlStr{
	return [SEHTMLParse getHtmlStr:self.attributedText];
}

- (NSString*)getHtmlPreview{
    return [SEHTMLParse getHtmlPreview:self.attributedText];
}

- (NSArray*)atUserIds
{
    return [self getIdWithType:@"at"];
}

-(NSString *)topicId
{
    return [[self getIdWithType:@"topic"] lastObject];
}

-(NSArray *)getIdWithType:(NSString *)theType
{
    NSMutableSet *ret = [NSMutableSet set];
    NSAttributedString *attributeStr = self.attributedText;
    [attributeStr enumerateAttributesInRange:NSMakeRange(0, attributeStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSDictionary *actInfo = [attrs objectForKey:kTRActInfo];
        if(actInfo){
            NSString *id = [actInfo objectForKey:@"id"];
            NSString *type = [actInfo objectForKey:@"type"];
            if ([type isEqualToString:theType]) {
                [ret addObject:id];
            }
        }
    }];
    return [ret allObjects];
}

- (void)appendHtmlStr:(NSString*)text
{
    [self parseStr:text];
    [self.textStorage beginEditing];
    [self.textStorage appendAttributedString:self.parser.parsedAttr];
    [self.textStorage endEditing];
//    NSAttributedString *a = [[NSAttributedString alloc] initWithAttributedString:self.textStorage];
//    [self setAttributedText:a];
    self.selectedRange = NSMakeRange(self.text.length, 0);
    [self.parser clear];
}

- (void)setHtmlStr:(NSString*)str{
    [self parseStr:str];
    self.attributedText = self.parser.parsedAttr;
    [self.parser clear];
}


-(CGFloat)newHeightWithMaxSize:(CGSize)maxSize
{
	return [self sizeThatFits:maxSize].height;
	//    float h = [self sizeThatFits:maxSize].height;
	//    return h;
}


-(NSInteger)autoRemoveAction{
    return 0;
//    NSAttributedString *removed = [SEHTMLParse autoRemoveAction:self.attributedText];
//    NSInteger offset = [SEHTMLParse getNewLocation:self.attributedText withCurLocation:self.selectedRange.location];
//    self.attributedText = removed;
// 
////    offset = offset > removed.length ? removed.length : offset;
//    self.selectedRange = NSMakeRange(offset, 0);
//
//    return offset;
}


@end
