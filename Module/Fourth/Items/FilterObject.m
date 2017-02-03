//
//  FilterObject.m
//  Pods
//
//  Created by 郑丰 on 2017/1/21.
//
//

#import "FilterObject.h"
 NSString const *kFilterNameKey = @"name";
 NSString const *kFilterObjectKey = @"obj";

@implementation FilterObject


- (NSArray *)filters
{
    NSMutableArray *filterArray =[NSMutableArray new];
    [filterArray addObject:[self constomFilter]];
    [filterArray addObject:[self pixellateFilter]];
    [filterArray addObject:[self halftoneFilter]];
    [filterArray addObject:[self crosshatchFilter]];
    [filterArray addObject:[self sketchFilter]];
    
    [filterArray addObject:[self thresholdSketchFilter]];
    [filterArray addObject:[self toonFilter]];
    [filterArray addObject:[self smoothToonFilter]];
    [filterArray addObject:[self embossFilter]];
    [filterArray addObject:[self posterizeFilter]];
    
    [filterArray addObject:[self posterizeFilter]];
    [filterArray addObject:[self swirlFilter]];
    [filterArray addObject:[self bulgeDistortionFilter]];
    [filterArray addObject:[self pinchDistortionFilter]];
    [filterArray addObject:[self stretchDistortionFilter]];
    
    [filterArray addObject:[self glassSphereFilter]];
    [filterArray addObject:[self vignetteFilter]];
    [filterArray addObject:[self kuwaharaFilter]];
    [filterArray addObject:[self kuwaharaRadius3Filter]];
    [filterArray addObject:[self perlinNoiseFilter]];
    
    [filterArray addObject:[self CGAColorspaceFilter]];
    
    return filterArray;
}

- (NSDictionary *)constomFilter
{
    GPUImageFilter* filter = [GPUImageFilter new];
    return @{@"name":@"normal", @"obj": filter};
}

- (NSDictionary *)pixellateFilter
{
    GPUImagePixellateFilter* filter = [GPUImagePixellateFilter new];
    return @{@"name":@"Pixe", @"obj": filter};
}

- (NSDictionary *)halftoneFilter
{
    GPUImageHalftoneFilter* filter = [GPUImageHalftoneFilter new];
    return @{@"name":@"Halft", @"obj": filter};
}

- (NSDictionary *)crosshatchFilter
{
    GPUImageCrosshatchFilter* filter = [GPUImageCrosshatchFilter new];
    return @{@"name":@"Chatch", @"obj": filter};
}
- (NSDictionary *)sketchFilter
{
    GPUImageSketchFilter* filter = [GPUImageSketchFilter new];
    return @{@"name":@"Sketch", @"obj": filter};
}
- (NSDictionary *)thresholdSketchFilter
{
    GPUImageThresholdSketchFilter* filter = [GPUImageThresholdSketchFilter new];
    return @{@"name":@"TSketch", @"obj": filter};
}

- (NSDictionary *)toonFilter
{
    GPUImageToonFilter* filter = [GPUImageToonFilter new];
    return @{@"name":@"Toon", @"obj": filter};
}
- (NSDictionary *)smoothToonFilter
{
    GPUImageSmoothToonFilter* filter = [GPUImageSmoothToonFilter new];
    return @{@"name":@"SToon", @"obj": filter};
}
- (NSDictionary *)embossFilter
{
    GPUImageEmbossFilter* filter = [GPUImageEmbossFilter new];
    return @{@"name":@"Emboss", @"obj": filter};
}
- (NSDictionary *)posterizeFilter
{
    GPUImagePosterizeFilter* filter = [GPUImagePosterizeFilter new];
    return @{@"name":@"Poster", @"obj": filter};
}
- (NSDictionary *)swirlFilter
{
    GPUImageSwirlFilter* filter = [GPUImageSwirlFilter new];
    return @{@"name":@"Swirl", @"obj": filter};
}
- (NSDictionary *)bulgeDistortionFilter
{
    GPUImageBulgeDistortionFilter* filter = [GPUImageBulgeDistortionFilter new];
    return @{@"name":@"bulgeD", @"obj": filter};
}
- (NSDictionary *)pinchDistortionFilter
{
    GPUImagePinchDistortionFilter* filter = [GPUImagePinchDistortionFilter new];
    return @{@"name":@"PinchD", @"obj": filter};
}
- (NSDictionary *)stretchDistortionFilter
{
    GPUImageStretchDistortionFilter* filter = [GPUImageStretchDistortionFilter new];
    return @{@"name":@"StretchD", @"obj": filter};
}
- (NSDictionary *)sphereRefractionFilter
{
    GPUImageSphereRefractionFilter* filter = [GPUImageSphereRefractionFilter new];
    return @{@"name":@"SphereR", @"obj": filter};
}
- (NSDictionary *)glassSphereFilter
{
    GPUImageGlassSphereFilter* filter = [GPUImageGlassSphereFilter new];
    return @{@"name":@"GlassS", @"obj": filter};
}
- (NSDictionary *)vignetteFilter
{
    GPUImageVignetteFilter* filter = [GPUImageVignetteFilter new];
    return @{@"name":@"Vignette", @"obj": filter};
}
- (NSDictionary *)kuwaharaFilter
{
    GPUImageKuwaharaFilter* filter = [GPUImageKuwaharaFilter new];
    return @{@"name":@"Kuwa", @"obj": filter};
}
- (NSDictionary *)kuwaharaRadius3Filter
{
    GPUImageKuwaharaRadius3Filter* filter = [GPUImageKuwaharaRadius3Filter new];
    return @{@"name":@"KuwaR", @"obj": filter};
}
- (NSDictionary *)perlinNoiseFilter
{
    GPUImagePerlinNoiseFilter* filter = [GPUImagePerlinNoiseFilter new];
    return @{@"name":@"PerlinN", @"obj": filter};
}
- (NSDictionary *)CGAColorspaceFilter
{
    GPUImageCGAColorspaceFilter* filter = [GPUImageCGAColorspaceFilter new];
    return @{@"name":@"CGAColor", @"obj": filter};
}

@end
