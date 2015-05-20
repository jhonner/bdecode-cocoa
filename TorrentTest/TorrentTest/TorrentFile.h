//
//  TorrentFile.h
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

#import <Foundation/Foundation.h>

#define CRC32   @"crc32"
#define LENGTH  @"length"
#define MD5     @"md5"
#define MTIME   @"mtime"
#define PATH    @"path"
#define SHA1    @"sha1"

@interface TorrentFile : NSObject

@property (nonatomic) NSString *crc32;
@property (nonatomic) NSNumber *length;
@property (nonatomic) NSString *md5;
@property (nonatomic) NSNumber *mtime;
@property (nonatomic) NSArray  *path;
@property (nonatomic) NSString *sha1;

+ (instancetype)torrentFileWithDictionary:(NSDictionary*)dict;

@end
