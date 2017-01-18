//
//  NS2DArray+JSON.h
//  StarLight
//
//  Created by Brian Olencki on 1/18/17.
//  Copyright © 2017 Brian Olencki. All rights reserved.
//

#import "NS2DArray.h"

@interface NS2DArray (JSON)
- (instancetype)initWithJSON:(NSArray *)json;
- (NSArray*)json;
@end
