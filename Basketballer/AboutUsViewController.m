//
//  AboutUsViewController.m
//  Basketballer
//
//  Created by maoyu on 12-10-22.
//
//

#import "AboutUsViewController.h"
#import "AppDelegate.h"
#import "Feature.h"

@interface AboutUsViewController () {
    NSArray * _array;
    NSArray * _arrayNumber;
}

@end

@implementation AboutUsViewController

- (void)initArray {
    _array = [[NSArray alloc] initWithObjects:@"勤快的天蓬",@"毛_宇",nil];
    _arrayNumber = [[NSArray alloc] initWithObjects:@"iharbor",@"1733875695",nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LocalString(@"AboutUs");
    [self initArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [_array objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"weibo"];
    
    NSString * url = @"http://weibo.com/";
    url = [url stringByAppendingString:[_arrayNumber objectAtIndex:indexPath.row]];
    cell.detailTextLabel.text = url;
    
    return cell;
}

#pragma TableView的处理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
