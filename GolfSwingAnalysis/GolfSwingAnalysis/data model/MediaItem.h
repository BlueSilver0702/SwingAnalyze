//
//  MediaItem.h
//  GolfChannel
//
//  Created by AnCheng on 9/15/15.
//  Copyright (c) 2015 ancheng1114. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaItem : NSObject

@property (nonatomic ,strong) NSString *id;
@property (nonatomic ,strong) NSString *userid;
@property (nonatomic ,strong) NSString *filename;
@property (nonatomic ,strong) NSString *web_filename;
@property (nonatomic ,strong) NSString *pretty_name;
@property (nonatomic ,strong) NSString *description1;
@property (nonatomic ,strong) NSString *type;
@property (nonatomic ,strong) NSString *extension;
@property (nonatomic ,strong) NSMutableArray *tagArr;
@property (nonatomic ,strong) NSMutableArray *commentArr;
@property (nonatomic ,strong) NSMutableArray *shareArr;
@property (nonatomic ,strong) NSDate *created_at;
@property (nonatomic ,strong) NSString *dateStr;
@property (nonatomic) BOOL viewable_by_academy;

- (id)initDic:(NSDictionary *)dic;

@end
