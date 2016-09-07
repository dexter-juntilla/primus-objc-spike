//
//  ViewController.m
//  PrimusIOSpike
//
//  Created by DNA on 9/1/16.
//
//

#import "ViewController.h"
#import <Primus/Primus.h>
#import "SocketRocketClient.h"
#import "SocketIOClient.h"
#import "Helper.h"
#import "CoreDataHelper.h"
#import <AFNetworking/AFNetworking.h>
#import "UIImageView+AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize tableView;
@synthesize fetchedResultsController;
@synthesize selectedRecord;
@synthesize primus;
@synthesize isOnLine;

#pragma mark -
#pragma mark View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isOnLine = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, [Helper getScreenWidth], [Helper getScreenHeight] - 20) style:UITableViewStylePlain];
    [self tableView].delegate = self;
    [self tableView].dataSource = self;
    [[self tableView] reloadData];
    [[self tableView] registerClass:[UITableViewCell self] forCellReuseIdentifier:@"CellIdentifier"];
    [[self view] addSubview:tableView];
    
    [self getDataFromDB];
//    [self fetchDataFromServer];
    
    UIBarButtonItem *createItem = [[UIBarButtonItem alloc] initWithTitle: @"Add" style:UIBarButtonItemStylePlain target: self action:@selector(rightBarButtonPressed)];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationItem setRightBarButtonItem:createItem];
    
    NSString *email = [self getEmail];
    
    if (email && [email length] > 0) {
        [self connect:email];
    }
    else {
        [self setEmail];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [[self fetchedResultsController] sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    return  [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"CellIdentifier"];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else {
        for (UIView *view in [[cell contentView] subviews]) {
            [view removeFromSuperview];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSManagedObject *record = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [cell textLabel].text = [record valueForKey:@"title"];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, [[cell contentView] bounds].size.height - 1, [Helper getScreenWidth], 1)];
    
    bottomLine.backgroundColor = [UIColor grayColor];
    [[cell contentView] addSubview:bottomLine];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *record = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[[CoreDataHelper sharedInstance] masterObjectContext] deleteObject:record];
    }
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedRecord = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *title = [[self selectedRecord] valueForKey:@"title"];
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Title"
                                                                              message: nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"title";
        textField.textColor = [UIColor blueColor];
        textField.text = title;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * titleField = textfields[0];
        NSLog(@"%@",titleField.text);
        [self updateItemPressed:titleField.text didSelectRowAtIndexPath:indexPath];
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

#pragma mark -
#pragma mark Fetch Results Controller Delegate methods

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            //            [self configureCell:(TSPToDoCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            [[self tableView] reloadData];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] endUpdates];
}

#pragma mark -
#pragma mark Event Actions

- (void)rightBarButtonPressed {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Title"
                                                                              message: nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"title";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * titleField = textfields[0];
        NSLog(@"%@",titleField.text);
        [self saveItemPressed:titleField.text];
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)saveItemPressed:(NSString *)title {
    if (title && title.length) {
        NSInteger newSeqID = [self getLatestSequenceID] + 1;
        NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     title, @"title",
                                     [NSDate date], @"createdDate",
                                     @NO, @"done",
                                     [NSNumber numberWithInteger:newSeqID], @"sequence_id",
                                     [NSNumber numberWithInteger:0],@"revision_id", nil];
        [self saveNewItemToDB:[item mutableCopy]];
        
        [item setValue:[Helper dateToISO8601:[item valueForKey:@"createdDate"]] forKey:@"createdDate"];
        [self saveNewItemToServer:[item mutableCopy]];
    }
}

- (void)updateItemPressed:(NSString *)title didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self selectedRecord] setValue:title forKey:@"title"];
    
    NSError *error = nil;
    [[CoreDataHelper sharedInstance] saveContext];
    if (error) {
        NSLog(@"%@", error);
    }
}

#pragma mark -
#pragma mark Custom Methods

- (NSString *)getEmail {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"App"];
    
    fetchRequest.fetchLimit = 1;
    
    NSError *error = nil;
    
    NSManagedObject *item = [[[CoreDataHelper sharedInstance] masterObjectContext] executeFetchRequest:fetchRequest error:&error].firstObject;
    if (![item valueForKey:@"email"]) {
        return @"";
    }
    
    return [item valueForKey:@"email"];
}

