//
//  UserListViewController.m
//  Zenithzone
//  学员列表
//  Created by alidao on 14-11-12.
//  Copyright (c) 2014年 skk. All rights reserved.
//

#import "BaseUserListViewController.h"
#import "PullingRefreshTableView.h"
#import "BasicsHttpClient.h"
#import "ALDImageView.h"
#import "EmbedButton.h"
#import "UserBean.h"

//#import "MyViewController.h"
//#import "InformationViewController.h"

@interface BaseUserListViewController ()<UITableViewDataSource,UITableViewDelegate,PullingRefreshTableViewDelegate,DataLoadStateDelegate,ALDDataChangedDelegate>

@end

@implementation BaseUserListViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.hidesBottomBarWhenPushed){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCustomTabBar" object:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    page=1;
    pageCount=20;
    hasNext=NO;
    bRefreshing=NO;
    
    CGRect frame=self.view.frame;
    CGFloat viewWidth=CGRectGetWidth(frame);
    CGFloat viewHeigh=CGRectGetHeight(frame);
    
    PullingRefreshTableView *pullTableView=[[PullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeigh) style:UITableViewStylePlain pullingDelegate:self];
    pullTableView.dataSource=self;
    pullTableView.delegate=self;
    pullTableView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    pullTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    pullTableView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:pullTableView];
    self.pullTableView=pullTableView;
    
    [self loadData];
    if(self.type==2){ //粉丝列表标记为已读
        BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
//        [httpClient hasReadNewFans];
    }
    // Do any additional setup after loading the view.
}

-(void)loadData
{
    BasicsHttpClient *httpClient=[BasicsHttpClient httpClientWithDelegate:self];
    if(self.type==1){
        [httpClient queryApplyMembers:self.sid page:page pageCount:pageCount];
    }else if(self.type==2){
        NSString *uid=[[NSUserDefaults standardUserDefaults] objectForKey:kUidKey];
        NSString *ltId=nil;
        if(page>1 && self.tableData && self.tableData.count>0){
            UserBean *bean=[self.tableData lastObject];
//            ltId=bean.followerId;
        }
//        [httpClient queryFans:uid ltId:ltId];
        [httpClient queryMyFans:page pageCount:pageCount];
    }else if(self.type==3){
        [httpClient queryMyAttentions:page pageCount:pageCount];
    }
    bRefreshing=NO;
}

-(void)scrollLoadData
{
    if(bRefreshing){
        page=1;
    }else{
        page++;
    }
    [self loadData];
}

