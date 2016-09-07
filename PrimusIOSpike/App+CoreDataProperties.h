//
//  App+CoreDataProperties.h
//  PrimusIOSpike
//
//  Created by DNA on 9/6/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "App.h"

NS_ASSUME_NONNULL_BEGIN

@interface App (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *session_id;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSNumber *last_sequence_id;

@end

NS_ASSUME_NONNULL_END