- (void)setEmail {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Email"
                                                                              message: nil
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"email";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * titleField = textfields[0];
        NSLog(@"%@",titleField.text);
        [self saveEmail:titleField.text];
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)saveEmail:(NSString *)email {
    if (email) {
        [self connect:email];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"App"];
        
        fetchRequest.fetchLimit = 1;
        
        NSError *error = nil;
        
        NSManagedObject *item = [[[CoreDataHelper sharedInstance] masterObjectContext] executeFetchRequest:fetchRequest error:&error].firstObject;
        if (!item) {
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"App" inManagedObjectContext:[[CoreDataHelper sharedInstance] backgroundObjectContext]];
            
            NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:[[CoreDataHelper sharedInstance] backgroundObjectContext]];
            
            [record setValue:email forKey:@"email"];
            
            NSError *error = nil;
            [[CoreDataHelper sharedInstance] saveContext];
            if (error) {
                NSLog(@"%@", error);
            }
        }
    }
}

- (void)connect:(NSString *)email {
    NSURL *url = [NSURL URLWithString:@"http://10.1.1.247:3001/primus"];
    
    PrimusConnectOptions *options = [[PrimusConnectOptions alloc] init];
    
    options.transformerClass = [SocketRocketClient class];
    options.manual = YES;
    
    self.primus = [[Primus alloc] initWithURL:url options:options];
    
    // Calling 'open' will start the connection
    [primus open];
    
    [primus on:@"reconnect" listener:^(PrimusReconnectOptions *options) {
        self.isOnLine = YES;
        [self sendPendingRequest];
        NSString *event = @"reconnect";
        NSString *email = [self getEmail];
        NSNumber *lastSequenceID = [NSNumber numberWithInt:[self getLastSequenceID]];
        NSDictionary *data = @{@"last_sequence_id": lastSequenceID,
                               @"email": email,
                               @"event": event};
        [primus write:data];
        NSLog(@"[reconnect] - We are scheduling a new reconnect attempt");
        NSLog(@"[reconnect] - sent: %@", data);
    }];
    
    [primus on:@"online" listener:^{
        self.isOnLine = YES;
        NSLog(@"[network] - We have regained control over our internet connection.");
    }];
    
    [primus on:@"offline" listener:^{
        self.isOnLine = NO;
        NSLog(@"[network] - We lost our internet connection.");
    }];
    
    [primus on:@"open" listener:^{
        self.isOnLine = YES;
        [self sendPendingRequest];
        NSString *event = @"connect";
        NSString *email = [self getEmail];
        NSNumber *lastSequenceID = [NSNumber numberWithInt:[self getLastSequenceID]];
        NSDictionary *data = @{@"last_sequence_id": lastSequenceID,
                               @"email": email,
                               @"event": event};
        [primus write:data];
        NSLog(@"[open] - The connection has been established.");
        NSLog(@"[open] - sent: %@", data);
    }];
    
    [primus on:@"error" listener:^(NSError *error) {
        self.isOnLine = NO;
        NSLog(@"[error] - Error: %@", error);
    }];
    
    [primus on:@"data" listener:^(NSDictionary *data, id raw) {
        self.isOnLine = YES;
        if ([[data valueForKey:@"event"] isEqualToString:@"syncItems"]) {
            NSArray *items = [data objectForKey:@"data"];
            if ([items count] > 0) {
                [self syncItemsToDB:items];
            }
        }
        NSLog(@"[data] - Received data: %@", data);
    }];
    
    [primus on:@"end" listener:^{
        self.isOnLine = NO;
        NSLog(@"[end] - The connection has ended.");
    }];
    
    [primus on:@"close" listener:^{
        self.isOnLine = NO;
        NSLog(@"[close] - We've lost the connection to the server.");
    }];
}

- (NSInteger)getLatestSequenceID {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Item"];
    
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sequence_id" ascending:NO]];

    NSError *error = nil;
    
    NSManagedObject *item = [[[CoreDataHelper sharedInstance] masterObjectContext] executeFetchRequest:fetchRequest error:&error].firstObject;
    if (![item valueForKey:@"sequence_id"]) {
        return 0;
    }
    NSNumber *seqID = [item valueForKey:@"sequence_id"];
    return [seqID intValue];
}

- (NSInteger)getLastSequenceID {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"App"];
    
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"last_sequence_id" ascending:NO]];
    
    NSError *error = nil;
    
    NSManagedObject *item = [[[CoreDataHelper sharedInstance] masterObjectContext] executeFetchRequest:fetchRequest error:&error].firstObject;
    if (![item valueForKey:@"last_sequence_id"]) {
        return 0;
    }
    NSNumber *seqID = [item valueForKey:@"last_sequence_id"];
    return [seqID intValue];
}

- (void)incrementLastSequenceID {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"App"];
    
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"last_sequence_id" ascending:NO]];
    
    NSError *error = nil;
    
    NSManagedObject *item = [[[CoreDataHelper sharedInstance] masterObjectContext] executeFetchRequest:fetchRequest error:&error].firstObject;
    NSNumber *seqID = [item valueForKey:@"last_sequence_id"];
    NSInteger newSeqID = [seqID integerValue] + 1;
    [item setValue:[NSNumber numberWithInteger:newSeqID] forKey:@"last_sequence_id"];
    
    [[CoreDataHelper sharedInstance] saveContext];
}

