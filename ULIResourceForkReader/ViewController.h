//
//  ViewController.h
//  ULIResourceForkReader
//
//  Created by Uli Kusterer on 03.05.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <NSBrowserDelegate>

@property IBOutlet NSButton * dataForkRadioButton;
@property IBOutlet NSButton * xattrResourceForkRadioButton;
@property IBOutlet NSButton * namedForkResourceForkRadioButton;
@property IBOutlet NSPathControl * pathControl;
@property IBOutlet NSBrowser * resourceBrowser;

-(IBAction) chooseFile: (id)sender;
-(IBAction) updateResourceFileView: (id)sender;

@end

