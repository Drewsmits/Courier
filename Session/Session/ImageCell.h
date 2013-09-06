//
//  ImageCell.h
//  Session
//
//  Created by Andrew Smith on 8/31/13.
//  Copyright (c) 2013 andrewbsmith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCell : UITableViewCell

@property (weak) IBOutlet UIImageView *thumbnailImageView;

@property (weak) IBOutlet UILabel *imageUrlLabel;

@end
