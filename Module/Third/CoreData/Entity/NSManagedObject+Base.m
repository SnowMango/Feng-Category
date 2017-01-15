//
//  NSManagedObject+Base.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/15.
//
//

#import "NSManagedObject+Base.h"

@implementation NSManagedObject (Base)
+ (NSFetchRequest *)base_fetchRequest
{
    NSString *name = NSStringFromClass(self);
    return [[NSFetchRequest alloc] initWithEntityName:name];
}
@end
