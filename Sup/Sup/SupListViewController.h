//
//  SupListViewController.h
//  Sup
//
//  Created by Héctor Ramos on 6/19/14.
//  Copyright (c) 2014 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

typedef void (^SUPBooleanResultBlock)(BOOL succeeded, NSError *error);

@interface SupListViewController : UITableViewController <UITextFieldDelegate>


@end

