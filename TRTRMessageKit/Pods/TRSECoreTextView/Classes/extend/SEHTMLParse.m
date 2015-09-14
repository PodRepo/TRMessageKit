//
//  DTAttributedTextView.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 1/12/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SEHTMLParse.h"
#import "SEEmotionAttachment.h"



@interface SEElementNode:NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSDictionary *attr;
@end

@implementation SEElementNode
@end



@interface SEHTMLParse ()
@property (nonatomic, copy) NSMutableArray *elements;
@property (nonatomic, copy) SEElementNode *curElement;
@property (nonatomic, copy) NSError *parseError;

@property (nonatomic, strong) NSDictionary *defaultAttr;
@property (nonatomic, assign) BOOL isIOSFormat;
@end


@implementation SEHTMLParse

+(NSAttributedString*)autoRemoveAction:(NSAttributedString*)attributeStr{
    NSMutableAttributedString *retStr = [[NSMutableAttributedString alloc] init];
    __block BOOL actStarted = NO;
    __block NSMutableString *actStr = [[NSMutableString alloc] init];
    __block NSString *actName = @"";
     __block NSDictionary *actAttr = nil;
    [attributeStr enumerateAttributesInRange:NSMakeRange(0, attributeStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSDictionary *actInfo = [attrs objectForKey:kTRActInfo];
        if(actInfo){
            actName = [actInfo objectForKey:@"name"];
            actAttr = attrs;
            [actStr appendString:[[attributeStr attributedSubstringFromRange:range] string]];
            actStarted = YES;
        }else{
            if (actStarted) {
                if ([actName isEqualToString:actStr]) {
                    [retStr appendAttributedString:[[NSAttributedString alloc] initWithString:actName attributes:actAttr]];
                }
                actStr = [[NSMutableString alloc] init];
                actName = @"";
                actStarted = NO;
                actAttr = nil;
            }
            
            [retStr appendAttributedString:[attributeStr attributedSubstringFromRange:range]];
        }

    }];
    //    NSLog(@"3 %@", retStr);
    return retStr;
}


+(NSUInteger)getNewLocation:(NSAttributedString*)attributeStr withCurLocation:(NSUInteger)location{
    __block NSUInteger newLocation = 0;
    __block NSUInteger actStartLoc = 0;
    __block BOOL actStarted = NO;
    [attributeStr enumerateAttributesInRange:NSMakeRange(0, attributeStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSDictionary *actInfo = [attrs objectForKey:kTRActInfo];
        if(actInfo ){
            if (!actStarted) {
                actStartLoc = range.location;
            }
            actStarted = YES;
        }else{
            if (actStarted) {
                if (actStartLoc <= location && location < range.location + range.length) {
                    newLocation = actStartLoc;
                }
            }
            actStarted = NO;
        }
    }];
    
    if (newLocation != 0) {
        return newLocation;
    }else{
        return location;
    }
}

+(NSString*)getHtmlStr:(NSAttributedString*)attributeStr{
    //    SEHTMLParse *parse = [[SEHTMLParse alloc] init];
    //    [parse parseHtmlStr:@"asfd asf<act type='at' name='好人' id='id'></act> <e src='titleicon_53'></e> "];
    //    attributeStr = parse.parsedAttr;
    
    NSMutableString *retStr = [NSMutableString string];
    __block BOOL actStarted = NO;
    [attributeStr enumerateAttributesInRange:NSMakeRange(0, attributeStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSDictionary *emotionInfo = [attrs objectForKey:kTREmotionInfo];
        NSDictionary *actInfo = [attrs objectForKey:kTRActInfo];
//        NSDictionary *topicInfo = [attrs objectForKey:kTRTopicInfo];
        if (emotionInfo) {
            actStarted = NO;
            NSString *src = [emotionInfo objectForKey:@"src"];
            [retStr appendFormat:@"<e src=\"%@\"></e>", src];
        }else if(actInfo){
            NSString *id = [actInfo objectForKey:@"id"];
            NSString *type = [actInfo objectForKey:@"type"];
            NSString *name = [actInfo objectForKey:@"name"];
            if (!actStarted) {
                [retStr appendFormat:@"<act id=\"%@\" type=\"%@\" name=\"%@\"></act>", id, type, name];
            }
            actStarted = YES;
        }
//        else if (topicInfo){
//            NSString *id = [actInfo objectForKey:@"id"];
//            NSString *type = [actInfo objectForKey:@"type"];
//            NSString *name = [actInfo objectForKey:@"name"];
//            if (!actStarted) {
//                [retStr appendFormat:@"<act id=\"%@\" type=\"%@\" name=\"%@\"></act>", id, type, name];
//            }
//            actStarted = YES;
//        }
        else{
             actStarted = NO;
            [retStr appendString:[[attributeStr attributedSubstringFromRange:range] string]];
        }
    }];
    return retStr;
}

