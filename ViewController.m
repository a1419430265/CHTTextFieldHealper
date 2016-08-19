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
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 300, 180, 200)];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 150, 180, 30)];
    field.placeholder = @"我的父视图移动";
    field.borderStyle = UITextBorderStyleRoundedRect;
    [view addSubview:field];
    field.moveView = view;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(190, 300, 180, 200)];
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    
    UITextField *field2 = [[UITextField alloc] initWithFrame:CGRectMake(0, 150, 180, 30)];
    field2.placeholder = @"我的父视图偏移";
    field2.borderStyle = UITextBorderStyleRoundedRect;
    [scrollView addSubview:field2];
    field2.moveView = scrollView;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
