//
//  ViewController.m
//  CHTTextFieldHealper
//
//  Created by risenb_mac on 16/8/17.
//  Copyright © 2016年 risenb_mac. All rights reserved.
//

#import "ViewController.h"
#import "UITextField+CHTHealper.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITextField *noMoveField;
@property (strong, nonatomic) IBOutlet UITextField *defaultMoveField;
@property (strong, nonatomic) IBOutlet UITextField *heightMoveField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noMoveField.canMove = NO;
    self.heightMoveField.heightToKeyboard = 100;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 300, 375, 200)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(100, 150, 200, 30)];
    field.placeholder = @"我的父视图移动";
    field.borderStyle = UITextBorderStyleRoundedRect;
    [view addSubview:field];
    field.moveView = view;
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
