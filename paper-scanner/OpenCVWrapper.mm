//
//  OpenCVWrapper.h
//  paper-scanner
//
//  Created by Joshua on 10/25/19.
//  Copyright © 2019 Joshua. All rights reserved.
//

#ifdef __cplusplus
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import <UIKit/UIKit.h>
#include "math.h"

#pragma clang pop
#endif

using namespace std;
using namespace cv;

#pragma mark - Private Declarations

@interface OpenCVWrapper ()

#ifdef __cplusplus
+ (Mat)_scanDocument:(Mat)source;
+ (Mat)_circleBiggestRectangle:(Mat)source;
+ (Mat)_matFrom:(UIImage *)source;
+ (UIImage *)_imageFrom:(Mat)source;
+ (vector<cv::Point>)_getMaxRectangleArea:(Mat)image;
+ (vector<cv::Point>)_orderPoints:(vector<cv::Point>)source;
+ (Mat)_transformPoints:(Mat)image :(vector<cv::Point>)contour;
#endif

@end

#pragma mark - OpenCVWrapper

@implementation OpenCVWrapper

#pragma mark Public

+ (UIImage *)scanDocument:(UIImage *)source {
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _scanDocument:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)selectArea:(UIImage *)source {
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _circleBiggestRectangle:[OpenCVWrapper _matFrom:source]]];
}

#pragma mark Private

// Take a Photo and Produce Scan Document Like Image
+ (Mat)_circleBiggestRectangle:(Mat)source {

    vector<cv::Point> maxRectangle;
    maxRectangle = [OpenCVWrapper _getMaxRectangleArea:source];
    vector<vector<cv::Point>> newcontours;
    newcontours.push_back(maxRectangle);
    Scalar color = Scalar(0, 255, 0);
    drawContours(source, newcontours, -1, color, 5);
    
    return source;
}

// Take a Photo and Produce Scan Document Like Image
+ (Mat)_scanDocument:(Mat)source {
    
    Mat result;
    vector<cv::Point> maxRectangle;
    maxRectangle = [OpenCVWrapper _getMaxRectangleArea:source];

    vector<cv::Point> orderedPoints = [OpenCVWrapper _orderPoints:maxRectangle];
    Mat warped = [OpenCVWrapper _transformPoints:source :orderedPoints];
    cvtColor(warped, result, cv::COLOR_BGR2GRAY);
        
    return result;
}

// Get Biggest Rectangle Area from Image
+ (vector<cv::Point>)_getMaxRectangleArea:(Mat)image {
    Mat result;
    cvtColor(image, result, COLOR_BGR2GRAY);
    GaussianBlur(result, result, cv::Size(3, 3), 0);
    Canny(result, result, 75, 200);

    vector<vector<cv::Point>> contours;
    findContours(result, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
    
    double maxarea = 0;
    vector<cv::Point> maxRectangle;
    for(int i=0; i < contours.size(); i++){
        
        double peri = arcLength(contours[i], true);
        vector<cv::Point> approx;
        approxPolyDP(contours[i], approx, 0.02 * peri, true);
        if (approx.size() == 4){
            double area = contourArea(contours[i]);
            if (maxarea < area) {
                maxarea = area;
                maxRectangle = approx;
            }
        }
    }
    return maxRectangle;
}


// Transform Four Points Contour and Warp Original Image
+ (Mat)_transformPoints:(Mat)image :(vector<cv::Point>)contour {
    Mat result;
    Mat transform;
    
    double widthA = sqrt(pow(contour[2].x - contour[3].x, 2) + pow(contour[2].y - contour[3].y, 2));
    double widthB = sqrt(pow(contour[1].x - contour[0].x, 2) + pow(contour[1].y - contour[0].y, 2));
    double maxWidth = widthA > widthB ? widthA: widthB;

    double heightA = sqrt(pow(contour[1].x - contour[2].x, 2) + pow(contour[1].y - contour[2].y, 2));
    double heightB = sqrt(pow(contour[0].x - contour[3].x, 2) + pow(contour[0].y - contour[3].y, 2));
    double maxHeight = heightA > heightB ? heightA : heightB;
    
    Point2f src[4];
    src[0] = contour[0];
    src[1] = contour[1];
    src[2] = contour[2];
    src[3] = contour[3];

    Point2f dst[4];

    dst[0] = cv::Point(0,0);
    dst[1] = cv::Point((maxWidth - 1),0);
    dst[2] = cv::Point((maxWidth - 1),(maxHeight - 1));
    dst[3] = cv::Point(0,(maxHeight - 1));

    transform = getPerspectiveTransform(src, dst);
    
    warpPerspective(image, result, transform, cv::Size(maxWidth, maxHeight));
    return result;
}

// Order Four Coordinates by TopLeft, TopRight, BottomRight, BottomLeft
+ (vector<cv::Point>)_orderPoints:(vector<cv::Point>)source {
    vector<cv::Point> result;
    cv::Point topLeft = source[0];
    cv::Point topRight = source[0];
    cv::Point bottomLeft = source[0];
    cv::Point bottomRight = source[0];
    
    for (int i = 1; i < source.size(); i++)
    {
        if (source[i].x + source[i].y > bottomRight.x + bottomRight.y) {
            bottomRight = source[i];
        }
        if (source[i].x + source[i].y < topLeft.x + topLeft.y) {
            topLeft = source[i];
        }
    }
    vector<cv::Point> twoPoints;
    for (int i = 0; i < source.size(); i++)
    {
        if (source[i] != topLeft && source[i] != bottomRight)
        {
            twoPoints.push_back(source[i]);
        }
    }
    if (twoPoints[0].x > twoPoints[1].x) {
        topRight = twoPoints[0];
        bottomLeft = twoPoints[1];
    } else {
        topRight = twoPoints[1];
        bottomLeft = twoPoints[0];
    }
    result.push_back(topLeft);
    result.push_back(topRight);
    result.push_back(bottomRight);
    result.push_back(bottomLeft);

    return result;
}

// Convert UIImage to OpenCV Mat
+ (Mat)_matFrom:(UIImage *)source {
    
    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    Mat result(rows, cols, CV_8UC4);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = result.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    
    CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);
    
    return result;
}

// Convert OpenCV Mat to UIImage
+ (UIImage *)_imageFrom:(Mat)source {
    
    NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);

    CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = source.step[0];
    CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());
    
    CGImageRef image = CGImageCreate(source.cols, source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return result;
}

@end
