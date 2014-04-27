//
//  ViewController.m
//  Procon25
//
//  Created by Cubic on 2014/04/03.
//  Copyright (c) 2014年 Cubic. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *sumCost;
@property (weak, nonatomic) IBOutlet UITextField *selectCost;
@property (weak, nonatomic) IBOutlet UITextField *swapCost;
@property (weak, nonatomic) IBOutlet UITextField *heightDivNumber;
@property (weak, nonatomic) IBOutlet UITextField *widthDivNumber;
@property (nonatomic) NSMutableArray *views;
@property (nonatomic) UIImage *originImage;
@property (nonatomic) UIView *selectedView;
@property (nonatomic) CGPoint beginPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) BOOL isSwaped;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // initialize member
    self.views = [NSMutableArray array];
    self.isSwaped = false;
    // put a initial image
    self.originImage = [UIImage imageNamed:@"Neko1.jpg"];
    [self setImage:self.originImage
         heightDiv:self.heightDivNumber.text.intValue
          widthDiv:self.widthDivNumber.text.intValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


# pragma mark - button actions

- (IBAction)resetButtonTouched:(id)sender
{
    self.sumCost.text = @"0";
    [self setImage:self.originImage
         heightDiv:self.heightDivNumber.text.intValue
          widthDiv:self.widthDivNumber.text.intValue];
}

- (IBAction)selectImageButtonTouched:(id)sender
{
    UIAlertView *alert = UIAlertView.new;
    alert.delegate = self;
    alert.title = @"画像選択";

    [alert addButtonWithTitle:@"カメラ"];
    [alert addButtonWithTitle:@"フォトライブラリ"];
    [alert addButtonWithTitle:@"キャンセル"];
    
    [alert show];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0: // カメラ
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        case 1: // フォトライブラリ
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 2: // キャンセル
            break;
    }
    
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = UIImagePickerController.new;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    picker.sourceType = sourceType;
    picker.delegate = self;
    picker.allowsEditing = YES;
 
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - touch event

- (void)panAction : (UIPanGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateBegan) {
        self.beginPoint = sender.view.center;
        self.endPoint = sender.view.center;
        self.selectedView = sender.view;
        [self.view bringSubviewToFront:self.selectedView];
    }
 
    
    CGPoint d = [sender translationInView:self.view];
    CGPoint to = CGPointMake(self.beginPoint.x + d.x, self.beginPoint.y + d.y);
    sender.view.center = to;
    
    if(sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.1f animations:^{ self.selectedView.center = self.endPoint; }];
        
        self.isSwaped = false;
    }
    
    
    // search swap opponent and ones id
    int index = 0, opponentIndex = -1;
    double minDirection = 100000000;
    for(int i = 0; i < self.views.count; i++) {
        UIImageView *view = [self.views objectAtIndex:i];
        double d1 = pow(self.endPoint.x - to.x, 2) + pow(self.endPoint.y - to.y, 2);
        double d2 = pow(view.center.x - to.x, 2) + pow(view.center.y - to.y, 2);
        
        if(view.tag != sender.view.tag && d1 > d2 && minDirection > d2) {
            opponentIndex = i;
            minDirection = d2;
        }
        
        if(view.tag == sender.view.tag) {
            index = i;
        }
    }
    
    
    // swap
    if(opponentIndex != -1) {
        if(!self.isSwaped) {
            self.sumCost.text = [NSString stringWithFormat:@"%d", self.sumCost.text.intValue + self.selectCost.text.intValue];
            self.isSwaped = true;
        }
        
        self.sumCost.text = [NSString stringWithFormat:@"%d", self.sumCost.text.intValue + self.swapCost.text.intValue];
        
        UIImageView *view = [self.views objectAtIndex:opponentIndex];
        CGPoint buf = self.endPoint;
        self.endPoint = view.center;
        
        [UIView animateWithDuration:0.2f animations:^{ view.center = buf; }];
        
        [self.views swapValuesWithIndex:index opponent:opponentIndex];
    }
}


#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self setImage:self.originImage
         heightDiv:self.heightDivNumber.text.intValue
          widthDiv:self.widthDivNumber.text.intValue];

    self.sumCost.text = @"0";
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


# pragma mark - setImage and others

- (void)setImage:(UIImage *)image heightDiv:(NSInteger)heightDiv widthDiv:(NSInteger)widthDiv
{
    for(UIImageView *view in self.views) {
        [view removeFromSuperview];
    }
    
    [self.views removeAllObjects];
    
    NSMutableArray *divImages = [self divImage:image heightDiv:heightDiv widthDiv:widthDiv];
    [divImages shuffle];
    
    CGFloat scale = 640 / MAX(image.size.width, image.size.height);
    int width = image.size.width * scale;
    int height = image.size.height * scale;
    int blockWidth = width / widthDiv;
    int blockHeight = height / heightDiv;
    int space = 16 / MAX(widthDiv, heightDiv);
    CGPoint center = CGPointMake(384, 384);
    
    for(int heightCount = 0; heightCount < heightDiv; heightCount++) {
        for(int widthCount = 0; widthCount < widthDiv; widthCount++) {
            int x = center.x - (width + space * (widthDiv - 1)) / 2 + (blockWidth + space) * widthCount;
            int y = center.y - (height + space * (heightDiv - 1)) / 2 + (blockHeight + space) * heightCount;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, blockWidth, blockHeight)];
            imageView.tag = heightCount * widthDiv + widthCount;
            imageView.image = [divImages objectAtIndex:imageView.tag];
            imageView.layer.cornerRadius = 10;
            imageView.clipsToBounds = true;
            
            [self setRecognizers:imageView];
            
            [self.view addSubview:imageView];
            [self.views addObject:imageView];
        }
    }
}

- (void)setRecognizers:(UIImageView *)imageView
{
    imageView.userInteractionEnabled = YES;
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    
    [imageView addGestureRecognizer:gesture];
}

- (NSMutableArray *)divImage:(UIImage *)image heightDiv:(NSInteger)heightDiv widthDiv:(NSInteger)widthDiv
{
    CGImageRef srcImageRef = [image CGImage];
    
    CGFloat blockWith = image.size.width / widthDiv;
    CGFloat blockHeight = image.size.height / heightDiv;
    
    NSMutableArray *images = NSMutableArray.new;
    
    for (int heightCount = 0; heightCount < heightDiv; heightCount++) {
        for(int widthCount = 0; widthCount < widthDiv; widthCount++){
            CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, CGRectMake(blockWith * widthCount, blockHeight * heightCount, blockWith, blockHeight));
            UIImage *trimmedImage = [UIImage imageWithCGImage:trimmedImageRef];
            [images addObject:trimmedImage];
        }
    }
    
    return images;
}

@end


@implementation NSMutableArray (swapping)

- (void)shuffle
{
    srand((unsigned)time(NULL));
    
    NSInteger count = self.count;
    
    for(int i = 0; i < count * 10; i++) {
        [self swapValuesWithIndex:(rand() % count) opponent:(rand() % count)];
    }
}

- (void)swapValuesWithIndex:(int)a opponent:(int)b
{
    id tmpa = [self objectAtIndex:a];
    id tmpb = [self objectAtIndex:b];
    
    [self replaceObjectAtIndex:a withObject:tmpb];
    [self replaceObjectAtIndex:b withObject:tmpa];
}

@end

