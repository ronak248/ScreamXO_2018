//
//  JContact.m
//  Drizzle
//
//  Created by Jatin Kathrotiya on 11/02/16.
//  Copyright © 2016 Chirag Lakhani. All rights reserved.
//

#import "JContactStore.h"
#define CONTACTAPPUSER @"contactAppUser"
#define CONTACTINVITEUSER @"contactInviteUser"
#define LastSyncDate @"lastsyncdate"


static JContactStore *jcontactStore;
typedef void(^CompletionHandler)(BOOL);

@interface JContactStore()
@property(nonatomic, strong) CNContactStore *contactStore;

@end

@implementation JContactStore

+(JContactStore *)sharedContact{
   
    if(jcontactStore == nil){
        jcontactStore = [[JContactStore alloc]init];
        jcontactStore.contactArray = [[NSMutableArray alloc]init];
        
        jcontactStore.contctOfAppUsers = [[NSMutableArray alloc]init];
        jcontactStore.contctOfInviteUsers = [[NSMutableArray alloc]init];
       

        jcontactStore.contactStore = [[CNContactStore alloc]init];
            [[NSNotificationCenter defaultCenter] addObserver:jcontactStore selector:@selector(addressBookDidChange:) name:CNContactStoreDidChangeNotification object:nil];
//         [jcontactStore fetchAllContacts];
        
       
    }
    return jcontactStore;
}

-(void)refreshContact{
   
        [jcontactStore fetchAllContacts];
}
//// code for ios 9.0 and later
-(void)fetchAllContacts{
    
    [self requestForAccessWithcompletionHandler:^(BOOL isAuth) {
        
        if (isAuth) {
           
            NSError *fetchError;
            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:           @[CNContactPhoneNumbersKey,CNContactEmailAddressesKey, CNContactImageDataKey,[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]]];
            request.mutableObjects = YES;
            request.unifyResults = YES;
            self.contactArray = [[NSMutableArray alloc]init];
            BOOL success = [self.contactStore enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
                
                NSDictionary *dict = [self getDictFromCNObj:contact];
                if(dict != nil){
                     [self.contactArray addObject:dict];
                }
               
               // NSLog(@"I am %@", self.contactArray);
                
            }];
            
            if(success){
                [self syncWithServer];
            }
        }
    }];
    
}
-(void)syncWithServer{
    
    NSLog(@"%@",self.contactArray);
   
}
-(void)fetchContactEmailswithblock:(CompletionBlock )block{
    self.contactEmailsArray = [[NSMutableArray alloc]init];
    [self requestForAccessWithcompletionHandler:^(BOOL isAuth) {
        
        if (isAuth) {
            
            NSError *fetchError;
            CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:           @[CNContactPhoneNumbersKey,CNContactEmailAddressesKey, CNContactImageDataKey,[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]]];
            request.mutableObjects = YES;
            request.unifyResults = YES;
            self.contactArray = [[NSMutableArray alloc]init];
            BOOL success = [self.contactStore enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
                
                NSMutableArray *array = [self emailsOfContacts:contact];
                if(array != nil){
                    [self.contactEmailsArray addObjectsFromArray:array];
                }
                
                // NSLog(@"I am %@", self.contactArray);
                
            }];
            
            if(success){
                
                NSDictionary *dict = @{@"contactEmail":self.contactEmailsArray};
                block(dict);
            }
        }
    }];
  
    
}

-(void)requestForAccessWithcompletionHandler:(CompletionHandler)compileBlock{
   CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (authorizationStatus) {
        case CNAuthorizationStatusAuthorized:
        {
            compileBlock(YES);
        }
            break;
        case CNAuthorizationStatusDenied:
        case CNAuthorizationStatusNotDetermined:
        {
            [self.contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    compileBlock(YES);
                }
                else
                {
                    
                    NSLog(@"Please allow the app to access your contacts through the Settings");
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:@"Please allow the app to access your contacts through the Settings"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                    
                   

                }
            }];
            
        }
            break;
        default:
            compileBlock(NO);
            break;
    }
}




-(NSMutableDictionary *)getDictFromCNObj:(CNContact *)c

{
    
   // [contactFilterArray addObject:@{@"number":person.phoneNumber,@"name":CLFullName(person),@"Image":checkForNullOrNil(person.imageUrl),@"Id":@""}];
   
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:@"" forKey:@"Id"];
    [dict setObject:[NSString stringWithFormat:@"%@ %@",c.givenName ,c.familyName]forKey:@"name"];
    [dict setObject:@"" forKey:@"Image"];
    
    
    
    NSArray *phones = [[NSArray alloc]initWithArray:c.phoneNumbers];
    if (phones.count > 0) {
        CNLabeledValue *cnlv = phones[0];
        CNPhoneNumber *n = cnlv.value;
        [dict setObject:n.stringValue forKey:@"number"];
    }else{
        return nil;
    }

//    NSLog(@"contact %@",dict);
    
    return  dict;
}
-(NSMutableArray *)emailsOfContacts:(CNContact *)c{
    
    NSMutableArray * Emails = [[NSMutableArray alloc]init];
    
    NSArray *emails = [[NSArray alloc]initWithArray:c.emailAddresses];
    
    for (CNLabeledValue *lbl in emails) {
        
        [Emails addObject:lbl.value];
    }
    
    return Emails;
}



-(NSDictionary *)conactDictForNumber:(NSString *)phoneNumber
{
    NSPredicate *predicateEventsByArtistName = [NSPredicate predicateWithFormat:@"SELF.%K contains[c] %@",@"Number",phoneNumber];
    
     NSArray *array =[self.contctOfAppUsers  filteredArrayUsingPredicate:predicateEventsByArtistName];
     if (array.count>0)
     {
         NSMutableDictionary *contactDictionary = [NSMutableDictionary dictionaryWithDictionary:array[0]];
       
         return contactDictionary;
     }
    
    return nil;
}



///// code for ios 8 and Later



#pragma mark:-- contact Delegate---
-(void)apGetContactArray:(NSArray *)contactArray1 WithImageArray:(NSArray *)imageArray1
{
    
    self.contactArray = [[NSMutableArray alloc]initWithArray:imageArray1];
    
    [self syncWithServer];
    
   
}

#pragma mark:- change notification methods

-(void)addressBookDidChange:(NSNotification*)notification
{
    [self refreshContact];
}



@end
