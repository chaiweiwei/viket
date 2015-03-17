#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>      //导入视频播放库
#import "PlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

#pragma mark -
#pragma mark Compiler Directives & Static Variables

@implementation PlayViewController

@synthesize movieURL;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    loadingAni = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(140, 150, 37, 37)];
    loadingAni.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.view addSubview:loadingAni];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(130, 190, 80, 40)];
    label.text = @"加载中...";
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    
    [[self view] setBackgroundColor:[UIColor blackColor]];
    
    [loadingAni startAnimating];
    [self.view addSubview:label];
    
   // NSString *str = [[NSBundle mainBundle] pathForResource:@"03" ofType:@"mp4"];
//    self.movieURL = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
//    [self readyPlayer];
}


- (void) moviePlayerLoadStateChanged:(NSNotification*)notification
{
    [loadingAni stopAnimating];
    [label removeFromSuperview];
    
    // Unless state is unknown, start playback
    if ([mp loadState] != MPMovieLoadStateUnknown)
    {
        // Remove observer
        [[NSNotificationCenter     defaultCenter] removeObserver:self
                                                            name:MPMoviePlayerLoadStateDidChangeNotification
                                                          object:nil];
        
        // When tapping movie, status bar will appear, it shows up
        // in portrait mode by default. Set orientation to landscape
        //设置横屏
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
        // Rotate the view for landscape playback
        [[self view] setBounds:CGRectMake(0, 0, 480, 320)];
        [[self view] setCenter:CGPointMake(160, 240)];
        //选中当前view
        [[self view] setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
        
        // Set frame of movieplayer
        [[mp view] setFrame:CGRectMake(0, 0, 480, 320)];
        
        // Add movie player as subview
        [[self view] addSubview:[mp view]];
        
        // Play the movie
        [mp play];
    }
}


- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    //还原状态栏为默认状态
    //[mp playbackState);
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    // Remove observer
    [[NSNotificationCenter     defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [mp stop];
}
//隐藏状态栏
-(BOOL)prefersStatusBarHidden
{
    return YES;
}
- (void) readyPlayer
{
    mp =  [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if ([mp respondsToSelector:@selector(loadState)])
    {
        // Set movie player layout
        [mp setControlStyle:MPMovieControlStyleFullscreen];        //MPMovieControlStyleFullscreen        //MPMovieControlStyleEmbedded
        //满屏
        //[mp setFullscreen:YES];
        mp.fullscreen = YES;
        // 有助于减少延迟
        [mp prepareToPlay];
        
        // Register that the load state changed (movie is ready)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerLoadStateChanged:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:nil];
        

    }
    else
    {
        // Play the movie For 3.1.x devices
        [mp play];
    }
    
     //Register to receive a notification when the movie has finished playing.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
}

-(UIImage *)getPreViewImg:(NSString *)url

{
    
    NSLog(@"url ---- %@",url);
    
    NSURL *urlvideo = nil;
    
    
    
    if([url hasPrefix:@"assets-library:"] ) {
        
        urlvideo = [NSURL URLWithString:url];
        
    }else{
        
        urlvideo = [[NSURL alloc] initFileURLWithPath:url];
        
    }
    
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:urlvideo options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 500);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *img = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    //    [self performSelector:@selector(saveImg:) withObject:img afterDelay:0.1];
    
    return img;
    
}
@end