-(void)dataChangedFrom:(id)from widthSource:(id)source byOpt:(int)opt
{
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCell=@"userListCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:strCell];
    CGFloat cellWidth=CGRectGetWidth(self.view.frame);
    
    if(cell==nil){
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
        
        CGFloat startX=10.0f;
        ALDImageView *imgView=[[ALDImageView alloc] initWithFrame:CGRectMake(startX, 12, 40, 40)];
        imgView.tag=0x11;
        imgView.defaultImage=[UIImage imageNamed:@"user_default"];
        imgView.layer.masksToBounds=YES;
        imgView.layer.cornerRadius=20.0f;
        imgView.autoResize=NO;
        imgView.fitImageToSize=NO;
        imgView.backgroundColor=[UIColor clearColor];
        [cell addSubview:imgView];
        startX+=50.0f;
        
        //名称
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(startX, 12, 200, 20.0f)];
        label.tag=0x12;
        label.textColor=KWordBlackColor;
        label.textAlignment=TEXT_ALIGN_LEFT;
        label.font=[UIFont systemFontOfSize:16.0f];
        label.backgroundColor=[UIColor clearColor];
        [cell addSubview:label];
        
        //职位
        label=[[UILabel alloc] initWithFrame:CGRectMake(startX, 12, cellWidth-startX-10, 20.0f)];
        label.tag=0x13;
        label.textColor=KWordBlackColor;
        label.textAlignment=TEXT_ALIGN_LEFT;
        label.font=[UIFont systemFontOfSize:12.0f];
        label.backgroundColor=[UIColor clearColor];
        [cell addSubview:label];
        
        //公司
        label=[[UILabel alloc] initWithFrame:CGRectMake(startX, 32, cellWidth-startX-10-50, 20.0f)];
        label.tag=0x14;
        label.textColor=KWordGrayColor;
        label.textAlignment=TEXT_ALIGN_LEFT;
        label.font=[UIFont systemFontOfSize:14.0f];
        label.backgroundColor=[UIColor clearColor];
        [cell addSubview:label];
        
        //是否关注
        EmbedButton *btn=[self createBtn:CGRectMake(cellWidth-10-50, (cellHeight-50)/2, 50, 50) icon:[UIImage imageNamed:@"bt_guanzhu"]];
        btn.tag=0x15;
        [btn addTarget:self action:@selector(clickAble:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
    }
    
    UserBean *bean=[self.tableData objectAtIndex:indexPath.row];
    NSString *text=bean.userInfo.avatar;
    
    //头像
    ALDImageView *imgView=(ALDImageView *)[cell viewWithTag:0x11];
    text=text==nil?@"":text;
    imgView.imageUrl=text;
    
    //名称
    UILabel *label=(UILabel *)[cell viewWithTag:0x12];
    text=bean.username;
    text=text==nil?@"":text;
    label.text=text;
    CGSize size=[ALDUtils captureTextSizeWithText:text textWidth:100 font:label.font];
    if(size.width>200){
        size.width=200;
    }
    CGRect subFrame=label.frame;
    subFrame.size.width=size.width;
    label.frame=subFrame;
    
    CGFloat startX=subFrame.origin.x+subFrame.size.width+10;
    //职位
    label=(UILabel *)[cell viewWithTag:0x13];
    subFrame.origin.x=startX;
    subFrame.size.width=cellWidth-startX-10;
    label.frame=subFrame;
    text=bean.userInfo.position;
    text=text==nil?@"":text;
    label.text=text;
    
    //公司
    label=(UILabel *)[cell viewWithTag:0x14];
    text=bean.userInfo.company;
    text=text==nil?@"":text;
    label.text=text;
    
    //是否关注
    EmbedButton *btn=(EmbedButton *)[cell viewWithTag:0x15];
    btn.userInfo=[NSDictionary dictionaryWithObject:bean forKey:@"data"];
    NSString *uid=[[NSUserDefaults standardUserDefaults] objectForKey:kUidKey];
    if([bean.uid isEqualToString:uid]){
        btn.hidden=YES;
    }else{
        btn.hidden=NO;
//        if([bean.following boolValue]){
//            [btn setButtonBgImage:[UIImage imageNamed:@"bt_yiguanzhu"]];
//        }else{
//            [btn setButtonBgImage:[UIImage imageNamed:@"bt_guanzhu"]];
//        }
    }
    
    return cell;
}

-(void)clickAble:(ALDImageView *)sender
{
    UserBean *userBean=[sender.userInfo objectForKey:@"data"];
    self.selectBean=userBean;
//    BOOL isAttente=[userBean.following boolValue];
//    HttpClient *httpClient=[HttpClient httpClientWithDelegate:self];
//    int opt=1;
//    if(isAttente){
//        opt=-1;
//    }
//    [httpClient attentionOpt:userBean.uid opt:opt];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pullTableView tableViewDidScroll:scrollView];
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.pullTableView tableViewDidEndDragging:scrollView];
}

#pragma mark - PullingRefreshTableViewDelegate
-(void) pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView
{
    bRefreshing = YES;
    [self performSelector:@selector(scrollLoadData) withObject:[NSNumber numberWithInt:1] afterDelay:1.f];
    
}

-(void) pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView
{
    [self performSelector:@selector(scrollLoadData) withObject:[NSNumber numberWithInt:1] afterDelay:1.f];
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserBean *bean=[self.tableData objectAtIndex:indexPath.row];
    NSString *uid=[[NSUserDefaults standardUserDefaults] objectForKey:kUidKey];
    /*
    if([bean.sid longValue]==[uid longValue]){
        MyViewController *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"MyViewController"];
        controller.title=@"我的";
        controller.hidesBottomBarWhenPushed=YES;
        UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
        self.navigationItem.backBarButtonItem = backBtnItem;
        [self.navigationController pushViewController:controller animated:YES];
        
    }else{
        InformationViewController *controller=[self.storyboard instantiateViewControllerWithIdentifier:@"InformationViewController"];
        controller.title=@"个人信息";
        controller.currentBean=bean;
        UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:nil action:nil];
        self.navigationItem.backBarButtonItem = backBtnItem;
        [self.navigationController pushViewController:controller animated:YES];
    }
     */
}

