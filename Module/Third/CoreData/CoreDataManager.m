//
//  CoreDataManager.m
//  DemoDev
//
//  Created by 郑丰 on 2017/1/15.
//
//

#import "CoreDataManager.h"

@interface CoreDataManager ()
@property (strong) NSString *databaseName;
@property (nonatomic,strong) NSPersistentContainer *container;
@end

@implementation CoreDataManager

+ (instancetype)shareInstance
{
    static CoreDataManager *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[CoreDataManager alloc] init];
    });
    return obj;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.databaseName = @"ThirdCoreData";
        NSLog(@"%@", self.container);
        
    }
    return self;
}
@synthesize container = _container;

- (NSPersistentContainer *)container {
    @synchronized (self) {
        if (_container == nil) {
            _container = [[NSPersistentContainer alloc] initWithName:self.databaseName];
            [_container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error) {
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
                self.viewContext = _container.viewContext;
            }];
            NSDictionary *options= @{NSMigratePersistentStoresAutomaticallyOption : @(YES),
                                     
                                     NSInferMappingModelAutomaticallyOption:@(YES)};
            NSURL  *applicationDocumentsDirectory =[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            
            NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",self.databaseName]];
            NSError *error = nil;
            if (![_container.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }

        }
    }
    return _container;
}

#pragma mark - Core Data Saving support
- (void)saveContext:(NSManagedObjectContext *)context {
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}
- (void)synchronize
{
    [self saveContext:self.viewContext];
    [self saveContext:self.viewContext.parentContext];
}

- (NSArray *)readObjectsWithEntityName:(NSString *)entityName sorts:(NSArray *)sorts predicate:(NSPredicate*)predicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    request.sortDescriptors = sorts;
    request.predicate = predicate;
    
    NSArray * objects = [self readObjectsWithFetchRequest:request error:nil];
    return objects;
}

- (NSArray*)readObjectsWithFetchRequest:(NSFetchRequest*)request error:(NSError*)error
{
    return [self.viewContext executeFetchRequest:request error:&error];
}

- (NSManagedObject *)writeObjectWithEntityName:(NSString *)entityName forData:(NSDictionary*)data
{
    NSManagedObject * obj = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.viewContext];
    [obj setValuesForKeysWithDictionary:data];
    return obj;
}

@end
