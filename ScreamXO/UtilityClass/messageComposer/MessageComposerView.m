// MessageComposerView.m
//
// Copyright (c) 2015 oseparovic. ( http://thegameengine.org )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MessageComposerView.h"

@interface MessageComposerView()
- (IBAction)sendClicked:(id)sender;
@property(nonatomic, strong) UIView *accessoryView;
@property(nonatomic, strong) UIView *accessoryViewSubView;
@property(nonatomic) CGFloat composerTVMaxHeight;
@end

@implementation MessageComposerView
static NSString* const keyModelId = @"mintACV_id";
const NSInteger defaultHeight = 50;
const NSInteger defaultMaxHeight = 100;

- (id)init {
    _messageTextView.enablesReturnKeyAutomatically = true;
    _messageTextView.returnKeyType = UIReturnKeySend;
    return [self initWithKeyboardOffset:0 andMaxHeight:defaultMaxHeight];
}

- (id)initWithKeyboardOffset:(NSInteger)offset andMaxHeight:(CGFloat)maxTVHeight {
    CGFloat frameWidth  = [self currentScreenSize].width;
    CGFloat yPos = [self currentScreenSize].height-defaultHeight;
    return [self initWithFrame:CGRectMake(0, yPos, frameWidth, defaultHeight) andKeyboardOffset:offset andMaxHeight:maxTVHeight];
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andKeyboardOffset:0];
}

- (id)initWithFrame:(CGRect)frame andKeyboardOffset:(NSInteger)offset {
    return [self initWithFrame:frame andKeyboardOffset:offset andMaxHeight:defaultMaxHeight];
}

