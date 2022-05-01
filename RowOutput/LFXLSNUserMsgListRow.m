//
//  LFXLSNUserMsgListRow.h
//  WebApp
//
//  Created by yeyang on 17-12-12.
//  Copyright (c) 2017 Lufax. All rights reserved.
//


#import "LFXLSNUserMsgListRow.h"

@interface LFXLSNUserMsgListRow ()

@end

@implementation LFXLSNUserMsgListRow

- (UITableViewCell *)createCellForAutoAdjustedTableViewCell {
    LFXLSNUserMsgListCell *cell = [[LFXLSNUserMsgListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reuseIdentifier]];
    return cell;
}

- (UITableViewCell *)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    LFXLSNUserMsgListCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier]];
    if (cell == nil) {
        cell = (LFXLSNUserMsgListCell *)[self createCellForAutoAdjustedTableViewCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (CGFloat) cellHeight {
    return 64;
}

- (void)updateCell:(LFXLSNUserMsgListCell *)cell indexPath:(NSIndexPath *)indexPath {
}

@end



@interface LFXLSNUserMsgListCell ()

@end

@implementation LFXLSNUserMsgListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

@end





