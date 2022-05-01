<%include file="/header_info.mako" />

#import "${data}Cell.h"

@interface ${data}Cell ()

@end

@implementation ${data}Cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

@end




