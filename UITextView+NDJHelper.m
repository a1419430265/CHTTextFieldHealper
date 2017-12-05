//
//  UITextView+NDJHelper.m
//  TransportCar
//
//  Created by niudengjun on 2017/11/28.
//  Copyright © 2017年 amplity. All rights reserved.
//

#import "UITextView+NDJHelper.h"
#import <objc/runtime.h>
static char canMoveKey;
static char moveViewKey;
static char heightToKeyboardKey;
static char initialYKey;
static char tapGestureKey;
static char keyboardYKey;
static char totalHeightKey;
static char keyboardHeightKey;
static char hasContentOffsetKey;

@implementation UITextView (NDJHelper)
@dynamic canMove;
@dynamic moveView;
@dynamic heightToKeyboard;
@dynamic initialY;
@dynamic tapGesture;
@dynamic keyboardY;
@dynamic totalHeight;
@dynamic keyboardHeight;
@dynamic hasContentOffset;

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if(IOS_VERSION >=9){
            SEL systemSel = @selector(initWithFrame:);
            SEL mySel = @selector(setupInitWithFrame:);
            [self exchangeSystemSel:systemSel bySel:mySel];
            
            SEL systemSel2 = @selector(becomeFirstResponder);
            SEL mySel2 = @selector(newBecomeFirstResponder);
            [self exchangeSystemSel:systemSel2 bySel:mySel2];
            
            SEL systemSel3 = @selector(resignFirstResponder);
            SEL mySel3 = @selector(newResignFirstResponder);
            [self exchangeSystemSel:systemSel3 bySel:mySel3];
            
            SEL systemSel4 = @selector(initWithCoder:);
            SEL mySel4 = @selector(setupInitWithCoder:);
            [self exchangeSystemSel:systemSel4 bySel:mySel4];
        }
    });
}

// 交换方法
+ (void)exchangeSystemSel:(SEL)systemSel bySel:(SEL)mySel {
    Method systemMethod = class_getInstanceMethod([self class], systemSel);
    Method myMethod = class_getInstanceMethod([self class], mySel);
    //首先动态添加方法，实现是被交换的方法，返回值表示添加成功还是失败
    BOOL isAdd = class_addMethod(self, systemSel, method_getImplementation(myMethod), method_getTypeEncoding(myMethod));
    if (isAdd) {
        //如果成功，说明类中不存在这个方法的实现
        //将被交换方法的实现替换到这个并不存在的实现
        class_replaceMethod(self, mySel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        //否则，交换两个方法的实现
        method_exchangeImplementations(systemMethod, myMethod);
    }
}

- (instancetype)setupInitWithCoder:(NSCoder *)aDecoder {
    [self setup];
    return [self setupInitWithCoder:aDecoder];
}

- (instancetype)setupInitWithFrame:(CGRect)frame {
    [self setup];
    return [self setupInitWithFrame:frame];
}

- (void)setup {
    self.heightToKeyboard = 10;
    self.canMove = YES;
    self.keyboardY = 0;
    self.totalHeight = 0;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
}

- (void)showAction:(NSNotification *)sender {
    NSLog(@"%@", sender);
    if (!self.canMove) {
        return;
    }
    self.keyboardY = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    self.keyboardHeight = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [self keyboardDidShow];
}

- (void)hideAction:(NSNotification *)sender {
    if (!self.canMove || self.keyboardY == 0) {
        return;
    }
    [self hideKeyBoard:0.25];
}

- (void)keyboardDidShow {
    if (self.keyboardHeight == 0) {
        return;
    }
    CGFloat fieldYInWindow = [self convertPoint:self.bounds.origin toView:[UIApplication sharedApplication].keyWindow].y;
    CGFloat height = (fieldYInWindow + self.heightToKeyboard + self.frame.size.height) - self.keyboardY;
    CGFloat moveHeight = height > 0 ? height : 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        if (self.hasContentOffset) {
            UIScrollView *scrollView = (UIScrollView *)self.moveView;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + moveHeight);
        } else {
            CGRect rect = self.moveView.frame;
            self.initialY = rect.origin.y;
            rect.origin.y -= moveHeight;
            self.moveView.frame = rect;
        }
        self.totalHeight += moveHeight;
    }];
}

