//
//  MintAnnotationView.m
//  MintAnnotationView
//
//  Created by soleaf on 13. 8. 26..
//  Mintcode.org
//  http://www.mintcode.org/
//  Repository : https://github.com/soleaf/MintAnnotationView
//

#import <QuartzCore/QuartzCore.h>
#import "MintAnnotationChatView.h"

static NSString* const keyModelId = @"mintACV_id";

@interface MintAnnotationChatView()
{
    BOOL isModified;
    NSMutableArray *tagViews;
}

@end

@implementation MintAnnotationChatView


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentMode = UIViewContentModeRedraw;
        
        self.annotationList = [[NSMutableArray alloc] init];
        self.rangesOfAt = [[NSMutableArray alloc]init];
        self.rangesOfAtOriginal = [[NSMutableArray alloc]init];
        self.bounces = NO;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    [super drawRect:rect];
    
    for (UIView *tagView in tagViews) {
        [tagView removeFromSuperview];
    }
    
    if (self.annotationList == nil || self.attributedText.length  < 1) return;
    
    // 3. Find and draw
    
    [self.attributedText enumerateAttribute:keyModelId inRange:NSMakeRange(0, self.attributedText.length)
                                    options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                                        
                                        if ([self annotationForId:value]){
                                            //                                            NSLog(@"%d, %d",range.location, range.length);
                                            CFRange cfRange = CFRangeMake(range.location, range.length);
                                            [self calculatingTagRectAndDraw:cfRange];
                                            
                                            
                                        }
                                        
                                    }];
    
}

- (void) calculatingTagRectAndDraw:(CFRange) annoationStringRange
{
    /*
     Caclulating Rect and Draw
     */
    
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UITextView *textView = self;
    
    // 4) Find rect
    CFRange stringRange = annoationStringRange;
    UITextPosition *begin = [textView positionFromPosition:textView.beginningOfDocument offset:stringRange.location];
    UITextPosition *end = [textView positionFromPosition:begin offset:stringRange.length];
    UITextRange *textRange = [textView textRangeFromPosition:begin toPosition:end];
    
    // 5) Need 2line?
    CGPoint firstCharPosition = [textView caretRectForPosition:begin].origin;
    CGPoint lastCharPosition = [textView caretRectForPosition:end].origin;
    
    if (firstCharPosition.y < lastCharPosition.y){
        
        // Finf pos of first line
        float secondY = firstCharPosition.y;
        CFRange secondStrRange = CFRangeMake(stringRange.location, 1); // first time is just init, not have mean of value
        NSInteger secondPos = stringRange.location;
        NSInteger cnt = 0;
        
        while (secondY < lastCharPosition.y) {
            
            secondPos++;
            cnt++;
            
            secondStrRange = CFRangeMake(secondPos, stringRange.length - cnt);
            UITextPosition *secondBegin = [textView positionFromPosition:textView.beginningOfDocument offset:secondStrRange.location];
            CGPoint secondPosition = [textView caretRectForPosition:secondBegin].origin;
            secondY = secondPosition.y;
            
        }
        
        // Calculate rect
        UITextPosition *secondBegin = [textView positionFromPosition:textView.beginningOfDocument offset:secondStrRange.location];
        UITextPosition *secondEnd = [textView positionFromPosition:secondBegin offset:secondStrRange.length];
        UITextRange *secondTextRange = [textView textRangeFromPosition:secondBegin toPosition:secondEnd];
        
        // 1st line
        [self drawTag:context Rect:[textView firstRectForRange:textRange]
                 name:[self textInRange:[textView textRangeFromPosition:textRange.start toPosition:secondBegin]]];
        
        // 2nd Line
        [self drawTag:context Rect:[textView firstRectForRange:secondTextRange]
                 name:[self textInRange:secondTextRange]];
    }
    else{
        // Draw rect first line
        [self drawTag:context Rect:[textView firstRectForRange:textRange] name:[self textInRange:textRange]];
    }
}



#pragma mark - Draw Tag graphics

- (void) drawTag: (CGContextRef) context Rect:(CGRect) rect name:(NSString*)nameText
{
    if(self.nameTagImage)
        [self drawTagImageInRect:rect name:nameText];
    else
        [self drawRectangle:context Rect:rect];
}

