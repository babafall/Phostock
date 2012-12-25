//
//  iPadMainController.m
//  Phostock
//
//  Created by Roman Truba on 21.09.12.
//  Copyright (c) 2012 Roman Truba. All rights reserved.
//

#import "iPadMainController.h"

bool filtersActive[100];

@implementation FilterDef

+(FilterDef *)defWithName:(NSString *)name startTag:(int)tag sliders:(int)sliders andFilter:(GPUImageOutput*) filter
{
    FilterDef * fd = [FilterDef new];
    fd->filterName = name;
    fd->numSliders = sliders;
    fd->sliderStartTag = tag;
    fd->createdFilter = filter;
    return fd;
}

@end

@implementation iPadMainController
@synthesize gpuImageView, tableViewController;
@synthesize tableView = _tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        curPhoto = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    lastEnableFiltersCount = 1;
    GPUImageRGBFilter * rgbFilter = [[GPUImageRGBFilter alloc] init];
    GPUImageVignetteFilter * vignetteFilter = [[GPUImageVignetteFilter    alloc] init];
    GPUImageHighlightShadowFilter * highShadows = [[GPUImageHighlightShadowFilter alloc] init];
    tableFiltersObjects = [NSMutableArray arrayWithObjects:
                           [FilterDef defWithName:@"Sepia"      startTag:Sepia        sliders:1 andFilter:[[GPUImageSepiaFilter       alloc] init] ],
                           [FilterDef defWithName:@"Saturation" startTag:Saturation   sliders:1 andFilter:[[GPUImageSaturationFilter  alloc] init] ],
                           [FilterDef defWithName:@"Contrast"   startTag:Contrast     sliders:1 andFilter:[[GPUImageContrastFilter    alloc] init] ],
                           [FilterDef defWithName:@"Brightness" startTag:Brightness   sliders:1 andFilter:[[GPUImageBrightnessFilter  alloc] init] ],
                           [FilterDef defWithName:@"Hue"        startTag:Hue          sliders:1 andFilter:[[GPUImageHueFilter         alloc] init] ],
                           [FilterDef defWithName:@"Exposure"   startTag:Exposure     sliders:1 andFilter:[[GPUImageExposureFilter    alloc] init] ],
                           [FilterDef defWithName:@"Gamma"      startTag:Gamma        sliders:1 andFilter:[[GPUImageGammaFilter       alloc] init] ],
                           [FilterDef defWithName:@"White Balance"      startTag:WhiteBalance   sliders:1 andFilter:[[GPUImageWhiteBalanceFilter    alloc] init] ],
                           [FilterDef defWithName:@"Highlights"         startTag:Highlights     sliders:1 andFilter:highShadows],
                           [FilterDef defWithName:@"Shadows"            startTag:Shadows        sliders:1 andFilter:highShadows],
                           [FilterDef defWithName:@"Luminance Threshold"startTag:Luminance        sliders:1 andFilter:[[GPUImageLuminanceThresholdFilter alloc] init]],
                           [FilterDef defWithName:@"Red"                startTag:Red            sliders:1 andFilter:rgbFilter],
                           [FilterDef defWithName:@"Green"              startTag:Green          sliders:1 andFilter:rgbFilter],
                           [FilterDef defWithName:@"Blue"               startTag:Blue           sliders:1 andFilter:rgbFilter],
                           [FilterDef defWithName:@"Vignette start"     startTag:VignetteStart      sliders:1 andFilter:vignetteFilter],
                           [FilterDef defWithName:@"Vignette end"       startTag:VignetteEnd        sliders:1 andFilter:vignetteFilter],
                           [FilterDef defWithName:@"Grayscale"          startTag:Grayscale          sliders:0 andFilter:[[GPUImageGrayscaleFilter alloc] init]],
                           [FilterDef defWithName:@"Pixelate"           startTag:Pixelate       sliders:1 andFilter:[[GPUImagePixellateFilter alloc] init]],
                           [FilterDef defWithName:@"Prewit" startTag:Prewit sliders:0 andFilter:[[GPUImagePrewittEdgeDetectionFilter alloc] init]],
                           [FilterDef defWithName:@"Sketch" startTag:Sketch sliders:0 andFilter:[[GPUImageSketchFilter alloc] init]],
                           [FilterDef defWithName:@"Emboss" startTag:Emboss sliders:1 andFilter:[[GPUImageEmbossFilter alloc] init]],
                           [FilterDef defWithName:@"Pinch" startTag:Pinch sliders:1 andFilter:[[GPUImagePinchDistortionFilter alloc] init]],
                           nil];
    
    NSMutableDictionary * temp = [NSMutableDictionary new];
    for (FilterDef * def in tableFiltersObjects) {
        [temp setObject:def forKey:[NSString stringWithFormat:@"%d",def->sliderStartTag] ];
    }
    filterByKey = temp;
    basicImage = [UIImage imageNamed:@"Basic"];
    
    self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Лог настроек" style:UIBarButtonItemStyleDone target:self action:@selector(logSettings:)];
    
    [self applyFiltersToImage];
}
-(void) applyFiltersToImage
{
    int activeFilters = 0;
    
    for (FilterDef * def in tableFiltersObjects)
    {
        if (def->active)
        {
            activeFilters++;
        }
    }
    if (activeFilters == lastEnableFiltersCount) {
        [gpuPicture processImage];
        return;
    }
    lastEnableFiltersCount = activeFilters;
    gpuPicture = [[GPUImagePicture alloc] initWithImage:basicImage];
    GPUImageOutput* lastTarget = (GPUImageOutput*)gpuPicture;
    for (FilterDef * def in tableFiltersObjects)
    {
        if (def->active && lastTarget != def->createdFilter)
        {
            [lastTarget removeAllTargets];
            [lastTarget addTarget:(id<GPUImageInput>)def->createdFilter];
            lastTarget = def->createdFilter;
        }
    }
    [lastTarget removeAllTargets];
    [(GPUImageOutput*)lastTarget addTarget:self.gpuImageView];
    [gpuPicture processImage];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self generateCellFromDef:[tableFiltersObjects objectAtIndex:indexPath.row]].frame.size.height;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableFiltersObjects.count;
}
-(UITableViewCell *) generateCellFromDef:(FilterDef *)def
{
    UITableViewCell * res = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellDef"];
    UISwitch * sw = [[UISwitch alloc] initWithFrame:CGRectMake(210, 10, 50, 20)];
    [res addSubview:sw];
    int height = 50, nextY = 50;
    res.textLabel.text = def->filterName;
    [sw addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    sw.tag = def->sliderStartTag;
    sw.on = def->active;
    
    for (int i = 0; i < def->numSliders; i++)
    {
        UISlider * sl = [[UISlider alloc] initWithFrame:CGRectMake(5, nextY, 300, 20)];
        sl.minimumValue = 0;
        sl.maximumValue = 1;
        sl.value = def->sliderValue;
        sl.tag = def->sliderStartTag + i;
        [sl addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [res addSubview:sl];
        height = nextY += 30;
    }
    res.frame = CGRectMake(0, 0, res.frame.size.width, height);
    return res;
}
-(void) switchChanged:(id) sender
{
    FilterDef * curFilter;
    curFilter = [filterByKey objectForKey:[NSString stringWithFormat:@"%d",((UIControl*)sender).tag ] ];
    curFilter->active = ((UISwitch*)sender).on;
//    NSLog(@"Filter: %@ %@", curFilter->filterName, curFilter->active ? @"ON" : @"Off");
    [self applyFiltersToImage];
}
-(void) sliderChanged:(id) sender
{
    int tag = ((UIControl*)sender).tag;
    FilterDef * curFilter = [filterByKey objectForKey:[NSString stringWithFormat:@"%d", tag]];
    if (tag == Sepia)
    {
        [(GPUImageSepiaFilter *)curFilter->createdFilter setIntensity:[(UISlider *)sender value]];
    }
    else if (tag == Saturation)
    {
        [(GPUImageSaturationFilter *)curFilter->createdFilter setSaturation:[(UISlider *)sender value] * 2];
    }
    else if (tag == Contrast)
    {
        [(GPUImageContrastFilter *)curFilter->createdFilter setContrast:[(UISlider *)sender value] * 4];
    }

    else if (tag == Brightness)
    {
        [(GPUImageBrightnessFilter *)curFilter->createdFilter setBrightness:[(UISlider *)sender value] * 2 - 1];
    }
    else if (tag == Hue)
    {
        [(GPUImageHueFilter *)curFilter->createdFilter setHue:[(UISlider *)sender value] * 360.0f];
    }
    else if (tag == Exposure)
    {
        [(GPUImageExposureFilter *)curFilter->createdFilter setExposure:[(UISlider *)sender value] * 8 - 4];
    }
    else if (tag == WhiteBalance)
    {
        if (!curFilter->active) return;
        [(GPUImageWhiteBalanceFilter *)curFilter->createdFilter setTemperature:[(UISlider *)sender value] * 5000 + 2500];
    }
    else if (tag == Highlights)
    {
        if (!curFilter->active) return;
        [(GPUImageHighlightShadowFilter *)curFilter->createdFilter setHighlights:[(UISlider *)sender value]];
    }
    else if (tag == Shadows)
    {
        if (!curFilter->active) return;
        [(GPUImageHighlightShadowFilter *)curFilter->createdFilter setShadows:[(UISlider *)sender value]];
    }
    else if (tag == Luminance)
    {
        if (!curFilter->active) return;
        [(GPUImageLuminanceThresholdFilter *)curFilter->createdFilter setThreshold:[(UISlider *)sender value]];
    }
    else if (tag == Green)
    {
        if (!curFilter->active) return;
        [(GPUImageRGBFilter *)curFilter->createdFilter setGreen:[(UISlider *)sender value]  * 2];
    }
    else if (tag == Red)
    {
        if (!curFilter->active) return;
        [(GPUImageRGBFilter *)curFilter->createdFilter setRed:[(UISlider *)sender value]    * 2];
    }
    else if (tag == Blue)
    {
        if (!curFilter->active) return;
        [(GPUImageRGBFilter *)curFilter->createdFilter setBlue:[(UISlider *)sender value]   * 2];
    }
    else if (tag == VignetteStart)
    {
        [(GPUImageVignetteFilter *)curFilter->createdFilter setVignetteStart:[(UISlider *)sender value]];
    }
    else if (tag == VignetteEnd)
    {
        [(GPUImageVignetteFilter *)curFilter->createdFilter setVignetteEnd:[(UISlider *)sender value]];
    }
    else if (tag == Pixelate)
    {
        [(GPUImagePixellateFilter *)curFilter->createdFilter setFractionalWidthOfAPixel:[(UISlider *)sender value]];
    }
    else if (tag == Gamma)
    {
        [(GPUImageGammaFilter *)curFilter->createdFilter setGamma:[(UISlider *)sender value]*3];
    }
    else if (tag == Emboss)
    {
        [(GPUImageEmbossFilter *)curFilter->createdFilter setIntensity:[(UISlider *)sender value] * 5];
    }
    else if (tag == Pinch)
    {
        [(GPUImagePinchDistortionFilter *)curFilter->createdFilter setScale:[(UISlider *)sender value] * 4 - 2];
    }
    curFilter->sliderValue = [(UISlider *)sender value];
    [self applyFiltersToImage];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self generateCellFromDef:[tableFiltersObjects objectAtIndex:indexPath.row]];
    
}
-(IBAction) logSettings:(id) sender
{
    self.logTextView.text = @"";
    for (FilterDef * def in tableFiltersObjects)
    {
        if (def->active)
        {
            CGFloat value = 0.0f;
            switch ( def->sliderStartTag )
            {
                case Sepia:
                    value = [(GPUImageSepiaFilter *)def->createdFilter intensity];
                    break;
                case Saturation:
                    value = [(GPUImageSaturationFilter *)def->createdFilter saturation];
                    break;
                case Contrast:
                    value = [(GPUImageContrastFilter *)def->createdFilter contrast];
                    break;
                case Brightness:
                    value = [(GPUImageBrightnessFilter *)def->createdFilter brightness];
                    break;
                case Hue:
                    value = [(GPUImageHueFilter *)def->createdFilter hue];
                    break;
                case Exposure:
                    value = [(GPUImageExposureFilter *)def->createdFilter exposure];
                    break;
                case WhiteBalance:
                    value = [(GPUImageWhiteBalanceFilter *)def->createdFilter temperature];
                    break;
                case Highlights:
                    value = [(GPUImageHighlightShadowFilter *)def->createdFilter highlights];
                    break;
                case Shadows:
                    value = [(GPUImageHighlightShadowFilter *)def->createdFilter shadows];
                    break;
                case Red:
                    value = [(GPUImageRGBFilter *)def->createdFilter red];
                    break;
                case Green:
                    value = [(GPUImageRGBFilter *)def->createdFilter green];
                    break;
                case Blue:
                    value = [(GPUImageRGBFilter *)def->createdFilter blue];
                    break;
                case VignetteStart:
                    value = [(GPUImageVignetteFilter *)def->createdFilter vignetteStart];
                    break;
                case VignetteEnd:
                    value = [(GPUImageVignetteFilter *)def->createdFilter vignetteEnd];
                    break;
                case Pixelate:
                    value = [(GPUImagePixellateFilter *)def->createdFilter fractionalWidthOfAPixel];
                    break;
                case Luminance:
                    value = [(GPUImageLuminanceThresholdFilter *)def->createdFilter threshold];
                    break;
                case Gamma:
                    value = [(GPUImageGammaFilter *)def->createdFilter gamma];
                    break;
                case Emboss:
                    value = [(GPUImageEmbossFilter *)def->createdFilter intensity];
                    break;
                case Pinch:
                    value = [(GPUImagePinchDistortionFilter *)def->createdFilter scale];
                    break;
                default:
                    value = 1;
                    break;
            }
            self.logTextView.text = [self.logTextView.text stringByAppendingFormat:@"%@ : %f\n", def->filterName, value];
//            NSLog(@"%@ : %f", def->filterName, value);
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
- (IBAction) stepperChanged:(id)sender
{
    UIStepper * st = (UIStepper*)sender;
    NSString * imageName = [NSString stringWithFormat:@"Filter%d", (int)st.value];
    [self.testCaseImageView setImage:[UIImage imageNamed:imageName]];
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    FilterDef * def = [tableFiltersObjects objectAtIndex:sourceIndexPath.row];
    [tableFiltersObjects removeObjectAtIndex:sourceIndexPath.row];
    [tableFiltersObjects insertObject:def atIndex:destinationIndexPath.row];
}
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (IBAction) editTable:(id)sender
{
    [self.tableViewController.tableView setEditing:!self.tableViewController.tableView.editing animated:YES];
}
@end
