//
//  JContact.h
//  Drizzle
//
//  Created by Jatin Kathrotiya on 11/02/16.
//  Copyright © 2016 Chirag Lakhani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <UIKit/UIKit.h>
typedef void(^CompletionBlock)(NSDictionary *dict);

@interface JContactStore : NSObject
@property (nonatomic,strong) NSMutableArray *contactArray;
@property (nonatomic,strong) NSMutableArray *contactEmailsArray;
@property (nonatomic,strong) NSMutableArray *contctOfAppUsers;
@property (nonatomic,strong) NSMutableArray *contctOfInviteUsers;
+(JContactStore *)sharedContact;
-(NSDictionary *)conactDictForNumber:(NSString *)phoneNumber;
-(void)refreshContact;
-(void)fetchContactEmailswithblock:(CompletionBlock )block;

@end
