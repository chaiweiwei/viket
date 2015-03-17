//
//  CustomTabBar.m
//  why
//
//  Created by aaa a on 11-4-6.
//  Copyright (c) 2011年 qw. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CustomTabBar.h"
#import "AppDelegate.h"
#import "ItemsLayout.h"

@interface CustomTabBar (){
    BOOL _isTabbarLoaded;
}

@property (retain,nonatomic) NSArray *tabItems;
@property (retain,nonatomic) UIImageView *imgView;


@end

@implementation CustomTabBar
#define TAG_OFFSET 1000
#define kNewFlagTag 0x201

@synthesize titles=_titles, icons=_icons;
@synthesize selectedIcons=_selectedIcons;
@synthesize tabItems=_tabItems;
@synthesize imgView=_imgView;
@synthesize tabbarView=_tabbarView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    CGRect frame=self.view.bounds;
    CGFloat tabHeight=self.tabBar.frame.size.height;
    CGRect tabFrame=CGRectMake(0, frame.size.height-tabHeight, frame.size.width, tabHeight);
    UIView *tabView=[[UIView alloc] initWithFrame:tabFrame];
    tabView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    tabView.backgroundColor=[UIColor clearColor];
    self.tabbarView=tabView;
    [self.view addSubview:tabView];
    ALDRelease(tabView);
    [self customTabBar];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideCustomTabBar)
                                                 name: @"hideCustomTabBar"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bringCustomTabBarToFront)
                                                 name: @"bringCustomTabBarToFront"
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPreTabItem)
                                                 name: @"showPreTabItem"
                                               object: nil];
}

-(void) hasNotify{
    
}

-(void) showPreTabItem{
    if (self.preSelectedIndex>=0 && self.preSelectedIndex<self.icons.count && (self.selectedIndex==3 || self.selectedIndex==2)) {
        [self changedTab:self.preSelectedIndex];
    }
}

-(void) reSetView{
    if (_tabbarView!=nil) {
        [self customTabBar];
    }
}

-(void) setBarItems:(NSArray*) items{
    if (!items) {
        return;
    }
    self.tabItems=items;
    NSMutableArray *tabItems=[NSMutableArray array];
    NSMutableArray *icons=[NSMutableArray array];
    NSMutableArray *selectedIcons=[NSMutableArray array];
    for (ItemsLayout *item in items) {
        NSAssert([item isKindOfClass:[ItemsLayout class]],@"The TabViewLayout array number of Items must be type of ItemsLayout");
        NSString *title=[item title];
        if (title) {
            [tabItems addObject:item];
        }
        NSString *icon=[item normalIcon];
        NSAssert(icon!=nil,@"The normal icon of ItemsLayout can't be null");
        [icons addObject:icon];
        NSString *selected=[item selectedIcon];
        if (!selected) {
            selected=icon;
        }
        [selectedIcons addObject:selected];
    }
    self.titles=tabItems;
    self.icons=icons;
    self.selectedIcons=selectedIcons;
    [self reSetView];
}

-(void) viewDidLayoutSubviews{
    if (!self.tabBar.hidden) {
        self.tabBar.hidden=YES;
    }
}

//将自定义的tabbar显示出来
- (void)bringCustomTabBarToFront{
    if (_tabbarView.hidden) {
        [_tabbarView setHidden:NO];
    }
}

//隐藏自定义tabbar
- (void)hideCustomTabBar{
    [_tabbarView setHidden:YES];
}

- (void)customTabBar{
    if (!self.icons || self.icons.count<1) {
        return;
    }
    NSArray *views=_tabbarView.subviews;
    for (UIView *subView in views) {
        [subView removeFromSuperview];
    }
    NSAssert(_icons.count==self.selectedIcons.count, @"The icons count must equals to selectedIcons count");
    
    CGRect tabFrame=_tabbarView.frame;
    UIImageView *imgView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"bg_TabBar"]];
	imgView.frame =CGRectMake(0, 0, tabFrame.size.width, tabFrame.size.height);
	[_tabbarView addSubview:imgView];
    self.imgView=imgView;
	ALDRelease(imgView);
	
    
	double _width = tabFrame.size.width / _icons.count;
	double _height = 49;
	
	
	CGFloat startY=0;
	
    int idx=0;
	for (NSString *icon in _icons) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(_width*idx, startY, _width, _height+2);
        button.tag=TAG_OFFSET+idx;
