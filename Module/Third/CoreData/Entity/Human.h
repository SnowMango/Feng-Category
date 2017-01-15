//
//  HumanEntity.h
//  
//
//  Created by 郑丰 on 2017/1/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Base.h"
NS_ASSUME_NONNULL_BEGIN

@interface Human : NSManagedObject
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *age;

+ (NSArray *)propertykeys;

- (instancetype)initWithContext:(NSManagedObjectContext *)moc;
@end


NS_ASSUME_NONNULL_END

