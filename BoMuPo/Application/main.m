//
//  main.m
//  BoMuPo
//
//  Created by Mikhail Kuklin on 9/13/14
//  Copyright (c) 2014 Mikhail Kuklin. All rights reserved.
//

#if HAS_POD(PixateFreestyle)
#import <PixateFreestyle/PixateFreestyle.h>
#endif

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        #if HAS_POD(PixateFreestyle)
        [PixateFreestyle initializePixateFreestyle];
        #endif

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