- (void) drawRectangle: (CGContextRef) context Rect:(CGRect) rect
{
    rect.size.width+=1;
    rect.size.height-=2;
    rect.origin.y+=1;
    
    if (_nameTagColor == nil)
        self.nameTagColor = [UIColor colorWithRed:0.12 green:0.31 blue:0.60 alpha:0.5];
    if (_nameTagLineColor == nil)
        self.nameTagLineColor = [UIColor clearColor];
    
    CGContextSetFillColorWithColor(context, _nameTagColor.CGColor);
    CGContextSetStrokeColorWithColor(context, _nameTagLineColor.CGColor);
    
    // Draw line
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
    
    // Fill
    CGContextFillRect(context, rect);
    CGContextStrokeRectWithWidth(context, rect, 0.5);
}

- (void) drawTagImageInRect:(CGRect) rect name:(NSString*)nameText
{
    self.nameTagColor = self.nameTagColor;
    
    UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tagButton.frame = CGRectMake(rect.origin.x,
                                 rect.origin.y+1,
                                 rect.size.width,
                                 rect.size.height);
    
    [tagButton setBackgroundImage:self.nameTagImage forState:UIControlStateNormal];
    [tagButton setTitle:nameText forState:UIControlStateNormal];
    [tagButton setTitleColor:self.nameTagColor forState:UIControlStateNormal];
    tagButton.titleLabel.font = [UIFont systemFontOfSize:self.font.pointSize-4];
    
    if (!tagViews)
        tagViews = [[NSMutableArray alloc] init];
    
    [tagViews addObject:tagButton];
    [self addSubview:tagButton];
    
    
    //    UIImageView *tagImage = [[UIImageView alloc]
    //                             tagImage.image = self.nameTagImage;
    //    [self addSubview:tagImage];
    //
    //    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x+2, rect.origin.y+2, rect.size.width-4, rect.size.height-4)];
    //    tagLabel.textColor = _nameTagColor;
    //    tagLabel.text = nameText;
    //    tagLabel.backgroundColor = [UIColor clearColor];
    //    tagLabel.font = [UIFont systemFontOfSize:self.font.pointSize-4];
    //    tagLabel.textAlignment = NSTextAlignmentCenter;
    //    tagLabel.minimumScaleFactor = .2;
    //    [self addSubview:tagLabel];
    
    //    if (!tagViews)
    //        tagViews = [[NSMutableArray alloc] init];
    
    //    [tagViews addObject:tagImage];
    //    [tagViews addObject:tagLabel];
}


#pragma mark - Modeling

// --- NEW ---
- (void)addAnnotation:(MintAnnotation *)newAnnoation
{
    // Check aleady imported
    for (MintAnnotation *annotation in self.annotationList) {
        
        if ([annotation.usr_id isEqualToString:newAnnoation.usr_id])
        {
//            NSLog(@"MintAnnoationChatView >> addAnoation >> id'%@'is aleady in", newAnnoation.usr_id);
            return;
        }
    }
    
    // Add
    if (!self.annotationList) self.annotationList = [[NSMutableArray alloc] init];
    [self.annotationList addObject:newAnnoation];
    
    
    if (!self.rangesOfAt) self.rangesOfAt = [[NSMutableArray alloc] init];
    if (!self.rangesOfAtOriginal) self.rangesOfAtOriginal = [[NSMutableArray alloc]init];
    
    // Insert Plain user name text
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] initWithDictionary:[self defaultAttributedString]];
    [attr setObject:newAnnoation.usr_id forKey:keyModelId];
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc]
                                             initWithString:[NSString stringWithFormat:@"%@", newAnnoation.usr_name]
                                             attributes:attr];
    
    NSMutableAttributedString *spaceStringPefix = nil;
    NSString *tempCommentWriting = self.text;
    
//    NSLog(@"nameString:%@",nameString);

    
    NSInteger cursor = self.selectedRange.location;
    // display name
    
    // Add Last
//    NSLog(@"self.attributedText.string.length:%d",self.attributedText.string.length);
    if (cursor >= self.attributedText.string.length-1)
    {
        // Add Space
        if (tempCommentWriting.length > 0){
            
            NSString *prevString = [tempCommentWriting substringFromIndex:tempCommentWriting.length-1];
            
            if (![prevString isEqualToString:@"\n"])
            {
                spaceStringPefix = [[NSMutableAttributedString alloc] initWithString:@" " attributes:[self defaultAttributedString]];
            }
        }
        
        NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        if (spaceStringPefix)
            [conts appendAttributedString:spaceStringPefix];
        [conts appendAttributedString:nameString];
        NSMutableAttributedString *afterBlank = [[NSMutableAttributedString alloc] initWithString:@" "
                                                                                       attributes:[self defaultAttributedString]];
        [conts appendAttributedString:afterBlank];
        
//        NSLog(@"conts:%@",conts);
        
        self.attributedText = conts;
//        NSLog(@"\n\nself.attributedText:%@",self.attributedText);
        
    }
    // Insert in text
    else
    {
        self.attributedText = [self attributedStringInsertString:nameString at:cursor];
    }
    
    
    [self setNeedsDisplay];
    
    // Pass Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)])
        [self.delegate textViewDidChange:self];
}

