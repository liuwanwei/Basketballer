//
//  PlaySoundViewController.m
//  Basketballer
//
//  Created by maoyu on 12-9-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlaySoundViewController.h"
#import "SoundManager.h"
#import "PlayGameViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface PlaySoundViewController () {
    SoundManager * _soundManager;
}

@end

@implementation PlaySoundViewController
@synthesize tableView = _tableView;
@synthesize cancelButton = _cancelButton;

- (NSString *)pageName {
    MatchUnderWay * match = [MatchUnderWay defaultMatch];
    NSString * pageName = @"PlaySound_";
    pageName = [pageName stringByAppendingString:match.matchMode];
    return pageName;
}

#pragma 事件函数
- (void)viewDidLoad
{
    [super viewDidLoad];
    _soundManager = [SoundManager defaultManager];
    self.title = LocalString(@"SoundEffect");

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:[self pageName]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:[self pageName]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    static NSArray * arr = nil;
    if (arr == nil) {
        arr = @[@"营造气氛", @"背景音乐",@""];
    }
    
    return arr[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _soundManager.soundsArray.count;
    }else if(section == 1) {
        return _soundManager.backgroundArray.count;
    }else if(section == 2){
        return 1;
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = [_soundManager.soundsArray objectAtIndex:indexPath.row];
    }else if(indexPath.section == 1){
        cell.textLabel.text = [_soundManager.backgroundArray objectAtIndex:indexPath.row];
    }else{
        cell.textLabel.text = @"停止播放";
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * soundName = nil;
    if (indexPath.section == 0) {
        soundName = [_soundManager.soundsArray objectAtIndex:indexPath.row];
    }else if(indexPath.section == 1){
        soundName = [_soundManager.backgroundArray objectAtIndex:indexPath.row];
    }else {
        [_soundManager stop];
    }
    
    if (soundName) {
        [_soundManager playSoundWithFileName:soundName];
    }
}

@end
