//
//  MyProfile_ViewController.m
//  Mealplan
//
//  Created by Mao on 7/12/15.
//  Copyright (c) 2015 Mao. All rights reserved.
//

#import "MyProfile_ViewController.h"

@implementation MyProfile_ViewController

@synthesize m_oServerHandler;
@synthesize m_oImagePicker;
@synthesize m_oProfileImage;
@synthesize m_oUserNameLabel;
@synthesize m_oLocationLabel;
@synthesize m_oMealFriendsLabel;
@synthesize m_oMealsAttendedLabel;
@synthesize m_oMealsCreatedLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_oServerHandler = [[ServerHandler alloc] init];
    m_oImagePicker = [[UIImagePickerController alloc] init];
    m_oServerHandler.m_oDelegate = self;
    m_oImagePicker.delegate = self;
    m_oImagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
}

- (void) viewDidAppear:(BOOL)animated {
    [m_oServerHandler makeRequest:@"/user_action.php?action=ViewProfile" postData:nil action:@"ViewProfile"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
}


#pragma mark Navigation

- (IBAction)unwindToMyProfile:(UIStoryboardSegue *)segue {
    return;
}

#pragma mark Click Actions

- (IBAction)clickMessage:(UIButton *)oButton {
}

- (IBAction)clickUploadPhoto:(UIButton *)oButton {
    [self presentViewController:m_oImagePicker animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate Protocol

-(void)imagePickerController:(UIImagePickerController *)oImagePicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [oImagePicker dismissViewControllerAnimated:YES completion:nil];
    NSData *oImageData = UIImagePNGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"]);
    
    [m_oServerHandler uploadImage:@"/image_action.php?action=CreateImage" postData:[self compressImage:[UIImage imageWithData:oImageData]] action:@"UploadImage"];
}

#pragma mark ServerHandlerDelegate Protocol

- (void)processServerResponseModel:(ServerResponseModel *)oServerResponseModel action:(NSString *)sAction {
    if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"ViewProfile"])
    {
        NSError *oJsonError;
        UserProfileModel *oUserProfileModel = [[UserProfileModel alloc] initWithString:oServerResponseModel.m_sOutput error:&oJsonError];
        
        if(oJsonError)
        {
            NSLog(@"json error: %@", oJsonError.localizedDescription);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *oProfilePicUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user_pics/%@", [ServerHandler getServerIp], oUserProfileModel.m_sUserPic]];
            UIImage *oPlaceholderPic = [UIImage imageNamed:@"icon_userimage.png"];
            [m_oProfileImage sd_setImageWithURL:oProfilePicUrl placeholderImage:oPlaceholderPic];
            m_oProfileImage.contentMode = UIViewContentModeScaleAspectFill;
            m_oProfileImage.layer.cornerRadius = m_oProfileImage.frame.size.width / 2;
            m_oProfileImage.clipsToBounds = YES;
            
            m_oUserNameLabel.text = oUserProfileModel.m_sName;
            m_oUserNameLabel.text = oUserProfileModel.m_sUserName;
            m_oMealsCreatedLabel.text = [NSString stringWithFormat:@"%i", oUserProfileModel.m_iNumberMealsCreated];
            m_oMealsAttendedLabel.text = [NSString stringWithFormat:@"%i", oUserProfileModel.m_iNumberMealsAttended];
            m_oMealFriendsLabel.text = [NSString stringWithFormat:@"%i", oUserProfileModel.m_iNumberFriends];
        });
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"TRUE"] && [sAction isEqualToString:@"UploadImage"])
    {
        [m_oServerHandler makeRequest:@"/user_action.php?action=ViewProfile" postData:nil action:@"ViewProfile"];
    }
    else if([oServerResponseModel.m_sResult isEqualToString:@"FALSE"] && [sAction isEqualToString:@"UploadImage"])
    {
        NSLog(@"%@", oServerResponseModel.m_sError);
    }
    
    return;
}

- (void)processServerResponseError:(NSError *)oError {
    return;
}

- (void)processJsonError:(NSError *)oError {
    return;
}

#pragma mark compress image - NOT MY CODE

- (NSData *)compressImage:(UIImage *)image{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 360.0;
    float maxWidth = 480.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImagePNGRepresentation(img);
    UIGraphicsEndImageContext();
    
    return imageData;
}

@end