- (void)setLastSequenceID:(NSNumber *)number {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"App"];
    
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"last_sequence_id" ascending:NO]];
    
    NSError *error = nil;
    
    NSManagedObject *item = [[[CoreDataHelper sharedInstance] masterObjectContext] executeFetchRequest:fetchRequest error:&error].firstObject;
    
    [item setValue:number forKey:@"last_sequence_id"];
    
    [[CoreDataHelper sharedInstance] saveContext];
}

- (void)getDataFromDB {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:YES]]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[CoreDataHelper sharedInstance] masterObjectContext] sectionNameKeyPath:nil cacheName:nil];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    [[self fetchedResultsController] performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

- (void)saveNewItemToDB:(NSDictionary *)item {
    if (item) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:[[CoreDataHelper sharedInstance] backgroundObjectContext]];
        
        NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:[[CoreDataHelper sharedInstance] backgroundObjectContext]];
        
        [record setValue:[item valueForKey:@"title"] forKey:@"title"];
        [record setValue:[item valueForKey:@"createdDate"] forKey:@"createdDate"];
        [record setValue:[item valueForKey:@"done"] forKey:@"done"];
        [record setValue:[item valueForKey:@"sequence_id"] forKey:@"sequence_id"];
        [record setValue:[item valueForKey:@"revision_id"] forKey:@"revision_id"];
        
        [[CoreDataHelper sharedInstance] saveContext];
    }
}

- (void)syncItemsToDB:(NSArray *)items {
    NSInteger lastSeqID = [self getLastSequenceID];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:[[CoreDataHelper sharedInstance] backgroundObjectContext]];
    for (int i=0; i<[items count]; i++) {
        NSDictionary *item = [items objectAtIndex:i];
        
        NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:[[CoreDataHelper sharedInstance] backgroundObjectContext]];
        
        [record setValue:[item valueForKey:@"title"] forKey:@"title"];
        [record setValue:[Helper ISO8601ToDate:[item valueForKey:@"createdDate"]] forKey:@"createdDate"];
        [record setValue:[item valueForKey:@"done"] forKey:@"done"];
        [record setValue:[item valueForKey:@"sequence_id"] forKey:@"sequence_id"];
        [record setValue:[item valueForKey:@"revision_id"] forKey:@"revision_id"];
        
        if ([[item valueForKey:@"sequence_id"] integerValue] > lastSeqID) {
            lastSeqID = [[item valueForKey:@"sequence_id"] integerValue];
        }
    }
    [self setLastSequenceID:[NSNumber numberWithInteger:lastSeqID]];
}

- (void)saveNewItemToServer:(NSDictionary *)item {
    NSDictionary *data = @{@"event":@"newItem",@"data":item};
    
    if (self.isOnLine) {
        [self incrementLastSequenceID];
        [[self primus] write:data];
    }
    else {
        [self saveRequestToDB:data];
    }

}

- (void)saveRequestToDB:(NSDictionary *)item {
    if (item) {
        NSLog(@"saveRequestToDB");
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:item
                                                           options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"PendingRequest" inManagedObjectContext:[[CoreDataHelper sharedInstance] masterObjectContext]];
            
            NSManagedObject *record = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:[[CoreDataHelper sharedInstance] masterObjectContext]];
            
            [record setValue:jsonString forKey:@"request"];
            NSLog(@"%@",record);
            
            [[CoreDataHelper sharedInstance] saveContext];
            if (error) {
                NSLog(@"CoreData Error - %@", error);
            }
        }
    }
}

- (void)sendPendingRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PendingRequest"];
    
    NSError *error = nil;
    NSArray *pendingRequests = [[[CoreDataHelper sharedInstance] masterObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    for (int i=0; i<[pendingRequests count]; i++) {
        NSManagedObject *item = [pendingRequests objectAtIndex:i];
        
        NSError *jsonError;
        NSData *objectData = [[item valueForKey:@"request"] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:&jsonError];
        
        NSDictionary *data = @{@"event":[json valueForKey:@"event"],@"data":[json objectForKey:@"data"]};
        
        if (self.isOnLine) {
            [self incrementLastSequenceID];
            [[self primus] write:data];
            [[[CoreDataHelper sharedInstance] masterObjectContext] deleteObject:item];
        }
        else {
            [[CoreDataHelper sharedInstance] saveContext];
            return;
        }
        [[CoreDataHelper sharedInstance] saveContext];
    }
    
}
@end