//        [button setImage:[self getImageResource:icon] forState:UIControlStateNormal];
//        UIImage *selImage=[self getImageResource:[_selectedIcons objectAtIndex:idx]];
        [button setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
        UIImage *selImage=[UIImage imageNamed:[_selectedIcons objectAtIndex:idx]];
        [button setImage:selImage forState:UIControlStateHighlighted];
        [button setImage:selImage forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
        [_tabbarView addSubview:button];
        idx++;
    }

    [self changedTab:self.selectedIndex];
//    [self changeNewSessionState];
    _isTabbarLoaded=YES;
}
/*
-(UIImage*) getImageResource:(NSString*) imagePath{
    NSString *bgImage=nil;
    NSUserDefaults *config=[NSUserDefaults standardUserDefaults];
    NSString *netConfig=[config objectForKey:kLayoutFilePathKey];
    if (netConfig && ![netConfig isEqualToString:@""]) {
        NSString *path=[[config objectForKey:kConfigFilesPathKey] stringByAppendingPathComponent:imagePath];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:path]){
            bgImage=path;
        }else{
            bgImage=imagePath;
        }
    }else{
        bgImage=imagePath;
    }
    
    UIImage *resultImage=nil;
    if([bgImage hasPrefix:@"file://"]||[bgImage hasPrefix:@"/"]){
        resultImage=[UIImage imageWithContentsOfFile:bgImage];
    }else if(bgImage && ![bgImage isEqualToString:@""]){
        resultImage=[UIImage imageNamed:bgImage];
    }
    return resultImage;
}*/

- (void)changedTab:(NSInteger) selectIndx{
    NSInteger currIndex=self.selectedIndex;
    //BOOL fromLeft=NO;
    if (selectIndx==NSNotFound) {
        selectIndx=0;
    }
    if (currIndex==selectIndx && _isTabbarLoaded) {
        return;
    }
    self.preSelectedIndex=currIndex;
    self.selectedIndex=selectIndx;
    
    NSInteger count=_icons.count;
    for (int i=0; i<count; i++) {
        UIButton *button=(UIButton*)[_tabbarView viewWithTag:(TAG_OFFSET+i)];
        if (selectIndx==i) {
            [button setSelected:YES];
        }else {
            [button setSelected:NO];
        }
    }
}

-(UIButton*) findViewControllerButton:(Class) clazz{
    NSArray *viewCtrols=[self viewControllers];
    NSInteger count=viewCtrols.count;
    NSInteger findIndex=NSNotFound;
    for (int i=0; i<count; i++) {
        UIViewController *controller=[viewCtrols objectAtIndex:i];
        if ([controller isKindOfClass:[UINavigationController class]]) {
            controller=((UINavigationController*)controller).topViewController;
            if (![controller isKindOfClass:clazz]) {
                findIndex=i;
                break;
            }
        }else if ([controller isKindOfClass:[UITabBarController class]]){
            NSArray *topControllers=((UITabBarController*)controller).viewControllers;
            for (int j=0; j<topControllers.count; j++) {
                UIViewController *topController=[topControllers objectAtIndex:i];
                if ([topController isKindOfClass:[UINavigationController class]]) {
                    topController=((UINavigationController*)topController).topViewController;
                    if (![topController isKindOfClass:clazz]) {
                        findIndex=i;
                        break;
                    }
                }else{
                    if (![topController isKindOfClass:clazz]) {
                        findIndex=i;
                        break;
                    }
                }
            }
        }else{
            if (![controller isKindOfClass:clazz]) {
                findIndex=i;
                break;
            }
        }
        if (findIndex!=NSNotFound) {
            break;
        }
    }
    if (findIndex!=NSNotFound) {
        return (UIButton*)[_tabbarView viewWithTag:(TAG_OFFSET+findIndex)];
    }
    return nil;
}

-(void) addNewToButton:(UIButton*)button{
    UIImageView *tagView=(UIImageView*)[button viewWithTag:kNewFlagTag];
    UILabel *textLa=nil;
    if (!tagView) {
        tagView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_mass.png"]];
        tagView.frame=CGRectMake(50,-6,30, 25);
        tagView.tag=kNewFlagTag;
        
        textLa=[[UILabel alloc] initWithFrame:CGRectMake(0,0,30, 25)];
        textLa.highlighted = YES;      
        textLa.textColor=[UIColor whiteColor];
        textLa.font=[UIFont systemFontOfSize:10.0];
        textLa. textAlignment=TEXT_ALIGN_CENTER;
        textLa.adjustsFontSizeToFitWidth =  YES ;         
        textLa.numberOfLines = 1;    
        textLa.enabled =  YES;      
        textLa.backgroundColor=[UIColor clearColor];
        textLa.tag=11;
        textLa.text=@"new";
        
        [tagView addSubview:textLa];
        ALDRelease(textLa);
        [button addSubview:tagView];
        ALDRelease(tagView);
    }else {
        tagView.hidden=NO;
        textLa=(UILabel*)[tagView viewWithTag:11];
        textLa.text=@"new";
    }
}

-(void) removeNewOfButton:(UIButton*) button{
    UIImageView *tagView=(UIImageView*)[button viewWithTag:kNewFlagTag];
    if (tagView) {
        [tagView removeFromSuperview];
    }
}

- (void)selectedTab:(UIButton *)button{
    NSInteger selectIndx=button.tag-TAG_OFFSET;
    [self changedTab:selectIndx];	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.imgView=nil;
    self.tabbarView=nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.titles=nil;
    self.icons=nil;
    self.selectedIcons=nil;
	self.imgView=nil;
    self.tabbarView=nil;
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
