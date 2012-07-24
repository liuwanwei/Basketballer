//
//  define.h
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef Basketballer_define_h
#define Basketballer_define_h

enum TeamType{host = 0, guest = 1};
enum GameState {
    prepare = 0,
    playing = 1,
    timeout = 2,
    over_quarter_finish =3,
    finish = 4
};

#define host 0
#define guest 1

#define kTimeoutMessage @"kTimeout"
#define kTimeoutOverMessage @"kTimeoutOver"
#define kAddScoreMessage @"kAddScore"
#endif
