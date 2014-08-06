//
//  ViewController.m
//  TestingICloud
//
//  Created by John Malloy on 7/28/14.
//  Copyright (c) 2014 BigRedINC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


/*
    before you can test for iCloud integration,you must make sure the device is properly configured to work with iCloud. Go to "Settings" on the device, go to the iCloud section. For the application to store the data,your iCloud account must be properly configured and verified. This requires you to have verified your email address and rehistered it as your Apple ID. The Documents & Data item should also be set to ON
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //1 gets a reference to the key value store
    //2. Signs up for notifications when the data in the key-value store is changed by external source
    //3. Makes sure the key-value store sache is up-to-date by call synchronize
    //4. Updates the user interface with the values from the keyValueStore
    
    
    self.iCloudKeyValueStore = [NSUbiquitousKeyValueStore defaultStore];
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlesStoreChange:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:self.iCloudKeyValueStore];
    
    [self.iCloudKeyValueStore synchronize];
    [self updateUserInterfaceWithPreferences];
    
    /* Setting up the iCloud access directly in the main view controller,which is fine for this recipe. In an application with several view controllers you should set it up in the app delegate instead and distribute the reference to whichever device request it */
    
    [self updateDocument];

}


-(void)updateDocument
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    id iCloudToken = [fileManager ubiquityIdentityToken];
    if (iCloudToken)
    {
        //iCloud available
        
        //Register to notifications for changes in availability
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleICloudDidChangeIdentity:)
                                                     name:NSUbiquityIdentityDidChangeNotification
                                                   object:nil];
        
        //Open exisiting document or create new\
        //to avoid freezing the user interface,the following actions will be done on a different thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{ NSURL * documentContainer = [[fileManager URLForUbiquityContainerIdentifier:nil]
                                                       URLByAppendingPathComponent:@"Documents"];
                         if (documentContainer != nil)
                         {
                             self.documentURL = [documentContainer URLByAppendingPathComponent:@"mydocument.txt"];
                             self.document = [[MyDocument alloc] initWithFileURL:self.documentURL];
                             self.document.delegate = self;
                             //If this file exists, open it,otherwise create it
                             
                             if ([fileManager fileExistsAtPath:self.documentURL.path])
                                 [self.document openWithCompletionHandler:nil];
                             else
                                 [self.document saveToURL:self.documentURL
                                         forSaveOperation:UIDocumentSaveForCreating
                                        completionHandler:nil];
                        
                         }
                       });
    }
    else
    {
        //No iCloud Access
        self.documentURL = nil;
        self.document = nil;
        self.documentTextView.text = @"<NO iCloud Access";
    }
}

-(void)handleICloudDidChangeIdentity:(NSNotification *)notification
{
    NSLog(@"ID Changed");
    [self updateDocument];
}

-(void)documentDidChange:(MyDocument *)document
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       self.documentTextView.text = document.text;
                   });
}




-(void)handlesStoreChange:(NSNotification *)notification
{
    [self updateUserInterfaceWithPreferences];
}

-(void)updateUserInterfaceWithPreferences
{
//    NSInteger selectedSize = [self.iCloudKeyValueStore doubleForKey:@"TextSize"];
//    self.fontSizeSegmentedControl.selectedSegmentIndex = selectedSize;
//    [self updateTextSize:self];
    
    NSInteger selectedSize;
    if ([self.iCloudKeyValueStore objectForKey:@"TextSize"] != nil)
    {
        //iCloud Value exists
        selectedSize = [self.iCloudKeyValueStore doubleForKey:@"TextSize"];
        //Make sure the local cache is synced
        [self.userDefaults setDouble:selectedSize forKey:@"TextSize"];
        [self.userDefaults synchronize];
    }
    else
    {
        //iCloud NOT available, use the value from the local cache
        selectedSize = [self.userDefaults doubleForKey:@"TextSize"];
    }
    
    self.fontSizeSegmentedControl.selectedSegmentIndex = selectedSize;
    [self updateTextSize:self];
    
    
    //Now the app should persist it's size text preference, both with iCloud and without it
    
}



- (IBAction)updateTextSize:(id)sender
{
    CGFloat newFontSize;
    switch (self.fontSizeSegmentedControl.selectedSegmentIndex)
    {
        case 1:
            newFontSize = 19;
            break;
        case 2:
            newFontSize = 24;
            break;
        case 3:
            
        default:
            newFontSize = 14;
            break;
    }
    self.documentTextView.font = [UIFont systemFontOfSize:newFontSize];
    
    //Update preferences
    NSInteger selectedSize = self.fontSizeSegmentedControl.selectedSegmentIndex;
    [self.userDefaults setDouble:selectedSize forKey:@"TextSize"];
    [self.userDefaults synchronize];
    [self.iCloudKeyValueStore setDouble:selectedSize forKey:@"TextSize"];
}

- (IBAction)saveDocument:(id)sender
{
    if (self.document)
    {
        self.document.text = self.documentTextView.text;
        [self.document saveToURL:self.documentURL
                forSaveOperation:UIDocumentSaveForOverwriting
               completionHandler:^(BOOL success)
         {
             if (success)
             {
                 NSLog(@"Written to iCloud");
             }
             else
             {
                 NSLog(@"Error writing to iCloud");
             }
         }];
    }
}
@end
