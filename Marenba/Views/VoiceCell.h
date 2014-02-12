//
//  VoiceCell.h
//  Marenba
//
//  Created by sunqichao on 14-2-10.
//  Copyright (c) 2014年 sun qichao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoiceCell : UITableViewCell
@property (strong, nonatomic) PFObject *selectObject;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (IBAction)playVoice:(id)sender;

@end