- (void)hideKeyBoard:(CGFloat)duration {
    [UIView animateWithDuration:duration animations:^{
        if (self.hasContentOffset) {
            UIScrollView *scrollView = (UIScrollView *)self.moveView;
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - self.totalHeight);
        } else {
            CGRect rect = self.moveView.frame;
            rect.origin.y += self.totalHeight;
            self.moveView.frame = rect;
        }
        self.totalHeight = 0;
    }];
}

- (BOOL)newBecomeFirstResponder {
    if (self.moveView == nil) {
        self.moveView = [self viewController].view;
    }
    //    if (![self.moveView.gestureRecognizers containsObject:self.tapGesture]) {
    //        [self.moveView addGestureRecognizer:self.tapGesture];
    //    }
    if ([self isFirstResponder] || !self.canMove) {
        return [self newBecomeFirstResponder];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAction:) name:UIKeyboardWillHideNotification object:nil];
    return [self newBecomeFirstResponder];
}

- (BOOL)newResignFirstResponder {
    if ([self.moveView.gestureRecognizers containsObject:self.tapGesture]) {
        [self.moveView removeGestureRecognizer:self.tapGesture];
    }
    if (!self.canMove) {
        return [self newResignFirstResponder];
    }
    BOOL result = [self newResignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self hideKeyBoard:0];
    return result;
}

- (void)tapAction {
    [[self viewController].view endEditing:YES];
}

- (UIViewController *)viewController {
    UIView *next = self;
    while (1) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }else if ([nextResponder isKindOfClass:[UIWindow class]]){
            return nil;
        }
        next = next.superview;
    }
    return nil;
}

- (void)setCanMove:(BOOL)canMove {
    objc_setAssociatedObject(self, &canMoveKey, @(canMove), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)canMove {
    return [objc_getAssociatedObject(self, &canMoveKey) boolValue];
}

- (void)setHeightToKeyboard:(CGFloat)heightToKeyboard {
    objc_setAssociatedObject(self, &heightToKeyboardKey, @(heightToKeyboard), OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)heightToKeyboard {
    return [objc_getAssociatedObject(self, &heightToKeyboardKey) floatValue];
}

- (void)setMoveView:(UIView *)moveView {
    self.hasContentOffset = NO;
    if ([moveView isKindOfClass:[UIScrollView class]]) {
        self.hasContentOffset = YES;
    }
    
    objc_setAssociatedObject(self, &moveViewKey, moveView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)moveView {
    return objc_getAssociatedObject(self, &moveViewKey);
}

- (void)setInitialY:(CGFloat)initialY {
    objc_setAssociatedObject(self, &initialYKey, @(initialY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)initialY {
    return [objc_getAssociatedObject(self, &initialYKey) floatValue];
}

- (void)setTapGesture:(UITapGestureRecognizer *)tapGesture {
    objc_setAssociatedObject(self, &tapGestureKey, tapGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITapGestureRecognizer *)tapGesture {
    return objc_getAssociatedObject(self, &tapGestureKey);
}

- (void)setKeyboardY:(CGFloat)keyboardY {
    objc_setAssociatedObject(self, &keyboardYKey, @(keyboardY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)keyboardY {
    return [objc_getAssociatedObject(self, &keyboardYKey) floatValue];
}

- (void)setTotalHeight:(CGFloat)totalHeight {
    objc_setAssociatedObject(self, &totalHeightKey, @(totalHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)totalHeight {
    return [objc_getAssociatedObject(self, &totalHeightKey) floatValue];
}

- (void)setKeyboardHeight:(CGFloat)keyboardHeight {
    objc_setAssociatedObject(self, &keyboardHeightKey, @(keyboardHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)keyboardHeight {
    return [objc_getAssociatedObject(self, &keyboardHeightKey) floatValue];
}

- (void)setHasContentOffset:(BOOL)hasContentOffset {
    objc_setAssociatedObject(self, &hasContentOffsetKey, @(hasContentOffset), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)hasContentOffset {
    return [objc_getAssociatedObject(self, &hasContentOffsetKey) boolValue];
}

@end