- (id)initWithFrame:(CGRect)frame andKeyboardOffset:(NSInteger)offset andMaxHeight:(CGFloat)maxTVHeight {
    self = [super initWithFrame:frame];
    if (self) {
        // Insets for the entire MessageComposerView. Top inset is used as a minimum value of top padding.
        _composerBackgroundInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        // Insets only for the message UITextView. Default to 0
        _composerTVInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        
        // Default animation time for 5 <= iOS <= 7. Should be overwritten by first keyboard notification.
        _keyboardAnimationDuration = 0.25;
        _keyboardAnimationCurve = 7;
        _keyboardOffset = offset;
        _composerBackgroundInsets.top = MAX(_composerBackgroundInsets.top, frame.size.height - _composerBackgroundInsets.bottom - 34);
        _composerTVMaxHeight = maxTVHeight;
        
        // Default character cap if one hasn't been set
        if (_characterCap <= 0) {
            _characterCap = 400;
        }
        
        // alloc necessary elements
        self.sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.sendButton addTarget:self action:@selector(sendClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = [[UIView alloc] init];
        
        // fix ridiculous jumpy scrolling bug inherant in native UITextView since 7.0
        // http://stackoverflow.com/a/19339716/740474
        NSString *reqSysVer = @"7.0";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        BOOL osVersionSupported = ([currSysVer compare:reqSysVer  options:NSNumericSearch] != NSOrderedAscending);
        if (osVersionSupported)  {
            NSTextStorage* textStorage = [[NSTextStorage alloc] init];
            NSLayoutManager* layoutManager = [NSLayoutManager new];
            [textStorage addLayoutManager:layoutManager];
            NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
            [layoutManager addTextContainer:textContainer];
            self.messageTextView = [[MintAnnotationChatView alloc] initWithFrame:CGRectZero textContainer:textContainer];
        } else {
            self.messageTextView = [[MintAnnotationChatView alloc] initWithFrame:CGRectZero];
        }
        
        //self.messageTextView.delegate = self;
        
        // configure elements
        self.messagePlaceholder = @"Add Comment";
        [self setup];
        
        // insert elements above MessageComposerView
        [self addSubview:self.sendButton];
        [self addSubview:self.accessoryView];
        [self addSubview:self.messageTextView];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Configuration
- (void)setup {
    //    self.backgroundColor = [UIColor colorWithRed:242/255.0f green:242/255.0f blue:242/255.0f alpha:1.0];
    self.backgroundColor = UIColor.whiteColor;
    
    // MARK: Top border implementation
    
    CALayer *TopBorder = [CALayer layer];
    TopBorder.frame = CGRectMake(8.0f, 0.0f, self.frame.size.width - 16.0, 1.0f);
    TopBorder.backgroundColor = [UIColor colorWithRed:185/255.0f green:185/255.0f blue:185/255.0f alpha:1.0].CGColor;
    [self.layer addSublayer:TopBorder];
    
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = NO;
    
    [self.sendButton setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin)];
    [self.sendButton setImage:[UIImage imageNamed:@"timer_new_icon"] forState:UIControlStateNormal];
    self.sendButton.layer.masksToBounds = true;
    //[self.sendButton.layer setCornerRadius:5];
    //    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [self.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    //    [self.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    //    [self.sendButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    //[self.sendButton setBackgroundColor:[UIColor orangeColor]];
    //[self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
    //[self.sendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    
    [self.accessoryView setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin)];
    
    [self.messageTextView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin)];
    [self.messageTextView setShowsHorizontalScrollIndicator:NO];
    [self.messageTextView.layer setCornerRadius:2];
    
    [self.messageTextView setFont:[UIFont fontWithName:@"ProximaNova-Regular" size:14]];
    //    [self.messageTextView setTextColor:[UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0]];
    [self.messageTextView setTextColor: UIColor.blackColor];
    [self.messageTextView setDelegate:self];
    
    [self setupFrames];
    
    NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setupFrames {
    CGRect sendButtonFrame = self.bounds;
    sendButtonFrame.size.width = 40;
    sendButtonFrame.size.height = 29 ;//defaultHeight - _composerBackgroundInsets.top - _composerBackgroundInsets.bottom;
    sendButtonFrame.origin.x = self.frame.size.width -35; //- _composerBackgroundInsets.right - sendButtonFrame.size.width;
    sendButtonFrame.origin.y = self.bounds.size.height -45;//- _composerBackgroundInsets.bottom - sendButtonFrame.size.height;
    [self.sendButton setFrame:sendButtonFrame];
    
    CGRect accessoryFrame = self.bounds;
    accessoryFrame.size.width = self.accessoryViewSubView.frame.size.width;
    accessoryFrame.size.height = defaultHeight - _composerBackgroundInsets.top - _composerBackgroundInsets.bottom;
    accessoryFrame.origin.x = _composerBackgroundInsets.left;
    accessoryFrame.origin.y = self.bounds.size.height - _composerBackgroundInsets.bottom - accessoryFrame.size.height;
    [self.accessoryView setFrame:accessoryFrame];
    // [self.accessoryViewSubView setCenter:CGPointMake(self.accessoryView.frame.size.width/2, self.accessoryView.frame.size.height/2)];
    
    CGRect messageTextViewFrame = self.bounds;
    messageTextViewFrame.origin.x = 0 ;//_composerTVInsets.left + _composerBackgroundInsets.left;
    if (accessoryFrame.size.width > 0) {
        messageTextViewFrame.origin.x += accessoryFrame.size.width + 20;
    }
    else
        messageTextViewFrame.origin.x += 120;
    
    //messageTextViewFrame.origin.y = _composerTVInsets.top;
    messageTextViewFrame.size.width = [UIScreen mainScreen].bounds.size.width - 90; //_composerTVInsets.right - accessoryFrame.size.width - _composerTVInsets.left - _composerBackgroundInsets.left;
    messageTextViewFrame.size.height = messageTextViewFrame.size.height;
    [self.messageTextView setFrame:messageTextViewFrame];
}

- (void)layoutSubviews {
    // Due to inconsistent handling of rotation when receiving UIDeviceOrientationDidChange notifications
    // ( see http://stackoverflow.com/q/19974246/740474 ) rotation handling and view resizing is done here.
    CGFloat oldHeight = self.messageTextView.frame.size.height;
    CGFloat newHeight = [self sizeWithText:self.messageTextView.text];
    
    if (newHeight >= _composerTVMaxHeight) {
        [self scrollTextViewToBottom];
    }
    if (oldHeight == newHeight) {
        // In cases where the height remains the same after the text change/rotation only change the y origin
        CGRect frame = self.frame;
        frame.origin.y = ([self currentScreenSize].height - [self currentKeyboardHeight]) - frame.size.height - _keyboardOffset;
        self.frame = frame;
        
        // Even though the height didn't change the origin did so notify delegates
        // TODO: remove deprecated method
        if ([self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:)]) {
            [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:_keyboardAnimationDuration];
        }
        if ([self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:andCurve:)]) {
            [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:_keyboardAnimationDuration andCurve:_keyboardAnimationCurve];
        }
    } else {
        // The view is already animating as part of the rotation so we just have to make sure it
        // snaps to the right place and resizes the textView to wrap the text with the new width. Changing
        // to add an additional animation will overload the animation and make it look like someone is
        // shuffling a deck of cards.
        // Recalculate MessageComposerView container frame
        CGRect newContainerFrame = self.frame;
        newContainerFrame.size.height = newHeight + _composerBackgroundInsets.top + _composerBackgroundInsets.bottom + _composerTVInsets.top + _composerTVInsets.bottom;
        // NSLog(@"height:%f",newContainerFrame.size.height);
        // NSLog(@"full height:%f",[self currentScreenSize].height);
        newContainerFrame.origin.y = ([self currentScreenSize].height - [self currentKeyboardHeight]) - newContainerFrame.size.height - _keyboardOffset;
        
        // Recalculate send button frame
        CGRect newSendButtonFrame = self.sendButton.frame;
        newSendButtonFrame.origin.y = newContainerFrame.size.height - (_composerBackgroundInsets.bottom + newSendButtonFrame.size.height);
        
        // Recalculate accessory frame
        CGRect newAccessoryFrame = self.accessoryView.frame;
        newAccessoryFrame.origin.y = newContainerFrame.size.height - (_composerBackgroundInsets.bottom + newAccessoryFrame.size.height);
        
        // Recalculate UITextView frame
        CGRect newTextViewFrame = self.messageTextView.frame;
        newTextViewFrame.size.height = newHeight;
        newTextViewFrame.origin.y = _composerBackgroundInsets.top + _composerTVInsets.top;
        
        self.frame = newContainerFrame;
        //NSLog(@"final:%@",NSStringFromCGRect(newContainerFrame));
        self.sendButton.frame = newSendButtonFrame;
        self.accessoryView.frame = newAccessoryFrame;
        self.messageTextView.frame = newTextViewFrame;
        [self scrollTextViewToBottom];
        
        // TODO: remove deprecated method
        if ([self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:)]) {
            [self.delegate messageComposerFrameDidChange:newContainerFrame withAnimationDuration:0];
        }
        if ([self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:andCurve:)]) {
            [self.delegate messageComposerFrameDidChange:newContainerFrame withAnimationDuration:0 andCurve:0];
        }
    }
}


