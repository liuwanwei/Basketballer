//
//  NewPlayerViewController.m
//  Basketballer
//
//  Created by Liu Wanwei on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NewPlayerViewController.h"
#import "PlayerManager.h"
#import "AppDelegate.h"
#import "Feature.h"

@interface NewPlayerViewController (){
    UIBarButtonItem * _cancelItem;
    UIBarButtonItem * _saveItem;
}

@end

@implementation NewPlayerViewController

@synthesize numberLabel = _numberLabel;
@synthesize nameLabel = _nameLabel;
@synthesize number = _number;
@synthesize name = _name;
@synthesize player = _player;
@synthesize team = _team;
@synthesize parentWhoPresentedMe = _parentWhoPresentedMe;

- (void)dismiss{
    if (_parentWhoPresentedMe) {
        [_parentWhoPresentedMe dismissModalViewControllerAnimated:YES];
    }else if(self.navigationController != nil){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showInvalidNumberAlert{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:LocalString(@"InvalidNumber") 
                                                message:LocalString(@"InputValidNumber") 
                                                delegate:self 
                                                cancelButtonTitle:LocalString(@"Ok") 
                                                otherButtonTitles:nil, nil];
    [alert show];
}

- (void)save{
    NSString * numberText = self.number.text;
    if (nil == numberText || numberText.length == 0) {
        [self showInvalidNumberAlert];
        return;
    }
    
    NSInteger numberInteger = [numberText integerValue];
    if (numberInteger > 99) {
        [self showInvalidNumberAlert];
        return;
    }
    
    PlayerManager * pm = [PlayerManager defaultManager];                
    NSNumber * number = [NSNumber numberWithInteger:numberInteger];    
    Player * player = nil;
    if (self.player == nil) {
        player = [pm addPlayerForTeam:_team withNumber:number withName:self.name.text];
    }else{
        player = [pm updatePlayer:_player withNumber:number andName:self.name.text];
    }

    if(nil == player){
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:
                               LocalString(@"RepeatNumber")
                               message:LocalString(@"RepeatNumberMessage") 
                               delegate:self 
                               cancelButtonTitle:LocalString(@"Ok") 
                               otherButtonTitles:nil, nil];
        [alert show];
        [self.number becomeFirstResponder];
    }else{
        [self dismiss];
    }
}

- (void)deletePlayer{
    [[PlayerManager defaultManager] deletePlayer:_player];
    [self dismiss];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"Cancel") 
            style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = item;
    
    _saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = _saveItem;
    
    _cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    
    self.numberLabel.text = LocalString(@"Number");
    self.nameLabel.text = LocalString(@"Name");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.player != nil) {
        self.number.text = [self.player.number stringValue];
        self.name.text = self.player.name;
        
        self.title = LocalString(@"PlayerInfo");
        [[Feature defaultFeature] initNavleftBarItemWithController:self];        
    }else{
        self.title = LocalString(@"NewPlayer");
        self.navigationItem.leftBarButtonItem = _cancelItem;
    }
    
    [self.number becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
