//
//  ViewController.h
//  IoTivitySimpleServer
//
//  Created by Md. Kamrujjaman Akon on 1/21/17.
//
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnStatServer;
@property (weak, nonatomic) IBOutlet UIButton *btnStopServer;
@property (weak, nonatomic) IBOutlet UITextView *tfDisplayLogs;

-(void) displayLog :(NSString *) msg;
- (IBAction)btnStartServerAction:(id)sender;

@end

