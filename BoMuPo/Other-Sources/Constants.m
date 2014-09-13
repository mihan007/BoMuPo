//
//  Constants.m
//  BoMuPo
//
//  Created by Mikhail Kuklin on 9/13/14
//  Copyright (c) 2014 Mikhail Kuklin. All rights reserved.
//

#import "BoMuPo-Environment.h"

// Use this file to define the values of the variables declared in the header.
// For data types that aren't compile-time constants (e.g. NSURL), use the
// ConstantsInitializer function below.

// See BoMuPo-Environment.h for macros that are likely applicable in
// this file. TARGETING_{STAGING,PRODUCTION} and IF_STAGING are probably
// the most useful.

// The values here are just examples.

#ifdef TARGETING_STAGING

//NSString * const APIKey = @"StagingKey";

#else

//NSString * const APIKey = @"ProductionKey";

#endif


//NSURL *APIRoot;
void __attribute__((constructor)) ConstantsInitializer() {
//    APIRoot = [NSURL URLWithString:IF_STAGING(@"http://myapp.com/api/staging", @"http://myapp.com/api")];
}