+(NSString*)getHtmlPreview:(NSAttributedString*)attributeStr{
    //    SEHTMLParse *parse = [[SEHTMLParse alloc] init];
    //    [parse parseHtmlStr:@"asfd asf<act type='at' name='好人' id='id'></act> <e src='titleicon_53'></e> "];
    //    attributeStr = parse.parsedAttr;
    
    NSMutableString *retStr = [NSMutableString string];
    __block BOOL actStarted = NO;
    [attributeStr enumerateAttributesInRange:NSMakeRange(0, attributeStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSDictionary *emotionInfo = [attrs objectForKey:kTREmotionInfo];
        NSDictionary *actInfo = [attrs objectForKey:kTRActInfo];
        if (emotionInfo) {
            actStarted = NO;
            [retStr appendFormat:@"[表情]"];
        }else if(actInfo){
            NSString *name = [actInfo objectForKey:@"name"];
            if (!actStarted) {
                [retStr appendFormat:@"@%@", name];
            }
            actStarted = YES;
        }else{
            actStarted = NO;
            [retStr appendString:[[attributeStr attributedSubstringFromRange:range] string]];
        }
    }];
    return retStr;

}

-(void)clear{
    _parsedAttr = nil;
    _parsedAttachments = nil;
    
    _elements = nil;
    _curElement = nil;
    _parseError = nil;
}

-(void)parseHtmlStr:(NSString*)str withAttr:(NSDictionary *)attr{
    _isIOSFormat = NO;
    _defaultAttr = attr;
    NSString* wrapperStr = [NSString stringWithFormat:@"<body>%@</body>", str];
    NSData *data = [wrapperStr dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    
    [xmlParser setDelegate:self];
    [xmlParser parse];
    
    if(!_parseError){
        
    }else{
        NSLog(@"Error %@", _parseError);
        _parsedAttr = [[NSMutableAttributedString alloc] init];
        _parsedAttachments = [[NSMutableSet alloc] init];
    }
}

-(void)parseHtmlStrToIOSFormat:(NSString*)str withAttr:(NSDictionary *)attr{
    _isIOSFormat = YES;
    _defaultAttr = attr;
    NSString* wrapperStr = [NSString stringWithFormat:@"<body>%@</body>", str];
    NSData *data = [wrapperStr dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
    
    [xmlParser setDelegate:self];
    [xmlParser parse];
    
    if(!_parseError){
        
    }else{
        NSLog(@"Error %@", _parseError);
        _parsedAttr = [[NSMutableAttributedString alloc] init];
        _parsedAttachments = [[NSMutableSet alloc] init];
    }
}


// Document handling methods
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    _parsedAttr = [[NSMutableAttributedString alloc] init];
    _parseError = nil;
    _elements = [[NSMutableArray alloc] init];
    _parsedAttachments  = [[NSMutableSet alloc] init];
    _curElement = nil;
}
// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    //     NSLog(@"end");
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if (_parseError) {
        return;
    }
//    NSLog(@"didStartElement %@", elementName);
    _curElement = [[SEElementNode alloc] init];
    [_elements addObject:_curElement];
    _curElement.name = elementName;
    _curElement.attr = attributeDict;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (_parseError) {
        return;
    }
    //    NSLog(@"foundCharacters %@", string);
    
    if (!_curElement) {
        _parseError = [NSError errorWithDomain:@"HTML parse:has not curelement" code:2 userInfo:nil];
        return;
    }
    
    if ([_curElement.name isEqualToString:@"body"]) {
        [_parsedAttr appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:_defaultAttr]];
    }
}

- (UIImage*)getImage:(NSString*)text with:(NSDictionary*)attr{
    UIFont *font = [attr objectForKey:NSFontAttributeName];
    UIColor *color = [attr objectForKey:kTRLinkTextColor];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(1000, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color} context:nil];
    CGFloat leading = 0.0;
    rect = CGRectMake(leading, 0.0, CGRectGetWidth(rect) + leading * 2, CGRectGetHeight(rect));
    
