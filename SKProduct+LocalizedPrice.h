//
//  SKProduct+LocalizedPrice.h
//  RRV101
//
//  Created by Christy Keck on 10/11/12.
//
//

#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end
