//
//  MyDocument.h
//  TestingICloud
//
//  Created by John Malloy on 8/1/14.
//  Copyright (c) 2014 BigRedINC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyDocument;

@protocol MyDocumentDelegate <NSObject>

-(void)documentDidChange:(MyDocument *)document;

@end

@interface MyDocument : UIDocument

@property (strong, nonatomic) NSString * text;
@property (strong, nonatomic) id<MyDocumentDelegate> delegate;



@end