//    UIGraphicsBeginImageContext(rect.size);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    [text drawInRect:rect withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:color}];
    // 从当前context中创建一个改变大小后的图片
    UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return textImage;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if (_parseError) {
        return;
    }
    //    NSLog(@"didEndElement %@", elementName);
    if (!_curElement) {
        _parseError = [NSError errorWithDomain:@"HTML parse:has not curelement" code:2 userInfo:nil];
        return;
    }
    
    if (![_curElement.name isEqualToString:elementName]) {
        _parseError = [NSError errorWithDomain:@"HTML parse:no end" code:3 userInfo:nil];
        return;
    }
    if ([_curElement.name isEqualToString:@"body"]) {
        //        NSLog(@"parse end body");
        return;
    }
    
    
    if ([_curElement.name isEqualToString:@"act"]) {
        //        NSString *name = @"user";
        NSNumber *editable = [_defaultAttr objectForKey:kTRTextEditable];
        if (editable && editable.integerValue == 1) {
            
            NSString * name = [_curElement.attr objectForKey:@"name"];
            if (!name) {
                name = @" ";
            }
            UIFont *font = [_defaultAttr objectForKey:NSFontAttributeName];
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.image = [self getImage:name with:_defaultAttr];
            attach.bounds = CGRectMake(0, font.descender, attach.image.size.width, attach.image.size.height);
            NSAttributedString* attributedString = [NSAttributedString attributedStringWithAttachment:attach];
            
            NSMutableAttributedString *attrRet = attributedString.mutableCopy;
            NSRange firstRange = NSMakeRange(0, attributedString.length);
            [attrRet addAttributes:_defaultAttr range:firstRange];
            [attrRet addAttributes:@{kTRActInfo:_curElement.attr} range:firstRange];
            
            [_parsedAttr appendAttributedString:attrRet];
        }else{
            [_parsedAttr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" " attributes:_defaultAttr]];
            NSString * name = [_curElement.attr objectForKey:@"name"];
            if (!name) {
                name = @"";
            }
            
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:name];
            
            NSRange firstRange = NSMakeRange(0, attributedString.length);
            NSDictionary *actioninfo = _curElement.attr;
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"at://%@", [actioninfo objectForKeyedSubscript:@"id"]]];
            // is Topic
            if ([[actioninfo objectForKeyedSubscript:@"type"] isEqualToString:@"topic"]) {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"topic://%@", [actioninfo objectForKeyedSubscript:@"id"]]];
            }
            NSMutableDictionary *mutAttr = [NSMutableDictionary dictionaryWithDictionary:_defaultAttr];
            UIColor *linkColor = [_defaultAttr objectForKey:kTRLinkTextColor];
            if (linkColor) {
                [mutAttr setObject:linkColor forKey:NSForegroundColorAttributeName];
            }
            [attributedString addAttributes:mutAttr range:firstRange];
            [attributedString addAttributes:@{NSLinkAttributeName:url, kTRActInfo:_curElement.attr} range:firstRange];
            [_parsedAttr appendAttributedString:attributedString];
        }
        
    }
    if ([_curElement.name isEqualToString:@"e"]) {
        if (_isIOSFormat) {
            
            UIFont *font = [_defaultAttr objectForKey:NSFontAttributeName];
            CGRect rect = [@"img" boundingRectWithSize:CGSizeMake(1000, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil];
            rect = CGRectMake(0.0, font.descender, CGRectGetHeight(rect), CGRectGetHeight(rect));
            
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            NSString *src = [_curElement.attr objectForKey:@"src"];
            attach.image = [UIImage imageNamed:src];
            attach.bounds = rect;
            NSAttributedString* attributedString = [NSAttributedString attributedStringWithAttachment:attach];
            NSMutableAttributedString *attrRet = attributedString.mutableCopy;
            NSRange firstRange = NSMakeRange(0, attributedString.length);
            [attrRet addAttributes:_defaultAttr range:firstRange];
            [attrRet addAttributes:@{kTREmotionInfo:_curElement.attr} range:firstRange];
            [_parsedAttr appendAttributedString:attrRet];
            
        }else{
            SEEmotionAttachment *attachment = [[SEEmotionAttachment alloc] initWithAttr:_curElement.attr range:NSMakeRange(_parsedAttr.length, 1)];
            [_parsedAttr appendAttributedString:attachment.originalAttributedString];
            [_parsedAttachments addObject:attachment];
        }
    }
    
    
    [_elements removeLastObject];
    _curElement = [_elements lastObject];
    if (!_curElement) {
        _parseError = [NSError errorWithDomain:@"HTML parse:no root element" code:4 userInfo:nil];
        return;
    }
    
}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString{
    if (_parseError) {
        return;
    }
    //    NSLog(@"foundIgnorableWhitespace %@", whitespaceString);
}

// this gives the delegate an opportunity to resolve an external entity itself and reply with the resulting data.

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    //    NSLog(@"parseErrorOccurred %@", parseError);
    if (_parseError) {
        return;
    }
    _parseError = parseError;
}
// ...and this reports a fatal error to the delegate. The parser will stop parsing.
+(BOOL)isExistTopic:(NSAttributedString*)attributeStr{
    __block BOOL ret = NO;
    [attributeStr enumerateAttributesInRange:NSMakeRange(0, attributeStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSDictionary *topicInfo = [attrs objectForKey:kTRActInfo];
        if (topicInfo && [[topicInfo objectForKey:@"type"] isEqualToString:@"topic"]) {
            ret = YES;
            *stop = YES;
        }
    }];
    return ret;
}

@end
