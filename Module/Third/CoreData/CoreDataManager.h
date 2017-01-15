//
//  CoreDataManager.h
//  DemoDev
//
//  Created by 郑丰 on 2017/1/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@interface CoreDataManager : NSObject
+ (instancetype)shareInstance;
@property (nonatomic,strong) NSManagedObjectContext *viewContext;

- (NSManagedObject *)writeObjectWithEntityName:(NSString *)entityName forData:(NSDictionary*)data;
- (NSArray *)readObjectsWithEntityName:(NSString *)entityName sorts:(NSArray *)sorts predicate:(NSPredicate*)predicate;

- (void)synchronize;
@end
