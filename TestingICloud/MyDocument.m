//
//  MyDocument.m
//  TestingICloud
//
//  Created by John Malloy on 8/1/14.
//  Copyright (c) 2014 BigRedINC. All rights reserved.
//

#import "MyDocument.h"


@implementation MyDocument


//The UIDocument class requires that you to implement the following two methods


-(id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    if (!self.text)
    
        self.text = @"";
        return [self.text dataUsingEncoding:NSUTF8StringEncoding];
    
}

-(BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError
{
    if ([contents length])
    {
        self.text = [[NSString alloc] initWithBytes:[contents bytes] length:[contents length] encoding:NSUTF8StringEncoding];
    }
    else
    {
        self.text = @"";
    }
    [self.delegate documentDidChange:self];
    
    return YES;
}



@end
