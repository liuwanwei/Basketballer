//
//  define.h
//  Basketballer
//
//  Created by maoyu on 12-7-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef Basketballer_define_h
#define Basketballer_define_h

enum TeamType{HostTeam = 0, GuestTeam = 1};
enum GameState {
    ReadyToPlay = 0,
    InPlay = 1,
    PlayIsSuspended = 2,
    QuarterTime = 3,
    EndOfGame = 4,
    StoppedPlay = 5
};

#define kTimeoutMessage @"kTimeout"
#define kTimeoutOverMessage @"kTimeoutOver"
#define kAddScoreMessage @"kAddScore"
#endif
