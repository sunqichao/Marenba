//
//  MainViewController.m
//  Marenba
//
//  Created by sun qichao on 14-2-8.
//  Copyright (c) 2014年 sun qichao. All rights reserved.
//

#import "MainViewController.h"
#import "VoiceCell.h"
#import "ViewController.h"
#import "MJRefresh.h"

@interface MainViewController ()<MJRefreshBaseViewDelegate>
@property (strong, nonatomic) LCVoice *voice;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) ViewController *startViewController;
@property (strong, nonatomic) MJRefreshHeaderView *refreshHeader;
@property (strong, nonatomic) MJRefreshFooterView *refreshFooter;
@property (assign, nonatomic) int myPage;
@property (assign, nonatomic) int otherPage;
@end

@implementation MainViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.voice = [[LCVoice alloc] init];
        self.dataSource = [[NSMutableArray alloc] init];
        _myPage = 0;
        _otherPage = 0;
        //初始化player  没有创建session不能播放
        NSError *setCategoryError = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
        UInt32 route = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(route), &route);
        self.player = [[AVAudioPlayer alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self addHidenDetailViewNotification];
    [self addHidenStartViewNotification];
    [self addHeaderAndFooter];
    
    //判断是否是第一次登录
    if ([SQCAPI isFirstLogin]) {
        [SQCAPI getCurrentUserName];

        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        self.startViewController = [story instantiateViewControllerWithIdentifier:@"startViewController"];
        
        [self.view addSubview:_startViewController.view];
    }else
    {
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getOtherData];
}

- (void)addHeaderAndFooter
{
    //添加下拉刷新
    _refreshHeader = [[MJRefreshHeaderView alloc] init];
    _refreshHeader.delegate = self;
    _refreshHeader.scrollView = self.mainTableView;
    
    //添加上拉加载更多
    _refreshFooter = [[MJRefreshFooterView alloc] init];
    _refreshFooter.delegate = self;
    _refreshFooter.scrollView = self.mainTableView;
}

#pragma mark 代理方法-进入刷新状态就会调用
- (void)refreshViewBeginRefreshing :(MJRefreshBaseView *)refreshView
{
    
    if (_refreshHeader == refreshView) {
        DLog(@"refresh header");
        [self accordingToSegment];
        [self reSetPageCount];
        
    } else {
        DLog(@"refresh footer");
        [self accordingToSegment];
        [self addPageCount];
    }

}

#pragma mark - 重置页数

- (void)reSetPageCount
{
    _myPage=0;
    _otherPage=0;
}

- (void)addPageCount
{
    if (_segment.selectedSegmentIndex==0) {
        _myPage++;
    }else
    {
        _otherPage++;
    }
}

#pragma mark - 隐藏开始启动界面

- (void)addHidenStartViewNotification
{
    [NSNotificationCenter.defaultCenter addObserverForName:@"HidenStartViewNotification"
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *note)
     {
         DLog(@"HidenStartViewNotification ********");
         
         dispatch_async(dispatch_get_main_queue(), ^{
             _startViewController.view.hidden = YES;    //隐藏开始界面
             
         });
         
         
     }];
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"HidenStartViewNotification" object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)accordingToSegment
{
    DLog(@"accordingToSegment");
    if (_segment.selectedSegmentIndex==0) {
        [self getMyData];
    }else
    {
        [self getOtherData];
    }
}

- (void)getOtherData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.dataSource = [SQCAPI getCafList:_myPage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainTableView reloadData];
            [_refreshHeader endRefreshing];
            [_refreshFooter endRefreshing];
        });
    });
}

- (void)getMyData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.dataSource = [SQCAPI getCurrentUserCafList:_otherPage];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mainTableView reloadData];
            [_refreshHeader endRefreshing];
            [_refreshFooter endRefreshing];
        });
    });
}

#pragma mark - 切换骂人列表

- (IBAction)SegmentChange:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    switch (segment.selectedSegmentIndex) {

        case 0:
        {
            DLog(@"我骂别人。");
            [self getMyData];
            [self reSetPageCount];

        }
            break;

        case 1:
        {
            DLog(@"别人骂别人。");
            [self getOtherData];
            [self reSetPageCount];

        }
            break;
            
        default:
            break;
    }
    
}


#pragma mark - 点击cell播放

- (void)addHidenDetailViewNotification
{
    [NSNotificationCenter.defaultCenter addObserverForName:@"PlayCellVoiceotification"
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *note)
     {
         DLog(@"PlayCellVoiceotification ********");
         
         dispatch_async(dispatch_get_main_queue(), ^{
             PFObject *object = [note object];
             NSData *cafData = [SQCAPI getCafDataFormParseObject:object];
             self.player = [_player initWithData:cafData error:nil];
             [self.player prepareToPlay];
             [self.player play];
             
         });
         
         
     }];
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayCellVoiceotification" object:nil];
    
}

#pragma mark - 开始骂人的几个步骤

- (IBAction)start:(id)sender {
    [self.voice startRecordWithPath:DefaultCafPath];
    
}

- (IBAction)touchEnd:(id)sender {
    [self.voice stopRecordWithCompletionBlock:^{
        
        if (self.voice.recordTime > 0.1f) {
            DLog(@"save succeed");
            [SVProgressHUD showSuccessWithStatus:@"我靠，发送成功。" duration:2.0];
            
            [SQCAPI saveTheVoiceToParse:DefaultCafPath withTime:self.voice.recordTime done:^(BOOL isRight) {
                [self reSetPageCount];
                [self accordingToSegment];
                
            }];

        }
        
    }];
}

- (IBAction)touchCancel:(id)sender {
    [SVProgressHUD showSuccessWithStatus:@"我日，取消了。" duration:1.0];

    [self.voice cancelled];

}

#pragma mark - uitableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VoiceCell";
    
    VoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *object = [_dataSource objectAtIndex:indexPath.row];
    cell.selectObject = object;
    cell.nameLabel.text = [NSString stringWithFormat:@"%@",object[@"name"]];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@",object[@"voiceTime"]];
    // Configure the cell...
    return cell;
    

}




@end
