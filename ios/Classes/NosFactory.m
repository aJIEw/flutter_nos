#import "NosFactory.h"
#import "NOSSDK/NOSSDK.h"

#define kNosMethod    @"method"

@interface NosFactory () {
    NSObject<FlutterBinaryMessenger>* _messenger;
    FlutterMethodChannel* _commonChannel;
    NOSUploadManager *upManager;
}

@property (nonatomic, strong) FlutterEventSink eventSink;

@end

@implementation NosFactory

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _messenger = messenger;
        __weak __typeof__(self) weakSelf = self;
        
        _commonChannel = [FlutterMethodChannel methodChannelWithName:@"flutter_nos" binaryMessenger:messenger];
        [_commonChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
            [weakSelf onMethodCall:call result:result];
        }];
        
        FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"flutter_nos_event" binaryMessenger:messenger];
        [eventChannel setStreamHandler:self];
    }
    return self;
}

#pragma mark - Flutter Stream Handler
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)eventSink{
    self.eventSink = eventSink;
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}

#pragma mark - Flutter Method Handler
- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* method = [call method];
    SEL methodSel=NSSelectorFromString([NSString stringWithFormat:@"%@:",method]);
    
    NSArray *arr = @[call,result];
    if([self respondsToSelector:methodSel]){
        IMP imp = [self methodForSelector:methodSel];
        void (*func)(id, SEL, NSArray*) = (void *)imp;
        func(self, methodSel, arr);
    }else{
        result(FlutterMethodNotImplemented);
    }
}


-(void)init:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    
    NOSConfig *conf = [[NOSConfig alloc] init];
    NSDictionary *dic = [call arguments];
    NSNumber *chunkSize = dic[@"chunkSize"];
    if (chunkSize != nil) {
        conf.NOSChunkSize = chunkSize.intValue;
    }
    NSNumber *retryCount = dic[@"retryCount"];
    if (retryCount != nil) {
        conf.NOSRetryCount = retryCount.intValue;
    }
    NSNumber *socketTimeout = dic[@"socketTimeout"];
    if (socketTimeout != nil) {
        conf.NOSSoTimeout = socketTimeout.intValue;
    }
    NSNumber *refreshInterval = dic[@"refreshInterval"];
    if (refreshInterval != nil) {
        conf.NOSRefreshInterval = refreshInterval.intValue;
    }
    NSNumber *monitorInterval = dic[@"monitorInterval"];
    if (monitorInterval != nil) {
        conf.NOSMoniterInterval = monitorInterval.intValue;
    }
    [NOSUploadManager setGlobalConf:conf];
    
    NSError *error = nil;
    NSString *dir = [NSTemporaryDirectory() stringByAppendingString:@"nos-ios-sdk"];
    NSLog(@"%@", dir);
    NOSFileRecorder *file = [NOSFileRecorder fileRecorderWithFolder:dir error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    upManager = [NOSUploadManager sharedInstanceWithRecorder: file
                                        recorderKeyGenerator: nil];
    
    result(nil);
}

- (void)uploadImage:(NSArray*)arr {
    FlutterMethodCall* call = arr.firstObject;
    FlutterResult result = arr[1];
    
    NSDictionary *dic = [call arguments];
    NSString *bucketName = [dic objectForKey:@"bucketName"];
    NSString *objName = [dic objectForKey:@"objName"];
    NSString *uploadToken = [dic objectForKey:@"uploadToken"];
    NSString *imagePath = [dic objectForKey:@"imagePath"];
    
    NOSUploadOption *option = [[NOSUploadOption alloc] initWithMime: @"image/jpeg"
                                                    progressHandler: nil
                                                    metas: nil
                                                    cancellationSignal: ^BOOL {
                                                        return NO;
                                                    }];
    [upManager putFileByHttps: imagePath
                            bucket: bucketName
                            key:objName
                            token: uploadToken
                            complete: ^(NOSResponseInfo *info, NSString *key, NSDictionary *resp) {
                                NSLog(@"上传完成~~");
                                self.eventSink(@{kNosMethod:@"onSuccess", @"message": [NSString stringWithFormat:@"%@", resp.description]});
                            }
                            option: option];
    result(nil);
}

@end

