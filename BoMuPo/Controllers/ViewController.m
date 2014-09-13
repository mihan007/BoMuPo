//
//  ViewController.m
//  BoMuPo
//
//  Created by Mikhail Kuklin on 9/13/14
//  Copyright (c) 2014 Mikhail Kuklin. All rights reserved.
//

#import "ViewController.h"
#import "GVMusicPlayerController.h"
#import "NSString+TimeToString.h"

#define kCurrentAudiobookProgressSetting @"currentAudiobookProgressSetting"

enum availablePlayingMode {
    modeStart,
    modeSongs,
    modeAudiobook
};

@interface ViewController () <GVMusicPlayerControllerDelegate, MPMediaPickerControllerDelegate>

@property(strong, nonatomic) IBOutlet UIView *chooseView;
@property(strong, nonatomic) IBOutlet UILabel *songLabel;
@property(strong, nonatomic) IBOutlet UILabel *artistLabel;
@property(strong, nonatomic) IBOutlet UILabel *trackLengthLabel;
@property(strong, nonatomic) IBOutlet UIImageView *imageView;
@property(strong, nonatomic) IBOutlet UILabel *trackCurrentPlaybackTimeLabel;
@property(strong, nonatomic) IBOutlet UISlider *progressSlider;
@property(strong, nonatomic) IBOutlet UIButton *playButton;
@property(strong, nonatomic) IBOutlet UIButton *songsBookButton;

@property NSTimeInterval currentAudiobookProgress;
@property enum availablePlayingMode currentMode;
@property BOOL panningProgress;
@property(strong, nonatomic) NSTimer *timer;

@end


@implementation ViewController

#pragma mark - ViewController LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view bringSubviewToFront:self.chooseView];
    self.currentAudiobookProgress = [self getCurrentAudioBookProgress];
    self.currentMode = modeStart;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timedJob) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)viewWillAppear:(BOOL)animated {
    // NOTE: add and remove the GVMusicPlayerController delegate in
    // the viewWillAppear / viewDidDisappear methods, not in the
    // viewDidLoad / viewDidUnload methods - it will result in dangling
    // objects in memory.
    [super viewWillAppear:animated];
    [[GVMusicPlayerController sharedInstance] addDelegate:self];
    [self adjustPlaybackButton];
    [self adjustSongsBookButton];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[GVMusicPlayerController sharedInstance] removeDelegate:self];
    [super viewDidDisappear:animated];
}

- (void)timedJob {
    if (self.panningProgress) {
        return;
    }

    NSTimeInterval currentPlaybackTime = [GVMusicPlayerController sharedInstance].currentPlaybackTime;
    self.progressSlider.value = (float) currentPlaybackTime;
    self.trackCurrentPlaybackTimeLabel.text = [NSString stringFromTime:currentPlaybackTime];
    if (self.currentMode == modeAudiobook) {
        self.currentAudiobookProgress = currentPlaybackTime;
    }
    [self setCurrentAudioBookProgress:self.currentAudiobookProgress];
}


#pragma mark - Catch remote control events, forward to the music player

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    [[GVMusicPlayerController sharedInstance] remoteControlReceivedWithEvent:receivedEvent];
    [self adjustPlaybackButton];
}

#pragma mark - IBActions

- (void)playSongs {
    [GVMusicPlayerController sharedInstance].shuffleMode = MPMusicShuffleModeSongs;
    self.currentMode = modeSongs;
    [self adjustSongsBookButton];

#if !(TARGET_IPHONE_SIMULATOR)
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    [[GVMusicPlayerController sharedInstance] setQueueWithQuery:query];
    [[GVMusicPlayerController sharedInstance] play];
    [self adjustPlaybackButton];
#endif
}

- (void)playAudiobook {
    [GVMusicPlayerController sharedInstance].shuffleMode = MPMusicShuffleModeOff;
    self.currentMode = modeAudiobook;
    [self adjustSongsBookButton];

#if !(TARGET_IPHONE_SIMULATOR)
    MPMediaQuery *query = [MPMediaQuery audiobooksQuery];
    [[GVMusicPlayerController sharedInstance] setQueueWithQuery:query];
    [[GVMusicPlayerController sharedInstance] play];
    [GVMusicPlayerController sharedInstance].currentPlaybackTime = [self getCurrentAudioBookProgress];
    [self adjustPlaybackButton];
#endif
}

