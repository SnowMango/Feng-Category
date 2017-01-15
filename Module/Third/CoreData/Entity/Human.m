//
//  Human.m
//  
//
//  Created by 郑丰 on 2017/1/15.
//
//

#import "Human.h"
#import <objc/runtime.h>
@implementation Human
@dynamic name;
@dynamic age;

+ (NSFetchRequest *)fetchRequest {
    return [self base_fetchRequest];
}
+(NSArray *)propertykeys
{
    unsigned int number;
    NSMutableArray *keys = [NSMutableArray new];
    objc_property_t * properties = class_copyPropertyList(self, &number);
    for (int i = 0; i< number; i++) {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [keys addObject:name];
    }
    return [keys copy];
}


- (instancetype)initWithContext:(NSManagedObjectContext *)moc
{
    if ([super respondsToSelector:@selector(initWithContext:)]) {
        self = [super initWithContext:moc];
    }else{
        NSEntityDescription * entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:moc];
        self = [super initWithEntity:entity insertIntoManagedObjectContext:moc];
    }
    if (self) {
        
    }
    
    return self;
}
@end
