# DSImagePicker-IOS

# How to use

# Add Permission

Add following permissions in Project Info.plist
1. Privacy - Photo Library Usage Description
2. Privacy - Camera Usage Description


# How to call method

  -(IBAction)showImagePicker:(id)sender{
  
    [[DSImagePicker shared] imagePickerInViewController:self allowEditing:YES WithSuccess:^(UIImage *image) {
        //image
        
    } failure:^(NSError *error) {
        
    }];
    
}
