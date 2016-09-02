//
//  ViewController.m
//  PrimusIOSpike
//
//  Created by DNA on 9/1/16.
//
//

#import "ViewController.h"
#import <Primus/Primus.h>
#import "SocketRocketClient.h"
#import "SocketIOClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL URLWithString:@"http://10.1.1.247:3000/primus"];
    
    PrimusConnectOptions *options = [[PrimusConnectOptions alloc] init];
    
    options.transformerClass = [SocketRocketClient class];
    options.manual = YES;
    
    Primus *primus = [[Primus alloc] initWithURL:url options:options];
    
    // Calling 'open' will start the connection
    [primus open];
    
    
    [primus on:@"reconnect" listener:^(PrimusReconnectOptions *options) {
        NSLog(@"[reconnect] - We are scheduling a new reconnect attempt");
    }];
    
    [primus on:@"online" listener:^{
        NSLog(@"[network] - We have regained control over our internet connection.");
    }];
    
    [primus on:@"offline" listener:^{
        NSLog(@"[network] - We lost our internet connection.");
    }];
    
    [primus on:@"open" listener:^{
        NSLog(@"[open] - The connection has been established.");
    }];
    
    [primus on:@"error" listener:^(NSError *error) {
        NSLog(@"[error] - Error: %@", error);
    }];
    
    [primus on:@"data" listener:^(NSDictionary *data, id raw) {
        NSLog(@"[data] - Received data: %@", data);
    }];
    
    [primus on:@"end" listener:^{
        NSLog(@"[end] - The connection has ended.");
    }];
    
    [primus on:@"close" listener:^{
        NSLog(@"[close] - We've lost the connection to the server.");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