- (IBAction)play:(id)sender {
    switch (self.currentMode) {
        case modeStart:
            [self playAudiobook];
            break;
        case modeSongs:
            [self playAudiobook];
            break;
        case modeAudiobook:
            [self playSongs];
            break;
    }
}

- (IBAction)progressChanged:(UISlider *)sender {
    // While dragging the progress slider around, we change the time label,
    // but we're not actually changing the playback time yet.
    self.panningProgress = YES;
    self.trackCurrentPlaybackTimeLabel.text = [NSString stringFromTime:sender.value];
}

- (IBAction)progressEnd {
    // Only when dragging is done, we change the playback time.
    [GVMusicPlayerController sharedInstance].currentPlaybackTime = self.progressSlider.value;
    self.panningProgress = NO;
}

- (IBAction)playButtonPressed {
    if ([GVMusicPlayerController sharedInstance].playbackState == MPMusicPlaybackStatePlaying) {
        [[GVMusicPlayerController sharedInstance] pause];
    } else {
        if (self.currentMode == modeStart) {
            [self play:nil];
        } else {
            [[GVMusicPlayerController sharedInstance] play];
        }
    }

    [self adjustPlaybackButton];
}

#pragma mark - UI

- (void)adjustPlaybackButton {
    if ([GVMusicPlayerController sharedInstance].playbackState == MPMusicPlaybackStatePlaying) {
        [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    } else {
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (void)adjustSongsBookButton {
    switch (self.currentMode) {
        case modeStart:
            [self.songsBookButton setTitle:@"Слушать книгу" forState:UIControlStateNormal];
            break;
        case modeSongs:
            [self.songsBookButton setTitle:@"Слушать книгу" forState:UIControlStateNormal];
            break;
        case modeAudiobook:
            [self.songsBookButton setTitle:@"Петь музыку" forState:UIControlStateNormal];
            break;
    }
}

#pragma mark - AVMusicPlayerControllerDelegate

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer playbackStateChanged:(MPMusicPlaybackState)playbackState previousPlaybackState:(MPMusicPlaybackState)previousPlaybackState {

}

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer trackDidChange:(MPMediaItem *)nowPlayingItem previousTrack:(MPMediaItem *)previousTrack {

    // Time labels
    NSTimeInterval trackLength = [[nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    self.trackLengthLabel.text = [NSString stringFromTime:trackLength];
    self.progressSlider.value = (float) (self.currentMode == modeSongs ? 0 : [self getCurrentAudioBookProgress]);
    self.progressSlider.maximumValue = (float) trackLength;

    // Labels
    self.songLabel.text = [nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    self.artistLabel.text = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];

    // Artwork
    MPMediaItemArtwork *artwork = [nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
    if (artwork != nil) {
        self.imageView.image = [artwork imageWithSize:self.imageView.frame.size];
    }
}

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer endOfQueueReached:(MPMediaItem *)lastTrack {
    NSLog(@"End of queue, but last track was %@", [lastTrack valueForProperty:MPMediaItemPropertyTitle]);
}

- (void)musicPlayer:(GVMusicPlayerController *)musicPlayer volumeChanged:(float)volume {
}

#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    [[GVMusicPlayerController sharedInstance] setQueueWithItemCollection:mediaItemCollection];
    [[GVMusicPlayerController sharedInstance] play];
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AudioBook resume support

- (NSTimeInterval)getCurrentAudioBookProgress {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [userDefaults objectForKey:kCurrentAudiobookProgressSetting];
    if (result.length > 0) {
        return [result doubleValue];
    }
    return 0.0f;
}

- (void)setCurrentAudioBookProgress:(NSTimeInterval)currentProgress {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *result = [NSString stringWithFormat:@"%f", currentProgress];
    [userDefaults setObject:result forKey:kCurrentAudiobookProgressSetting];
    [userDefaults synchronize];
}

@end