-(EmbedButton *)createBtn:(CGRect) frame icon:(UIImage *)icon
{
    EmbedButton *btn=[EmbedButton buttonWithType:UIButtonTypeCustom];
    btn.frame=frame;
    btn.isCenter=YES;
    btn.edgeState=KEdgeInsetNo;
    [btn setButtonBgImage:icon];
    btn.backgroundColor=[UIColor clearColor];
    
    return btn;
}

-(void)dataStartLoad:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath
{
    if(requestPath==HttpRequestPathForApplyMembers || requestPath==HttpRequestPathForMyFans || requestPath==HttpRequestPathForMyAttentions){
        [ALDUtils addWaitingView:self.view withText:@"加载中,请稍候..."];
    }
}

-(void)dataLoadDone:(ALDHttpClient *)httpClient requestPath:(HttpRequestPath)requestPath withCode:(NSInteger)code withObj:(ALDResult *)result
{
    
    if(requestPath==HttpRequestPathForApplyMembers || requestPath==HttpRequestPathForMyFans || requestPath==HttpRequestPathForMyAttentions){
         [ALDUtils hiddenTips:self.view];
        if(code==KOK){
            id obj=result.obj;
            if([obj isKindOfClass:[NSArray class]]){
                NSArray *array=(NSArray *)obj;
                if(page==1){
                    self.tableData=[NSMutableArray arrayWithArray:array];
                }else{
                    [self.tableData addObjectsFromArray:array];
                }
                hasNext = result.hasNext;
                if (!hasNext){
                    [_pullTableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
                    _pullTableView.reachedTheEnd = YES;
                }else{
                    [_pullTableView tableViewDidFinishedLoading];
                    _pullTableView.reachedTheEnd = NO;
                }
                self.pullTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
                [_pullTableView reloadData];
            }
        }else {
            NSString *errMsg=result.errorMsg;
            hasNext = NO;
            if(page>1)
                page--;
            if(code==kNO_RESULT){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    if(requestPath==HttpRequestPathForApplyMembers){
                        errMsg=@"暂无报名人员!";
                    }else{
                        errMsg=@"暂无粉丝!";
                    }
                }
            }else if(code==kNET_ERROR || code==kNET_TIMEOUT){
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"网络连接失败,请检查网络设置!";
                }
            }else{
                if(!errMsg || [errMsg isEqualToString:@""]){
                    errMsg=@"抱歉，获取数据失败!";
                }
            }
            if (!self.tableData || self.tableData.count < 1){
                [ALDUtils showTips:self.view text:errMsg];
            }else{
                [_pullTableView tableViewDidFinishedLoadingWithMessage:@"没有啦，加载完了！"];
                _pullTableView.reachedTheEnd = YES;
            }
            [_pullTableView tableViewDidFinishedLoading];
            [_pullTableView reloadData];
        }
    }/*else if(requestPath==HttpRequestPathForReadFans){
        if(code==1){
            if(_dataChangedDelegate && [_dataChangedDelegate respondsToSelector:@selector(dataChangedFrom:widthSource:byOpt:)]){
                [_dataChangedDelegate dataChangedFrom:self widthSource:nil byOpt:2];
            }
        }else{
            
        }
    }else if(requestPath==HttpRequestPathForAttentionOpt){
        if(code==KOK){
            BOOL isAttente=[self.selectBean.following boolValue];
            if(isAttente){
                self.selectBean.following=[NSNumber numberWithInt:0];
            }else{
                self.selectBean.following=[NSNumber numberWithInt:1];
            }
//            NSDictionary *dic=[NSDictionary dictionaryWithObject:self.selectBean forKey:@"data"];
//            [[NSNotificationCenter defaultCenter] postNotificationName:KAttentionOpt object:nil userInfo:dic];
            int i=0;
            for(UserBean *bean in self.tableData){
                if([bean.uid isEqualToString:self.selectBean.uid]){
                    bean.following=self.selectBean.following;
                    [self.tableData replaceObjectAtIndex:i withObject:bean];
                    break;
                }
                i++;
            }
            [self.pullTableView reloadData];
        }else{
            
        }
    }*/

    [ALDUtils removeWaitingView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.sid=nil;
    self.pullTableView=nil;
    self.tableData=nil;
    self.selectBean=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
