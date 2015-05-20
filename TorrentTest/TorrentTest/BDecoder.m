//
//  BDecoder.m
//  TorrentTest
//
//  Created by Yann Bouschet on 19/05/2015.
//  Copyright (c) 2015 Yann Bouschet. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//  and associated documentation files (the “Software”), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or
//  substantial portions of the Software.
//
//  The Software is provided “as is”, without warranty of any kind, express or implied, including but not
//  limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.
//  In no event shall the authors or copyright holders X be liable for any claim, damages or other liability,
//  whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software
//  or the use or other dealings in the Software.
//
//  Except as contained in this notice, the name of the Yann Bouschet shall not be used in advertising
//  or otherwise to promote the sale, use or other dealings in this Software without prior written
//  authorization from the Yann Bouschet.
//

#import "BDecoder.h"


int p = 0;

@implementation BDecoder

/*
 
 bencode algo
 
 byte strings,      <length>:<contents>                     //  non-negative (zero is allowed) The string "spam" would be encoded as 4:spam.
 integers,          i<integer encoded in base ten ASCII>e   //  i42e, 0 as i0e, and -42 as i-42e. Negative zero is not permitted.
 lists,             l<contents>e                            // A list consisting of the string "spam" and the number 42 would be encoded as: l4:spami42ee. Note the absence of separators between elements.
 
 dictionaries       d<contents>e                            //{"bar": "spam", "foo": 42}), would be encoded as follows: d3:bar4:spam3:fooi42ee. (This might be easier to read by inserting some spaces: d 3:bar 4:spam 3:foo i42e e.)
 */

+ (id)decode:(NSString*)string {
    return [[BDecoder new] decode:string];
}

- (instancetype)init {
    if (self = [super init]) {
        p = 0;
    }
    
    return self;
}

- (id)decode:(NSString*)string {
    
    //security
    if(!string || p >= string.length) {
        return nil;
    }
    
    //decode integers
    if([string characterAtIndex:p] == 'i') {
        return [self processIntegerFromString:string];
    }
    
    //decode hashes
    else if([string characterAtIndex:p] == 'd') {
        return [self processHashFromString:string];
    }
    
    //decode lists
    else if([string characterAtIndex:p] == 'l') {
        return [self processListFromString:string];
    }

    //default decode string
    else {
        return [self processStringFromString:string];
    }
    
    return nil;
}

#pragma mark subs

- (NSNumber*)processIntegerFromString:(NSString*)string {
    
    //NSLog(@"++ integer");
    
    //skip marker
    p++;
    
    //slice
    NSString *substring = [string substringFromIndex:p];
    NSRange delimiterRange = [substring rangeOfString:@"e"];
    
    //extract digits
    NSString *digits = [string substringWithRange:NSMakeRange(p, delimiterRange.location)];
    
    //move on
    p+=digits.length+1;
    
    //package and return
    NSNumber *value = [NSNumber numberWithInteger:[digits integerValue]];
    return value;
}

-  (NSDictionary*)processHashFromString:(NSString*)string {
    
    //NSLog(@"++ hash");
    
    //skip marker
    p++;
    
    //temporary container
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
    
    while ([string characterAtIndex:p] != 'e'){
        
        //first get key
        NSString *key   = [self decode:string];
        //then get following object
        id object       = [self decode:string];
        
        //check end of element
        if (key && object) {
            [tmpDict setObject:object forKey:key];
        } else {
            break;
        }
    }
    
    //move on
    p++;
    
    //package and return
    NSDictionary *result = [NSDictionary dictionaryWithDictionary:tmpDict];
    return result;
}

-  (NSArray*)processListFromString:(NSString*)string {
    
    //NSLog(@"++ list");
    
    //skip marker
    p++;
    
    //temporary container
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    while ([string characterAtIndex:p] != 'e'){
        
        //recursive decode
        id result = [self decode:string];
        
        //check end of element
        if (result) {
            [tmpArray addObject:result];
        } else {
            break;
        }
    }
    
    //move on
    p++;
    
    //package and return
    NSArray *result = [NSArray arrayWithArray:tmpArray];
    return result;
}

- (NSString*)processStringFromString:(NSString*)string {
    
    //NSLog(@"++ string");
    
    //slice
    NSString *substring = [string substringFromIndex:p];
    NSRange delimiterRange = [substring rangeOfString:@":"];
    
    //extract length
    NSInteger length = [[string substringWithRange:NSMakeRange(p, delimiterRange.location)] integerValue];
    
    //extract content
    NSString *content = [substring substringWithRange:NSMakeRange(delimiterRange.location + 1, length)];
    
    //move on
    p+=delimiterRange.location+content.length+1;
    
    //return
    return content;
}



@end