- (NSRange) findTagPosition:(MintAnnotation*)annoation
{
    
    __block NSRange stringRange = NSMakeRange(0, 0);
    [self.attributedText enumerateAttribute:keyModelId inRange:NSMakeRange(0, self.attributedText.length-1)
                                    options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
                                        
                                        if ([value isEqualToString:annoation.usr_id])
                                        {
                                            stringRange = range;
                                            //                                            stringRange = CFRangeMake(range.location, range.location + range.length);
                                        }
                                        
                                    }];
    
    return stringRange;
    
}

- (MintAnnotation *) annotationForId:(NSString*)usr_id
{
    for (MintAnnotation *annotation in self.annotationList) {
        
        if ([annotation.usr_id isEqualToString:usr_id])
            return annotation;
    }
    
    return nil;
}


- (NSString *)setTextWithTageedString:(NSString *)memo
{
    
    
    NSMutableAttributedString *parsingMemo = [[NSMutableAttributedString alloc] initWithString:memo];
    [parsingMemo setAttributes:[self defaultAttributedString] range:NSMakeRange(0, parsingMemo.length)];
    
//    NSLog(@"memo:%@",parsingMemo);
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"<u uid=[^>]*>[^>]*<\\/u>"
                                  options:0
                                  error:&error];
    
    if (error){
//        NSLog(@"error:%@",error.description);
        return nil;
    }
    
    [regex enumerateMatchesInString:parsingMemo.string options:0 range:NSMakeRange(0, [parsingMemo length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                             
                             // detect
                             // <u uid=?>?</u>
                             NSRange range = [match rangeAtIndex:0];
                             NSString *insideString = [parsingMemo.string substringWithRange:range];
                             
                             // Name
                             NSRegularExpression *regexUsrName = [NSRegularExpression
                                                                  regularExpressionWithPattern:@">[가-힣a-zA-Z0-9]*<"
                                                                  options:0
                                                                  error:nil];
                             NSRange usrNameRange = [regexUsrName rangeOfFirstMatchInString:insideString
                                                                                    options:0
                                                                                      range:NSMakeRange(0, insideString.length)];
                             
                             if (usrNameRange.location != NSNotFound)
                             {
                                 NSString *userName = [insideString substringWithRange:usrNameRange];
                                 userName = [userName stringByReplacingOccurrencesOfString:@">" withString:@""];
                                 userName = [userName stringByReplacingOccurrencesOfString:@"<" withString:@""];
//                                 NSLog(@"userName:%@",userName);
                                 
                                 // ID
                                 NSRegularExpression *regexUsrID = [NSRegularExpression
                                                                    regularExpressionWithPattern:@"uid=[^>]*"
                                                                    options:0
                                                                    error:nil];
                                 NSRange usrIDRange = [regexUsrID rangeOfFirstMatchInString:insideString
                                                                                    options:0
                                                                                      range:NSMakeRange(0, insideString.length)];
                                 NSString *userID = [insideString substringWithRange:usrIDRange];
                                 userID = [userID stringByReplacingOccurrencesOfString:@"uid=" withString:@""];
                                 userID = [userID stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//                                 NSLog(@"userID:%@",userID);
                                 
                                 if (userID && userName)
                                 {
                                     MintAnnotation *annotation = [[MintAnnotation alloc] init];
                                     annotation.usr_id = userID;
                                     annotation.usr_name = userName;
                                     
                                     if (!self.annotationList) self.annotationList = [[NSMutableArray alloc] init];
                                     
                                     [self.annotationList addObject:annotation];
                                     
                                     NSRange userNameStringRange = NSMakeRange(range.location + usrNameRange.location+1, usrNameRange.length-2);
//                                     NSLog(@"nameRange:%d,%d",userNameStringRange.location,userNameStringRange.length);
                                     [parsingMemo addAttribute:keyModelId value:userID range:userNameStringRange];
                                 }
                                 
                                 
                             }
                             
                         }];
    
    
    NSRange r;
    
    while ((r = [[parsingMemo mutableString] rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        
        [[parsingMemo mutableString] replaceCharactersInRange:r withString:@""];
    }
    
    self.attributedText = parsingMemo;
    [self setNeedsDisplay];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewDidChange:)])
        [self.delegate textViewDidChange:self];
    
    
    return self.attributedText.string;
}

