//
//  PendingRequest+CoreDataProperties.h
//  PrimusIOSpike
//
//  Created by DNA on 9/6/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "PendingRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PendingRequest (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *request;

@end

NS_ASSUME_NONNULL_END
