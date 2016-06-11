//
//  Constants.h
//  GolfSwingAnalysis
//
//  Created by AnCheng on 12/15/15.
//  Copyright © 2015 Zhemin Yin. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define MAIN_DOMAIN @"https://api.winningidentity.net"
#define AMAZON_VIDEO_LINK @"https://s3-us-west-2.amazonaws.com/gcaplayerlinks/library/video/"

#define LOGIN_URL                               @"/auth"
#define GENERATE_TOKEN                          @"/regenerate-token"
#define ACADEMY_LIST_URL                        @"/academy_list_all"
#define STUDENTS_LIST_URL                       @"/members/students"

#define MEDIA_UPLOAD_URL                        @"%@/media/upload"
#define MEDIATHUMB_LINK                         @"%@/media/show/%@/thumb" // MEDIA ID
#define MEDIA_LIST_UEL                          @"/media/all/"

#define LOGIN_MAILPASSWORDEMPTY_ERROR           @"Please enter email and password"
#define LOGIN_MAILPASSWORDWRONG_ERROR           @"You must enter the correct login & password to register or login, please try again."
#define LOGIN_ACADEMYEMPTY_ERROR                @"Please type academy"

#define SUCCESS     @"Success"
#define ERROR       @"Error"
#define WARNING     @"Warning"

#endif /* Constants_h */