#pragma mark - UITextviewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self setNeedsDisplay];
    
    // length = 0, but attributed have id
    if (self.attributedText.string.length == 0)
    {
        [self clearAllAttributedStrings];
    }
    
    return;
    
}

- (BOOL) shouldChangeTextInRange:(NSRange)editingRange replacementText:(NSString *)text
{
    
    __block BOOL result = YES;
    
    // ALl clear
    if (editingRange.location == 0 && editingRange.length == self.attributedText.string.length)
    {
//        NSLog(@"<<<<<< --- all cleared by keyboard");
        //[self clearAll];
        return YES;
    }
    
    // Checking Trying to insert within tag
    if (text.length > 0)
    {
        NSRange rangeOfCheckingEditingInTag = editingRange;
        if (rangeOfCheckingEditingInTag.location + rangeOfCheckingEditingInTag.length <= self.attributedText.length)
        {
            rangeOfCheckingEditingInTag.length = 1;
            rangeOfCheckingEditingInTag.location-=1;
            
//            NSLog(@"<<<<< ----------- 1");
            
            //
            NSInteger totalLength = rangeOfCheckingEditingInTag.location + rangeOfCheckingEditingInTag.length;
            if (totalLength > self.attributedText.length)
            {
                rangeOfCheckingEditingInTag = NSMakeRange(0, 0);
//                NSLog(@"<<<<< ----------- 2");
            }
            else if (totalLength < 1)
            {
                rangeOfCheckingEditingInTag = NSMakeRange(0, 0);
//                NSLog(@"<<<<< -------------3");
            }
        }
        
        
        [self.attributedText enumerateAttributesInRange:rangeOfCheckingEditingInTag options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            
            if ([attrs objectForKey:keyModelId] && [self annotationForId:[attrs objectForKey:keyModelId]])
            {
                NSLog(@"------- Editing In Tag");
                result = NO;
            }
            
        }];
        
        
        return result;
    }
    // Deleting
    else
    {
        editingRange.location-=1;
        if (editingRange.location == -1)
            editingRange.location = 0;
        
        if (editingRange.length == 0)
        {
//            NSLog(@"location >>>> 0");
            
            if (self.attributedText.length == 0)
            {
                [self clearAllAttributedStrings];
            }
            
            return YES;
            
        }
//        NSLog(@"editingRange :%d, %d",editingRange.location, editingRange.length);
        
        [self.attributedText enumerateAttributesInRange:editingRange options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            
            if ([attrs objectForKey:keyModelId] && [self annotationForId:[attrs objectForKey:keyModelId]])
            {
                
                NSRange tagRange = [self findTagPosition:[self annotationForId:[attrs objectForKey:keyModelId]]];
                
//                NSLog(@"Deleted annotation tag >>>>> id(%@):range(%d,%d)",[attrs objectForKey:keyModelId], tagRange.location, tagRange.length);
                
                self.attributedText = [self attributedStringWithCutOutOfRange:tagRange];
                self.selectedRange = NSMakeRange(tagRange.location, 0);
                if ([self.text length] == 1) {
                    if ([[self.text substringFromIndex:[self.text length] - 1]  isEqual: @" "]) {
                        self.text = [self.text stringByReplacingCharactersInRange:NSMakeRange(([self.text length] - 1), 1) withString:@""];
                    }
                } else {
                    //no characters to delete... attempting to do so will result in a crash
                }
                [self.annotationList removeObject:[self annotationForId:[attrs objectForKey:keyModelId]]];
                [self setNeedsDisplay];
            }
            
        }];
        
        return YES;
        
    }
    
}


#pragma mark - AttributedStrings
- (NSAttributedString *) attributedStringWithCutOutOfRange:(NSRange)cuttingRange
{
    /*
     Cut out string of range on full string
     to get head + tail without middle
     */
    
    // Cutting Heads
    NSAttributedString *head = nil;
    if (cuttingRange.location > 0 && cuttingRange.length > 0)
        head = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, cuttingRange.location-1)];
    else
        head = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    
    
    // Cutting Tail
    
    NSAttributedString *tail = nil;
    if (cuttingRange.location + cuttingRange.length <= self.attributedText.string.length)
        tail = [self.attributedText attributedSubstringFromRange:NSMakeRange(cuttingRange.location + cuttingRange.length,
                                                                             self.attributedText.length - cuttingRange.location - cuttingRange.length)];
    
    NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    if (head)
        [conts appendAttributedString:head];
    if (tail)
        [conts appendAttributedString:tail];
    
    return conts;
}

