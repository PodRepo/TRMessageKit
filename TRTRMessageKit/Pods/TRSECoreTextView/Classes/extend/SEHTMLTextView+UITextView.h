
#import <UIKit/UIKit.h>
#import "SEHTMLParse.h"

@interface UITextView (SEHTMLView)

@property (nonatomic, strong) SEHTMLParse *parser;

// <act type="at" name="好人" id="sdfss">aa</act>
- (void)addAt:(NSString*)name withId:(NSString*)id;
- (void)replaceWithAt:(NSString*)name withId:(NSString*)id;
/// 不带@前缀
-(void)addAtWithoutPrefix:(NSString *)name withId:(NSString *)id;

- (void)addEmotion:(NSString *)type;
- (void)replaceWithEmotion:(NSString *)type;

// add topic
- (void)addTopic:(NSString *)name withId:(NSString *)id;
- (NSString *)topicId;
- (BOOL)isExistTopic;

- (NSString*)getHtmlStr;
- (NSString*)getHtmlPreview;
- (NSArray*)atUserIds;

- (void)appendHtmlStr:(NSString*)text;
- (void)setHtmlStr:(NSString *)str;

-(CGFloat)newHeightWithMaxSize:(CGSize)maxSize;

-(NSInteger)autoRemoveAction;

@end

