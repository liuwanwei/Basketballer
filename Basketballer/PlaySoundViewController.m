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

- (IBAction)back:(id)sender {
//    [[AppDelegate delegate].playGameViewController dismissModalViewControllerAnimated:YES];
    [[AppDelegate delegate].playGameViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)initNavitem {
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back:)];
    
    self.navigationItem.leftBarButtonItem = item;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _soundManager = [SoundManager defaultManager];
    self.title = LocalString(@"SoundEffect");
    [self initNavitem];
    //[_cancelButton setTitle:LocalString(@"Cancel") forState:UIControlStateNormal];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _soundManager.soundsArray.count;
    }else {
        return _soundManager.backgroundArray.count;
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
    }else {
        cell.textLabel.text = [_soundManager.backgroundArray objectAtIndex:indexPath.row];
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * soundName = nil;
    if (indexPath.section == 0) {
        soundName = [_soundManager.soundsArray objectAtIndex:indexPath.row];
    }else {
        soundName = [_soundManager.backgroundArray objectAtIndex:indexPath.row];
    }
    
    [_soundManager playSoundWithFileName:soundName];
    [self back:nil];
}

@end
