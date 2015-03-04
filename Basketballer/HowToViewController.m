//
//  HowToViewControllerTableViewController.m
//  Basketballer
//
//  Created by sungeo on 15/3/3.
//
//

#import "HowToViewController.h"
#import <Masonry.h>

@interface HowToViewController ()

@property (nonatomic, strong) NSArray * howTos;

@end

@implementation HowToViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"使用说明";
    
    self.howTos = @[@[@"1", @"111"],
                    @[@"2", @"222"],
                    @[@"3", @"333"],
                    @[@"4", @"444"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.howTos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * sIdentifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = self.howTos[indexPath.row][0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HowToDetailsViewController * vc = [[HowToDetailsViewController alloc] init];
    vc.text = self.howTos[indexPath.row][1];
    [self.navigationController pushViewController:vc animated:YES];
}


@end

@implementation HowToDetailsViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    __weak UIView * superview = self.view;
    
    UITextView * textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:17.0f];
    [self.view addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker * make){
        make.size.equalTo(superview);
        make.center.equalTo(superview);
    }];
    
    textView.text = self.text;
    
}

@end
