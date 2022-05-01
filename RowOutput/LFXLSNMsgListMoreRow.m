//
//  LFXLSNMsgListMoreRow.h
//  WebApp
//
//  Created by yeyang on 17-12-13.
//  Copyright (c) 2017 Lufax. All rights reserved.
//


#import "LFXLSNMsgListMoreRow.h"

@interface LFXLSNMsgListMoreRow ()

@end

@implementation LFXLSNMsgListMoreRow

- (UITableViewCell *)createCellForAutoAdjustedTableViewCell {
    LFXLSNMsgListMoreCell *cell = [[LFXLSNMsgListMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reuseIdentifier]];
    return cell;
}

- (UITableViewCell *)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    LFXLSNMsgListMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier]];
    if (cell == nil) {
        cell = (LFXLSNMsgListMoreCell *)[self createCellForAutoAdjustedTableViewCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (CGFloat) cellHeight {
    return 64;
}

- (void)updateCell:(LFXLSNMsgListMoreCell *)cell indexPath:(NSIndexPath *)indexPath {
}

@end



@interface LFXLSNMsgListMoreCell ()

@end

@implementation LFXLSNMsgListMoreCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

@end





