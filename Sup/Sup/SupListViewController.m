//
//  SupListViewController.m
//  Sup
//
//  Created by Héctor Ramos on 6/19/14.
//  Copyright (c) 2014 Parse. All rights reserved.
//

#import "SupListViewController.h"
#import "AddFriendTableViewCell.h"

@interface SupListViewController () {
    UITextField *_addFriendCellTextField;
    UILabel *_addFriendCellTextLabel;
    NSSet *_backgroundColors;
    NSMutableSet *_availableBackgroundColors;
    NSMutableOrderedSet *_objects;
    NSMutableDictionary *_colorMapping;
    NSMutableArray *_inProgressUsernames;
}

@end

@implementation SupListViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inProgressUsernames = [NSMutableArray array];
    _objects = [NSMutableOrderedSet new];
    _colorMapping = [NSMutableDictionary dictionary];

    UIColor *purpleColor = [UIColor colorWithRed:88.0f/255.0f green:84.0f/255.0f blue:215.0f/255.0f alpha:1.0f];
    UIColor *blueColor = [UIColor colorWithRed:66.0f/255.0f green:118.0f/255.0f blue:1.0f alpha:1.0f];
    UIColor *pastelBlueColor = [UIColor colorWithRed:103.0f/255.0f green:167.0f/255.0f blue:221.0f/255.0f alpha:1.0f];
    UIColor *lightBlueColor = [UIColor colorWithRed:133.0f/255.0f green:197.0f/255.0f blue:251.0f/255.0f alpha:1.0f];
    UIColor *greenColor = [UIColor colorWithRed:135.0f/255.0f green:215.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
    UIColor *yellowColor = [UIColor colorWithRed:244.0f/255.0f green:208.0f/255.0f blue:0.0f alpha:1.0f];
    UIColor *orangeColor = [UIColor colorWithRed:233.0f/255.0f green:157.0f/255.0f blue:0.0f alpha:1.0f];
    UIColor *redColor = [UIColor colorWithRed:224.0f/255.0f green:81.0f/255.0f blue:45.0f/255.0f alpha:1.0f];
    UIColor *pinkColor = [UIColor colorWithRed:223.0f/255.0f green:72.0f/255.0f blue:84.0f/255.0f alpha:1.0f];
    UIColor *grayColor = [UIColor colorWithRed:142.0f/255.0f green:142.0f/255.0f blue:148.0f/255.0f alpha:1.0f];
    UIColor *parseColor = [UIColor colorWithRed:0.267f green:0.588f blue:0.984f alpha:1.0f];
    
    _backgroundColors = [NSSet setWithArray:@[
                                              purpleColor,
                                              blueColor,
                                              pastelBlueColor,
                                              lightBlueColor,
                                              greenColor,
                                              yellowColor,
                                              orangeColor,
                                              redColor,
                                              pinkColor,
                                              [purpleColor colorWithAlphaComponent:0.5f],
                                              [blueColor colorWithAlphaComponent:0.5f],
                                              [pastelBlueColor colorWithAlphaComponent:0.5f],
                                              [lightBlueColor colorWithAlphaComponent:0.5f],
                                              [greenColor colorWithAlphaComponent:0.5f],
                                              [yellowColor colorWithAlphaComponent:0.5f],
                                              [orangeColor colorWithAlphaComponent:0.5f],
                                              [redColor colorWithAlphaComponent:0.5f],
                                              [pinkColor colorWithAlphaComponent:0.5f],
                                              grayColor
                                            ]];
    
    _availableBackgroundColors = [NSMutableSet setWithSet:_backgroundColors];
    self.view.backgroundColor = parseColor;

    [self loadObjects];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"didReceiveRemoteNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary *notificationPayload = note.userInfo;
        if (!notificationPayload) {
            return;
        }

        NSString *username = notificationPayload[@"username"];
        if (username) {
            [self moveUsernameToTop:username];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [self loadObjects];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == _objects.count) {
        return [self tableView:tableView cellForAddFriendAtIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *username = [self usernameForRowAtIndexPath:indexPath];
    cell.textLabel.text = username;
    cell.backgroundColor = [_colorMapping objectForKey:username];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0f;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != _objects.count) {
        NSString *username = [self usernameForRowAtIndexPath:indexPath];
        [_inProgressUsernames addObject:username];
        [self sup:username block:^(BOOL succeeded, NSError *error) {
            [_inProgressUsernames removeObject:username];
            if (succeeded) {
                [self moveUsernameToTop:username];
            }
        }];
    }
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField != _addFriendCellTextField) {
        return;
    }
    
    _addFriendCellTextLabel.hidden = YES;
    _addFriendCellTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"TYPE USERNAME TO ADD" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField != _addFriendCellTextField) {
        return YES;
    }
    
    NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    
    if (lowercaseCharRange.location != NSNotFound) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                 withString:[string uppercaseString]];
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField != _addFriendCellTextField) {
        return;
    }
    
    _addFriendCellTextLabel.hidden = NO;
    _addFriendCellTextField.placeholder = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField != _addFriendCellTextField) {
        return YES;
    }

    NSString *username = textField.text;
    if (username.length > 0) {
        [self sup:username block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self moveUsernameToTop:username];
            }
        }];
        textField.text = @"";
        textField.placeholder = @"";
        _addFriendCellTextField.hidden = NO;
        [textField resignFirstResponder];
        return YES;
    }
    
    return NO;
}


#pragma mark - SupListViewController

- (void)loadObjects {
    PFQuery *query = [PFQuery queryWithClassName:@"Sup"];
    [query orderByDescending:@"updatedAt"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    if (_objects.count != 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [_objects removeAllObjects];
            for (PFObject *object in objects) {
                PFUser *fromUser = object[@"fromUser"];
                NSString *username = [object[@"fromUserName"] uppercaseString];
                if ([fromUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
                    username = [object[@"toUserName"] uppercaseString];
                }
                [_objects addObject:username];
                
                if (![[_colorMapping allKeys] containsObject:username]) {
                    if (_availableBackgroundColors.count == 0) {
                        [_availableBackgroundColors addObjectsFromArray:[_backgroundColors allObjects]];
                    }
                    UIColor *backgroundColor = [_availableBackgroundColors anyObject];
                    _colorMapping[username] = backgroundColor;
                    [_availableBackgroundColors removeObject:backgroundColor];
                }
            }
            [self.tableView reloadData];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForAddFriendAtIndexPath:(NSIndexPath *)indexPath {
    AddFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFriendCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor blueColor];
    cell.textField.delegate = self;
    
    _addFriendCellTextLabel = cell.textLabel;
    _addFriendCellTextField = cell.textField;
    
    return cell;
}

- (NSString *)usernameForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_objects[indexPath.row] uppercaseString];
}

- (NSIndexPath *)indexPathForUsername:(NSString *)username {
    username = [username uppercaseString];
    if ([_objects containsObject:username]) {
        return [NSIndexPath indexPathForRow:[_objects indexOfObject:username] inSection:0];
    }
    
    return nil;
}

- (void)sup:(NSString *)username block:(SUPBooleanResultBlock)block {
    [PFCloud callFunctionInBackground:@"sup" withParameters:@{ @"username": [username lowercaseString] } block:^(id object, NSError *error) {
        if (block) {
            block(error == nil, error);
        }
    }];
}

- (void)moveUsernameToTop:(NSString *)username {
    username = [username uppercaseString];
    NSIndexPath *indexPath = [self indexPathForUsername:username];
    
    [self.tableView beginUpdates];
    if (indexPath) {
        [_objects moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.row] toIndex:0];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    } else {
        [_objects insertObject:username atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
}



@end
