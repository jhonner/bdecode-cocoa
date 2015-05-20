//
//  ViewController.m
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

#import "ViewController.h"
#import "BDecoder.h"
#import "TorrentInfo.h"

#define FILE_NAME       @"FILE_NAME"
#define FILE_LENGTH     @"FILE_LENGTH"
#define FILE_CHECKSUM   @"FILE_CHECKSUM"

#define kFileExtension  @"torrent"

/*
 
 - Creation date
 - Client that created the file
 - The tracker URL - // announce
 - The name, length and checksum of each file described in the torrent - // files
 
 */


@interface ViewController ()

@property (nonatomic) TorrentInfo *torrentInfo;

@property (nonatomic) NSString *trackerName;
@property (nonatomic) NSString *creationDate;
@property (nonatomic) NSString *clientName;

@property (nonatomic) NSArray *files;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)openFile:(id)sender {
    
    __weak __typeof__(self) weakSelf = self;
    [self openPanelWithHandler:^(NSString* filepath) {
        
        __typeof__(self) strongSelf = weakSelf;
        [strongSelf processFileAtPath:filepath];
        [strongSelf refresh];
    }];
    
}

- (void)processFileAtPath:(NSString*)path {
    
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    
    //try for UTF-8
    NSString *string    = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    //fallback on mac roman encoding
    if(!string) string  = [[NSString alloc] initWithData:fileData encoding:NSMacOSRomanStringEncoding];
    
    if(string) {
        //clean up
        if (_torrentInfo) _torrentInfo = nil;
        
        //decode
        NSDictionary *decoded = [BDecoder decode:string];
        
        //set up
        if (decoded && decoded.count > 0) {
            _torrentInfo = [TorrentInfo torrentInfoWithDictionary:decoded];
        } else {
            [self alertWithTitle:@"Failed" andMessage:@"Couldn't decode file."];
        }
        
    } else {
        [self alertWithTitle:@"Failed" andMessage:@"Unsupported file encoding."];
    }
}

- (void)refresh {
    
    if(_torrentInfo.title || _torrentInfo.fileName)    {
        NSString *title     = _torrentInfo.title;
        NSString *fileName  = _torrentInfo.fileName;
        NSString *final = @"";
        
        if (title && fileName) {
            final = [NSString stringWithFormat:@"%@ - %@", title, fileName];
        }
        
        else if (title && !fileName) {
            final = title;
        }
        
        else if (!title && fileName) {
            final = fileName;
        }
        
        _titleLabel.stringValue  = final;
    }
    
    if(_torrentInfo.announce)       _trackerLabel.stringValue  = _torrentInfo.announce;
    if(_torrentInfo.creationDate)   _dateLabel.stringValue     = [self formattedDate:_torrentInfo.creationDate];
    if(_torrentInfo.createdBy)      _clientLabel.stringValue   = [NSString stringWithFormat:@"Created by: %@",_torrentInfo.createdBy];
    if(_torrentInfo.files)          _files = _torrentInfo.files;
    
    [_tableView reloadData];
}

#pragma mark open file

- (void)openPanelWithHandler:(void (^)(NSString *path))handler {
    
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    
    openPanel.title = [NSString stringWithFormat:@"Choose a .%@ file",kFileExtension];
    openPanel.showsResizeIndicator = YES;
    openPanel.showsHiddenFiles = NO;
    openPanel.canChooseDirectories = NO;
    openPanel.canCreateDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    openPanel.allowedFileTypes = @[kFileExtension];
    
    [openPanel beginSheetModalForWindow:[NSApp mainWindow]
                      completionHandler:^(NSInteger result) {
                          
                          if (result == NSModalResponseOK) {
                              
                              NSURL *selection = openPanel.URLs[0];
                             NSString *path = [[selection path] stringByResolvingSymlinksInPath];
                              
                              if(path) handler(path);
                              else {
                                  [self alertWithTitle:@"Failed" andMessage:@"Couldn't get a correct path."];
                              }
                          }
                          
                      }];
}

#pragma mark Table view dataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _files.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString *value = nil;
    
    NSString *identifier = [tableColumn identifier];
    TorrentFile *file = _files[row];

    if ([identifier isEqualToString:FILE_NAME]) {
        value = [file.path lastObject];
    }
    
    else if ([identifier isEqualToString:FILE_LENGTH]) {
        value = [file.length stringValue];
    }
    
    else if ([identifier isEqualToString:FILE_CHECKSUM]) {
        value = file.crc32;
    }
    
    return value;
}

#pragma mark utilities

- (NSString *)formattedDate:(NSString*)rawDate {
    
    NSDateFormatter *format = [NSDateFormatter new];
    [format setDateFormat:@"MMM dd, yyyy"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[rawDate doubleValue]];
    
    return [format stringFromDate:date];
}

- (void)alertWithTitle:(NSString*)title andMessage:(NSString*)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert runModal];
}

@end
