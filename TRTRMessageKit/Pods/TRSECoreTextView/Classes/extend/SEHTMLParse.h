
#import <Foundation/Foundation.h>

#define kTRActInfo @"kTRActInfo"
#define kTREmotionInfo @"kTREmotionInfo"
#define kTRTopicInfo @"kTRTopicInfo"

#define kTRLinkTextColor @"kTRLinkTextColor"
#define kTRTextEditable @"kTRTextEditable"

#define kDefaultlinkColor [UIColor colorWithRed:0x35 / 255.0 green:0x7A / 255.0 blue:0xA5 / 255.0 alpha:1.0]

@interface SEHTMLParse:NSObject<NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableAttributedString *parsedAttr;
@property (nonatomic, copy) NSMutableSet *parsedAttachments;

+(NSAttributedString*)autoRemoveAction:(NSAttributedString*)attributeStr;
+(NSUInteger)getNewLocation:(NSAttributedString*)attributeStr withCurLocation:(NSUInteger)location;
+(NSString*)getHtmlStr:(NSAttributedString*)attributeStr;
+(NSString*)getHtmlPreview:(NSAttributedString*)attributeStr;

-(void)parseHtmlStr:(NSString*)str withAttr:(NSDictionary*)attr;
-(void)parseHtmlStrToIOSFormat:(NSString*)str withAttr:(NSDictionary*)attr;
-(void)clear;

+(BOOL)isExistTopic:(NSAttributedString*)attributeStr;
@end

