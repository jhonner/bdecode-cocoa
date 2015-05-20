//
//  TorrentInfo.m
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

#import "TorrentInfo.h"

@implementation TorrentInfo

+ (instancetype)torrentInfoWithDictionary:(NSDictionary*)dict {
    return [[TorrentInfo alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    
    if (!dict) return nil;
    
    if(self = [super init]) {
        self.announce       = dict[ANNOUNCE];
        self.comment        = dict[COMMENT];
        self.createdBy      = dict[CREATED_BY];
        self.creationDate   = dict[CREATION_DATE];
        self.locale         = dict[LOCALE];
        self.title          = dict[TITLE];
        
        self.files = nil;
        
        NSArray     *filesInfo  = dict[INFO][FILES];
        
        self.fileName           = dict[INFO][NAME];
        
        if (filesInfo && filesInfo.count > 0) {
            NSMutableArray *tmpArray = [NSMutableArray array];
            
            for (NSDictionary *fileInfo in filesInfo) {
                TorrentFile *torrentFile = [TorrentFile torrentFileWithDictionary:fileInfo];
                if(torrentFile) [tmpArray addObject:torrentFile];
            }
            
            self.files = [NSArray arrayWithArray:tmpArray];
        }
        
    }
    
    return self;
}

@end
