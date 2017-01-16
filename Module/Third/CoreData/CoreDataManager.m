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
@property (nonatomic,strong) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic,strong) NSManagedObjectContext *praviteContext;

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
            }];
        }
    }
    return _container;
}
- (NSURL *)sqliteUrlWithName:(NSString *)name
{
    NSURL *url =[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    url = [url URLByAppendingPathComponent:@"zheng/feng"];
//    NSURL *other = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"feng/%@.sqlite",name]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:url.path] ) {
        BOOL ret = [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"%@", ret? @"创建成功": @"创建失败");
    }
    
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",name]];
    return url;
}



- (NSURL *)momdUrlWithName:(NSString *)name bundle:(NSBundle*)bundle
{
    NSURL *url =[NSBundle mainBundle].bundleURL;
    if (bundle) {
        url = bundle.bundlePath;
    }
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.momd",name]];
    return url;
}
- (NSPersistentStoreCoordinator *)coordinator
{
    @synchronized (self) {
        if (_coordinator == nil) {

            NSManagedObjectModel * model = [NSManagedObjectModel mergedModelFromBundles:nil];
            _coordinator= [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
            NSURL * sqliteURL = [self sqliteUrlWithName:self.databaseName];
            NSError *error = nil;
            
            NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                                      NSInferMappingModelAutomaticallyOption : @YES};;
            if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                           configuration:nil URL:sqliteURL options:options error:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
    return _coordinator;
}

- (NSManagedObjectContext *)praviteContext
{
    @synchronized (self) {
        if (_praviteContext == nil) {
            _praviteContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            
             _praviteContext.persistentStoreCoordinator = self.coordinator;
//            NSLog(@"URL= %@", [_praviteContext.persistentStoreCoordinator  URLForPersistentStore:[_praviteContext.persistentStoreCoordinator.persistentStores firstObject]] );
        }
    }
    return _praviteContext;
}

- (NSManagedObjectContext *)viewContext
{
    @synchronized (self) {
        if (_viewContext == nil) {
            _viewContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            self.viewContext.parentContext = self.praviteContext;
        }
    }
    return _viewContext;
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
    [self saveContext:self.praviteContext];
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