- (NSAttributedString *) attributedStringInsertString:(NSAttributedString*)insertingStr at:(NSInteger)position
{
    /*
     Insert str within text at position
     with blank
     -> head + blank + insertingStr + blank + tail
     */
    
    // Cutting Heads
    NSAttributedString *head = nil;
    if (position > 0 && self.attributedText.string.length > 0)
        head = [self.attributedText attributedSubstringFromRange:NSMakeRange(0, position)];
    else if (position > 0)
        head = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    
    
    // Cutting Tail
    NSAttributedString *tail = nil;
    if (position + 1 < self.attributedText.string.length)
        tail = [self.attributedText attributedSubstringFromRange:NSMakeRange(position,
                                                                             self.attributedText.length - position)];
    else{
        tail = [[NSMutableAttributedString alloc] initWithString:@" " attributes:[self defaultAttributedString]];
    }
    
    NSMutableAttributedString *conts = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[self defaultAttributedString]];
    
    if (head)
    {
        [conts appendAttributedString:head];
        [conts appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:[self defaultAttributedString]]];
    }
    
    [conts appendAttributedString:insertingStr];
    
    if (tail)
    {
        [conts appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:[self defaultAttributedString]]];
        [conts appendAttributedString:tail];
    }
    
    return conts;
}

- (NSDictionary*) defaultAttributedString
{
    return @{NSFontAttributeName : self.font};
}



#pragma mark -ETC

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(paste:) ||
        action == @selector(cut:) ||
        action == @selector(copy:) ||
        action == @selector(select:) ||
        action == @selector(selectAll:)
        ) {
        return YES;
    }
    return NO;
}
- (NSAttributedString*) taggedString {
    NSMutableAttributedString *workingStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    // Finding Replace ranges and annoations
    [workingStr enumerateAttribute:keyModelId inRange:NSMakeRange(0, workingStr.string.length) options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            
                            MintAnnotation *annoation = nil;
                            if (value){
                                annoation = [self annotationForId:value];
                            }
                            
                            if (annoation){
                                NSString *replaceTo = [NSString stringWithFormat:@"@:@:%@@",
                                                       annoation.usr_id];
                                NSLog(@"%lu", (unsigned long)range.location);
                                [self.rangesOfAt addObject:[NSString stringWithFormat:@"%lu,%@", (unsigned long)range.location,annoation.usr_id]];
                                [workingStr replaceCharactersInRange:range withString:replaceTo];
                                NSLog(@"%@", workingStr.string);
                            }
                            
                            
                        }];
    
    return workingStr;
}
- (NSString*) makeStringWithTag
{
    
    NSMutableAttributedString *workingStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    // Finding Replace ranges and annoations
    [workingStr enumerateAttribute:keyModelId inRange:NSMakeRange(0, workingStr.string.length) options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            
                            MintAnnotation *annoation = nil;
                            if (value){
                                annoation = [self annotationForId:value];
                            }
                            
                            if (annoation) {
                                NSString *replaceTo = [NSString stringWithFormat:@"@:@:%@",
                                                       annoation.usr_id];
                                [workingStr replaceCharactersInRange:range withString:replaceTo];
                                
                            }
                            
                            
                        }];
    
    return workingStr.string;
    
}

- (NSString*) makeStringWithoutTagString
{
    
    NSMutableAttributedString *workingStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    // Finding Replace ranges and annoations
    [workingStr enumerateAttribute:keyModelId inRange:NSMakeRange(0, workingStr.string.length) options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            
                            MintAnnotation *annoation = nil;
                            if (value){
                                annoation = [self annotationForId:value];
                            }
                            
                            if (annoation){
                                NSLog(@"%lu", (unsigned long)range.location);
                                [self.rangesOfAtOriginal addObject:[NSString stringWithFormat:@"%lu", (unsigned long)range.location]];
                                NSLog(@"%lu", (unsigned long)range.length);
                                NSLog(@"%@", workingStr.string);
                                NSString *replaceTo = [NSString stringWithFormat:@"@%@",
                                                       annoation.usr_name];
                                [workingStr replaceCharactersInRange:range withString:replaceTo];
                                
                            }
                            
                        }];
    
    return workingStr.string;
    
}

- (void) clearAllAttributedStrings
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributedString removeAttribute: keyModelId range: NSMakeRange(0, self.text.length)];
    [self.annotationList removeAllObjects];
    [self setNeedsDisplay];
//    NSLog(@"cleared attributes!");
}


- (void)clearAll
{
    [self clearAllAttributedStrings];
    self.attributedText = [[NSAttributedString alloc]initWithString:@"" attributes:[self defaultAttributedString]];
    [self setNeedsDisplay];
}
@end
