//
//  HangManViewController.m
//  HangMan
//
//  Created by mahesh gattani on 04/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HangManViewController.h"

@interface HangManViewController ()
@property NSInteger faults;
@property (weak, nonatomic) IBOutlet UILabel *word;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) NSMutableArray *doneChars;
@property (nonatomic) NSInteger solved;
@property (nonatomic) NSString *imageFormat;
@end

@implementation HangManViewController
@synthesize mind = _mind;
@synthesize winner = _winner;
@synthesize faults = _faults;
@synthesize word = _word;
@synthesize solved = _solved;
@synthesize image = _image;
@synthesize imageFormat;
@synthesize doneChars = _doneChars;

- (HangManMind*) mind
{
    if(!_mind){
        _mind = [[HangManMind alloc] init];
    }
    return _mind;
}

- (void)presentInfo
{
    NSString *info = @"Try to guess the random word given to you with maximum 7 wrong attempts. Enjoy :)";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"HANGMAN" 
                                                        message:info 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
    
    [alertView show];
}

- (IBAction)StartGame:(UIButton *)sender 
{
    [sender setHidden:YES];
    [self newGame];
}

- (IBAction)Restart:(UIButton *)sender {
    [self newGame];    
}

- (void) newGame
{
    self.faults = 0;
    self.solved = 0;

    self.doneChars = [[NSMutableArray alloc] init];
    [self.doneChars removeAllObjects];
    [self showKeys];
    [self.image setImage:[UIImage imageNamed:[NSString stringWithFormat:self.imageFormat, 0]]];
    [self.winner setHidden:YES];
    
    NSString *test_word = [[self mind] getRandomWord];
    NSLog(@"%@", test_word);
    NSMutableString* s = [NSMutableString stringWithFormat:@"_"];
    NSInteger length = [test_word length];
    for (NSInteger i = 1; i < length; i++) {
        [s appendFormat:@" _"];        
    }
    [self.word setText:s];    
}

- (IBAction)Info:(id)sender {
    [self presentInfo];
}

- (IBAction)characterPressed:(UIButton *)sender {
    NSString *character = [sender currentTitle];   
    
    if([self.doneChars containsObject:character]){
        return;
    }
            
    [self.doneChars addObject:character];
    [sender setHidden:YES];
    NSMutableArray *retval = [self.mind getPositionsOfWord:character];
    NSLog(@"%d", [retval count]);
    
    if ([retval count] == 0) {
        self.faults += 1;
        [self imageFailue];
        if(self.faults == 7){
            NSLog(@"LOST");
            [self revealWord];
            [self hideKeys];
        }
        
    }
    else {
        [self revealPositionsOfWord:retval];
        if (self.solved == [[[self mind] word] length]) {
            NSLog(@"SOLVED!");
            [self.winner setHidden:NO];
            [self hideKeys];
        }
    }

}

- (void)revealPositionsOfWord:(NSArray *)positions {
    NSString* label = [self.word text];
    for (NSUInteger i = 0; i < [positions count]; i++) {
        NSNumber *index = [positions objectAtIndex:i];
        NSRange range = NSMakeRange(2*[index intValue], 1);
        NSString *character = [self.mind.word substringWithRange:NSMakeRange([index intValue], 1)];
        label = [label stringByReplacingCharactersInRange:range withString:character];
    }
    self.solved += [positions count];
    [self.word setText:label];
}
- (void)revealWord {
    NSString *word = self.mind.word;
    self.solved = [word length];
    NSMutableString* s = [NSMutableString stringWithString:word];
    for (NSInteger i = self.solved - 1; i > 0; i--) {
        [s insertString:@" " atIndex:i];
    }
    [self.word setText:s];
}
- (void)hideKeys {
    for (NSInteger i = 1; i <= 26; i++) {
        [[[self view] viewWithTag:i] setHidden:YES];
    }
}
- (void)showKeys {
    for (NSInteger i = 1; i <= 26; i++) {
        [[[self view] viewWithTag:i] setHidden:NO];
    }
}

- (void) imageFailue {
    NSString* imageName = [NSString stringWithFormat:self.imageFormat, self.faults];
    [self.image setImage:[UIImage imageNamed:imageName]]; 
}

-(void)viewDidAppear:(BOOL)animated {
    if (self.view.bounds.size.width > 640) {
        self.imageFormat = @"hangman%d@2x";
    } else {
        self.imageFormat = @"hangman%d";
    }
    [self newGame];
}
- (void)viewDidUnload {
    [self setWinner:nil];
    [super viewDidUnload];
}
@end
