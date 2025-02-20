//
//  PHAssetResource+PHAssetResource_checkType.m
//  photo_manager
//

#import "PHAssetResource+PHAssetResource_checkType.h"

@implementation PHAssetResource (PHAssetResource_checkType)

- (bool)isImage{
    return [self type] == PHAssetResourceTypePhoto
    || [self type] == PHAssetResourceTypeAlternatePhoto
    || [self type] == PHAssetResourceTypeFullSizePhoto
    || [self type] == PHAssetResourceTypeAdjustmentBasePhoto;
}

- (bool)isVideo{
    BOOL predicate = [self type] == PHAssetResourceTypeVideo;
    if (@available(iOS 9.1, *)) {
        predicate = (predicate || [self type] == PHAssetResourceTypePairedVideo);
    }
    if (@available(iOS 10.0, *)) {
        predicate = (predicate || [self type] == PHAssetResourceTypeFullSizePairedVideo);
        predicate = (predicate || [self type] == PHAssetResourceTypeAdjustmentBasePairedVideo);
    }
    if (@available(iOS 13.0, *)) {
        predicate = (predicate || [self type] == PHAssetResourceTypeAdjustmentBaseVideo);
    }
    return predicate;
}

- (bool)isAudio{
    return [self type] == PHAssetResourceTypeAudio;
}

- (bool)isImageOrVideo{
    return [self isVideo] || [self isImage];
}

@end
