//
//  ViewController.h
//  PrimusIOSpike
//
//  Created by DNA on 9/1/16.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <Primus/Primus.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property UITableView *tableView;
@property NSManagedObject *selectedRecord;
@property NSFetchedResultsController *fetchedResultsController;
@property Primus *primus;
@property BOOL isOnLine;

- (void)getDataFromDB;
- (void)rightBarButtonPressed;
- (void)saveItemPressed:(NSString *)title;
- (void)updateItemPressed:(NSString *)title didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)saveNewItemToDB:(NSDictionary *)item;
- (void)syncItemsToDB:(NSArray *)items;
- (void)saveNewItemToServer:(NSDictionary *)item;
- (NSInteger)getLatestSequenceID;
- (NSInteger)getLastSequenceID;
- (void)incrementLastSequenceID;
- (void)setLastSequenceID:(NSNumber *)number;
- (void)saveRequestToDB:(NSDictionary *)item;
- (void)sendPendingRequest;

@end
