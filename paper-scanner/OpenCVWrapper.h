//
//  OpenCVWrapper.h
//  paper-scanner
//
//  Created by Joshua on 10/25/19.
//  Copyright © 2019 Joshua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
    + (UIImage *)selectArea:(UIImage *)source;
    + (UIImage *)scanDocument:(UIImage *)source;
@end

NS_ASSUME_NONNULL_END
