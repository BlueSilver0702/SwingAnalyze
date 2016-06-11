//
//  MediaItem.m
//  GolfChannel
//
//  Created by AnCheng on 9/15/15.
//  Copyright (c) 2015 ancheng1114. All rights reserved.
//

#import "MediaItem.h"

@implementation MediaItem

- (id)initDic:(NSDictionary *)dic
{
    self.id = dic[@"id"];
    self.userid = dic[@"user_id"];
    self.filename = dic[@"web_filename"];
    self.web_filename = dic[@"filename"];
    self.type = dic[@"type"];
    self.extension = dic[@"extension"];
    self.description1 = ([dic[@"description"] isEqual:[NSNull null]]) ? @"" : dic[@"description"];
    self.pretty_name = dic[@"pretty_name"];
    self.viewable_by_academy = [dic[@"viewable_by_academy"] boolValue];
    self.dateStr = [dic[@"created_at"] objectForKey:@"date"];
    //self.created_at = [[[Global sharedManager] MillisecondDateFormatter] dateFromString:self.dateStr];
    
    self.tagArr = [[NSMutableArray alloc] initWithArray:dic[@"tags"]];
    self.commentArr = [[NSMutableArray alloc] initWithArray:dic[@"comments"]];
    if ([dic[@"shares"] isKindOfClass:[NSDictionary class]])
        self.shareArr = [[NSMutableArray alloc] initWithArray:[dic[@"shares"] allKeys]];
        
    return self;
}

@end