#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [self setNeedsDisplay];
    
    // length = 0, but attributed have id
    if (self.messageTextView.attributedText.string.length == 0)
    {
        [self.messageTextView clearAllAttributedStrings];
    }
    
    [self layoutSubviews];
    if ([textView.text isEqualToString:self.messagePlaceholder] || [textView.text length] == 0 || [self isStringOnlyWhiteSpace:textView.text]) {
        [self.sendButton setEnabled:YES];
    } else {
        [self.sendButton setEnabled:YES];
        self.messageTextView.textColor = [UIColor colorWithRed:131.0f/255.0f green:131.0f/255.0f blue:137.0f/255.0f alpha:1.0];
    }
    
    if ([self.delegate respondsToSelector:@selector(messageComposerUserTyping)])
        [self.delegate messageComposerUserTyping];
}

- (void)textViewDidBeginEditing:(UITextView*)textView {
    if ([textView.text isEqualToString:self.messagePlaceholder]) {
        textView.text = @"";
        textView.textColor = [UIColor colorWithRed:131.0f/255.0f green:131.0f/255.0f blue:137.0f/255.0f alpha:1.0];
        [self.sendButton setEnabled:YES];
    }
    
    CGRect frame = self.frame;
    frame.origin.y = ([self currentScreenSize].height - [self currentKeyboardHeight]) - frame.size.height - _keyboardOffset;
    
    [UIView animateWithDuration:_keyboardAnimationDuration
                          delay:0.0
                        options:(_keyboardAnimationCurve << 16)
                     animations:^{self.frame = frame;}
                     completion:nil];
    
    // TODO: remove deprecated method
    //    if ([self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:)]) {
    //        [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:_keyboardAnimationDuration];
    //    }
    //    if ([self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:andCurve:)]) {
    //        [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:_keyboardAnimationDuration andCurve:_keyboardAnimationCurve];
    //    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _messageTextView.enablesReturnKeyAutomatically = true;
    if  ([textView.text isEqualToString:@""] || [textView.text isEqualToString:@" "] || [textView.text length] == 0 || [self isStringOnlyWhiteSpace:textView.text]) {
        _messageTextView.enablesReturnKeyAutomatically = true;
        NSLog(@"%@",self.messageTextView.text);
    } else {
        _messageTextView.enablesReturnKeyAutomatically = false;
        NSLog(@"%@",self.messageTextView.text);

    }
    if ([text  isEqual: @"\n"])  {
        
        
        if ([self.delegate respondsToSelector:@selector(messageComposerSendMessageClickedWithMessage:)]) {
            [self.delegate messageComposerSendMessageClickedWithMessage:self.messageTextView.text];
        }
        [self.messageTextView setText:@""];
        [self textViewDidChange:self.messageTextView];
        
        
        return NO;
    }
    return YES;
    
//    
//    __block BOOL result = YES;
//    
//    // ALl clear
//    if (range.location == 0 && range.length == self.messageTextView.attributedText.string.length)
//    {
//        //        NSLog(@"<<<<<< --- all cleared by keyboard");
//        [self.messageTextView clearAll];
//        return YES;
//    }
//    
//    // Checking Trying to insert within tag
//    if (text.length > 0)
//    {
//        NSRange rangeOfCheckingEditingInTag = range;
//        if (rangeOfCheckingEditingInTag.location + rangeOfCheckingEditingInTag.length <= self.messageTextView.attributedText.length)
//        {
//            rangeOfCheckingEditingInTag.length = 1;
//            rangeOfCheckingEditingInTag.location-=1;
//            
//            //            NSLog(@"<<<<< ----------- 1");
//            
//            //
//            NSInteger totalLength = rangeOfCheckingEditingInTag.location + rangeOfCheckingEditingInTag.length;
//            if (totalLength > self.messageTextView.attributedText.length)
//            {
//                rangeOfCheckingEditingInTag = NSMakeRange(0, 0);
//                //                NSLog(@"<<<<< ----------- 2");
//            }
//            else if (totalLength < 1)
//            {
//                rangeOfCheckingEditingInTag = NSMakeRange(0, 0);
//                //                NSLog(@"<<<<< -------------3");
//            }
//        }
//        
//        
//        [self.messageTextView.attributedText enumerateAttributesInRange:rangeOfCheckingEditingInTag options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
//            
//            if ([attrs objectForKey:keyModelId] && [self.messageTextView annotationForId:[attrs objectForKey:keyModelId]])
//            {
//                NSLog(@"------- Editing In Tag");
//                result = NO;
//            }
//            
//        }];
//        
//        
//        return result;
//    }
//    // Deleting
//    else
//    {
//        range.location-=1;
//        if (range.location == -1)
//            range.location = 0;
//        
//        if (range.length == 0)
//        {
//            //            NSLog(@"location >>>> 0");
//            
//            if (self.messageTextView.attributedText.length == 0)
//            {
//                [self.messageTextView clearAllAttributedStrings];
//            }
//            
//            return YES;
//            
//        }
//        //        NSLog(@"editingRange :%d, %d",editingRange.location, editingRange.length);
//        
//        [self.messageTextView.attributedText enumerateAttributesInRange:range options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
//            
//            if ([attrs objectForKey:keyModelId] && [self.messageTextView annotationForId:[attrs objectForKey:keyModelId]])
//            {
//                
//                NSRange tagRange = [self.messageTextView findTagPosition:[self.messageTextView annotationForId:[attrs objectForKey:keyModelId]]];
//                
//                //                NSLog(@"Deleted annotation tag >>>>> id(%@):range(%d,%d)",[attrs objectForKey:keyModelId], tagRange.location, tagRange.length);
//                
//                self.messageTextView.attributedText = [self.messageTextView attributedStringWithCutOutOfRange:tagRange];
//                self.messageTextView.selectedRange = NSMakeRange(tagRange.location, 0);
//                
//                [self.messageTextView.annotationList removeObject:[self.messageTextView annotationForId:[attrs objectForKey:keyModelId]]];
//                [self setNeedsDisplay];
//            }
//            
//        }];
//        
//        return YES;
//        
//    }
    
}

