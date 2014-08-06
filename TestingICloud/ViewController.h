//
//  ViewController.h
//  TestingICloud
//
//  Created by John Malloy on 7/28/14.
//  Copyright (c) 2014 BigRedINC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyDocument.h"

@interface ViewController : UIViewController <MyDocumentDelegate>



@property (weak, nonatomic) IBOutlet UISegmentedControl *fontSizeSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextView *documentTextView;
@property (strong, nonatomic) NSUbiquitousKeyValueStore * iCloudKeyValueStore;
@property (strong, nonatomic) NSUserDefaults * userDefaults;
@property (strong, nonatomic) MyDocument * document;
@property (strong, nonatomic) NSURL * documentURL;

- (IBAction)updateTextSize:(id)sender;
- (IBAction)saveDocument:(id)sender;
@end
