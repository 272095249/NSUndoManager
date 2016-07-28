//
//  ViewController.m
//  NSUndoManager
//
//  Created by HarrySun on 16/7/28.
//  Copyright © 2016年 Mobby. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *myLabel;
@property (nonatomic, strong) NSUndoManager *undoManager;
@property (assign) int num;

@end

@implementation ViewController

@synthesize undoManager;

/*
 
 NSUndoManager会记录下修改、撤销操作的消息。这个机制使用两个NSInvocation对象栈。
 
 NSInvocation会把消息(选择器和接受者及参数)包装成一个对象，这个对象就是NSInvocation的实例。当一个对象收到它不理解的消息时，消息发送机制会在报出错误前检查该对象是否实现了forwardInvocation这个方法。如果实现了，就会将消息打包成NSInvocation对象，然后调用forwardInvocation方法。
 
 NSUndoManager工作原理：
     当进行操作时，控制器会添加一个该操作的逆操作的invocation到Undo栈中。当进行Undo操作时，Undo操作的逆操作会被添加到Redo栈中，就这样利用Undo和Redo两个堆栈巧妙的实现撤销操作。
 
 
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _myLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 300, 100, 100)];
    _myLabel.backgroundColor = [UIColor cyanColor];
    _myLabel.userInteractionEnabled = YES;
    [self.view addSubview:_myLabel];
    
    
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [addButton setFrame:CGRectMake(100, 420, 100, 50)];
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
    
    undoManager = [[NSUndoManager alloc] init];     // 初始化UndoManager
    [undoManager setLevelsOfUndo:999];      // 设置最大极限，当达到极限时扔掉旧的撤销
    _num = 0;

    
    
}

#pragma mark - NSUndoManager 操作
//  在我们的程序中有add以及这个方法的逆方法substract，我们可以这样来实现撤销功能。
-(void)substract{
    
    _num -= 10;
    [[undoManager prepareWithInvocationTarget:self] add];
    
    _myLabel.text = [NSString stringWithFormat:@"%d",_num];
    
    [self setTheUI];
}

-(void)add{
    
    _num += 10;
    [[undoManager prepareWithInvocationTarget:self] substract];  // 基于NSInvocation触发undo
    // prepareWithInvocationTarget:方法记录了target并返回UndoManager，然后UndoManager重载了forwardInvocation方法，也就将substract方法的Invocation添加到undo栈中了。
    
    _myLabel.text = [NSString stringWithFormat:@"%d",_num];
    
    [self setTheUI];
}

-(void)undo{
    
    // 执行撤销
    [self.undoManager undo];    //注意这里不是[self undo];
    
}


-(void)redo{
    
    // 执行反撤销
    [self.undoManager redo];
    
}

// 根据num的值判断是否加navigationItem
-(void)setTheUI{
    
    if (!_num){
        
        self.navigationItem.rightBarButtonItem = nil;
        
    }else{
        
        UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undo)];    // 方法没有冒号
        
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
    if (!_num){
        
        self.navigationItem.leftBarButtonItem = nil;
    }else{
        
        UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(redo)];
        
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