- (void)textViewDidEndEditing:(UITextView*)textView {
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"DataUpdated"
    // object:self];
    if ([textView.text isEqualToString:@""] || [textView.text length] == 0 || [self isStringOnlyWhiteSpace:textView.text]) {
        textView.text = self.messagePlaceholder;
        textView.textColor = [UIColor lightGrayColor];
        [self.sendButton setEnabled:YES];
    }
    [self.sendButton setEnabled:YES];
    CGRect frame = self.frame;
    frame.origin.y = [self currentScreenSize].height - self.frame.size.height - _keyboardOffset;
    
    [UIView animateWithDuration:_keyboardAnimationDuration
                          delay:0.0
                        options:(_keyboardAnimationCurve << 16)
                     animations:^{self.frame = frame;}
                     completion:nil];
    
    // TODO: remove deprecated method
    //    if ([self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:)]) {
    //        [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:_keyboardAnimationDuration];
    //    }
    //    if ([self.delegate respondsToSelector:@selector(messageComposerFrameDidChange:withAnimationDuration:andCurve:)]) {
    //        [self.delegate messageComposerFrameDidChange:frame withAnimationDuration:_keyboardAnimationDuration andCurve:_keyboardAnimationCurve];
    //    }
}


#pragma mark - Keyboard Notifications
- (void)keyboardWillShow:(NSNotification*)notification {
    // Because keyboard animation time and cure vary by iOS version, and we don't want to build the library
    // on top of spammy keyboard notifications we use UIKeyboardWillShowNotification ONLY to dynamically set our
    // animation duration. As a UIKeyboardWillShowNotification is fired BEFORE textViewDidBeginEditing
    // is triggered we can use the following values for all of animations including the first.
    _keyboardAnimationDuration = [[notification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    _keyboardAnimationCurve = [[notification userInfo][UIKeyboardAnimationCurveUserInfoKey] intValue];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    CGRect rect = [[notification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect converted = [self convertRect:rect fromView:nil];
    self.keyboardHeight = converted.size.height;
    [self setNeedsLayout];
}


#pragma mark - IBAction
- (IBAction)sendClicked:(UIButton *)sender {
    
    sender.selected  =  ! sender.selected;
    if (sender.selected)
    {
        
        
        NSLog(@" Not Selected");
        
    }
    else
    {
        
        
        NSLog(@" Selected");
        
    }
    
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataUpdated"
                                                        object:self];
    
    
    //    if ([self.delegate respondsToSelector:@selector(messageComposerSendMessageClickedWithMessage:)]) {
    //        [self.delegate messageComposerSendMessageClickedWithMessage:self.messageTextView.text];
    //    }
    //
    //  [self.messageTextView setText:@""];
    //    // Manually trigger the textViewDidChange method as setting the text when the messageTextView is not first responder the
    //    // UITextViewTextDidChangeNotification notification does not get fired.
    [self textViewDidChange:self.messageTextView];
}


#pragma mark - Utils
- (void)setMessagePlaceholder:(NSString *)messagePlaceholder {
    _messagePlaceholder = messagePlaceholder;
    [self.messageTextView setText:_messagePlaceholder];
    // Manually trigger the textViewDidChange method as setting the text when the messageTextView is not first responder the
    // UITextViewTextDidChangeNotification notification does not get fired.
    [self textViewDidChange:self.messageTextView];
}
- (void)configureWithAccessory:(UIView *)accessoryView {
    // add the accessory view (camera icons etc) to the left of the message text view and rejig the frames to accomodate.
    self.accessoryViewSubView = accessoryView;
    [self.accessoryViewSubView removeFromSuperview];
    [self.accessoryView addSubview:self.accessoryViewSubView];
    [self setupFrames];
}

- (void)scrollTextViewToBottom {
    // scrollRangeToVisible:NSMakeRange is a pretty buggy function. Manually setting the content offset seems to work better
    CGPoint offset = CGPointMake(0, self.messageTextView.contentSize.height - self.messageTextView.frame.size.height);
    [self.messageTextView setContentOffset:offset animated:NO];
}

- (CGFloat)currentKeyboardHeight {
    if ([self.messageTextView isFirstResponder]) {
        return self.keyboardHeight;
    } else {
        return 0;
    }
}

- (CGFloat)sizeWithText:(NSString*)text {
    CGFloat fixedWidth = self.messageTextView.frame.size.width;
    CGSize newSize = [self.messageTextView sizeThatFits:CGSizeMake(fixedWidth, CGFLOAT_MAX)];
    return MIN(_composerTVMaxHeight, newSize.height);
}

- (void)startEditing {
    if ([self.messageTextView isFirstResponder] == NO)
        [self.messageTextView becomeFirstResponder];
}

- (void)finishEditing {
    if ([self.messageTextView isFirstResponder])
        [self.messageTextView resignFirstResponder];
}

- (BOOL)isStringOnlyWhiteSpace:(NSString*)text {
    if ([self isStringEmpty:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]) {
        return YES;
    }
    return NO;
}

- (BOOL)isStringEmpty:(NSString*)inputString {
    //http://stackoverflow.com/a/3675518/740474
    //isEmpty will return true if the string equates to @"" or nil. Has to be static as
    //calling a method on a nil NSString will not execute the method.
    return (inputString == nil)
    || [inputString isKindOfClass:[NSNull class]]
    || ([inputString respondsToSelector:@selector(length)]
        && [(NSData *)inputString length] == 0)
    || ([inputString respondsToSelector:@selector(count)]
        && [(NSArray *)inputString count] == 0);
}


#pragma mark - Screen Size Computation
- (CGSize)currentScreenSize {
    // return the screen size with respect to the orientation
    //    return ((UIView*)self.nextResponder).frame.size;
    
    // there are a few problems with this implementation. Namely nav bar height
    // especially was unreliable. For example when UIAlertView height was present
    // we couldn't properly determine the nav bar height. The above method appears to be
    // working more consistently. If it doesn't work for you try this method below instead.
    return [self currentScreenSizeInInterfaceOrientation:[self currentInterfaceOrientation]];
}

- (CGSize)currentScreenSizeInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    // http://stackoverflow.com/a/7905540/740474
    
    // get the size of the application frame (screensize - status bar height)
    CGSize size = [UIScreen mainScreen].applicationFrame.size;
    
    // if the orientation at this point is landscape but it hasn't fully rotated yet use landscape size instead.
    // handling differs between iOS 7 && 8 so need to check if size is properly configured or not. On
    // iOS 7 height will still be greater than width in landscape without this call but on iOS 8
    // it won't
    if (UIInterfaceOrientationIsLandscape(orientation) && size.height > size.width) {
        size = CGSizeMake(size.height, size.width);
    }
    
    // subtract the height of the navigation bar from the screen height
    size.height -= [self currentNavigationBarHeight];
    
    return size;
}

- (UIInterfaceOrientation)currentInterfaceOrientation {
    // Returns the orientation of the Interface NOT the Device. The two do not happen in exact unison so
    // this point is important.
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (CGFloat)currentNavigationBarHeight {
    // TODO this will fail to get the correct height when a UIAlertView is present
    id nav = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([nav isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navc = (UINavigationController *) nav;
        if(navc.navigationBarHidden) {
            return 0;
        } else {
            return navc.navigationBar.frame.size.height;
        }
    }
    return 0;
}

@end
