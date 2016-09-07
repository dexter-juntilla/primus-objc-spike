//
//  Item+CoreDataProperties.h
//  PrimusIOSpike
//
//  Created by DNA on 9/6/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Item.h"

NS_ASSUME_NONNULL_BEGIN

@interface Item (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdDate;
@property (nullable, nonatomic, retain) NSString *details;
@property (nullable, nonatomic, retain) NSNumber *done;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *revision_id;
@property (nullable, nonatomic, retain) NSNumber *sequence_id;

@end

NS_ASSUME_NONNULL_END
