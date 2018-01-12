//
//  SDPAsyncSocket.m
//  Pods
//
//  Created by SoulJa on 2018/1/12.
//

#import "SDPAsyncSocket.h"

NSInteger const SDPTimeoutSocketConnect = 60;
NSInteger const SDPTimeoutSocketWrite = 60;
NSInteger const SDPTimeoutSocketRead = 60;

NSInteger const SDPTagSocketWrite = 1;
NSInteger const SDPTagSocketReadHeader = 2;
NSInteger const SDPTagSocketReadBody = 3;

NSInteger const SDPLengthSocketHeader = 2;

@interface SDPAsyncSocket()<GCDAsyncSocketDelegate>
/** socket **/
@property (strong, nonatomic) GCDAsyncSocket *socket;
/** ResponseBody的长度 **/
@property (assign, nonatomic) NSInteger responseBodyLength;
@end

@implementation SDPAsyncSocket
#pragma mark - 初始化方法
- (instancetype)initWithHost:(NSString *)aHost
                        Port:(NSInteger)aPort
                  BackUpHost:(NSString *)aBackUpHost
                  BackUpPort:(NSInteger)aBackUpPort
                    Delegate:(id<SDPAsyncSocketDelegate>)aDelegate {
    self = [super init];
    if (self) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _host = aHost;
        _port = aPort;
        _backUpHost = aBackUpHost;
        _backUpPort = aBackUpPort;
        _delegate = aDelegate;
    }
    return self;
}

#pragma mark - 链接socket
- (BOOL)connect {
    // 链接socket
    BOOL isConnected = [_socket connectToHost:_host onPort:_port withTimeout:SDPTimeoutSocketConnect error:nil];
    if (isConnected) {
        return YES;
    } else {
        return [_socket connectToHost:_backUpHost onPort:_backUpPort error:nil];
    }
}

#pragma mark - 发送数据
- (void)sendData:(NSData *)aData {
    if (_socket == nil) {
        return;
    }
    [_socket writeData:aData withTimeout:SDPTimeoutSocketWrite tag:SDPTagSocketWrite];
}

#pragma mark - GCDAsyncSocketDelegate
// 连接Socket回调
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    if (_delegate && [_delegate respondsToSelector:@selector(socketDidConnectToServer:)]) {
        [_delegate socketDidConnectToServer:self];
    }
}

// 写入回调
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (_delegate && [_delegate respondsToSelector:@selector(socketDidSendToServer:)]) {
        [_delegate socketDidSendToServer:self];
    }
    // 读取数据
    [sock readDataToLength:SDPLengthSocketHeader withTimeout:SDPTimeoutSocketRead tag:SDPTagSocketReadHeader];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // TagReadHeader 用于计算Body的长度
    if (tag == SDPTagSocketReadHeader) {
        Byte lengthBytes[] = {0x00, 0x00};
        [data getBytes:lengthBytes length:sizeof(lengthBytes)/sizeof(lengthBytes[0])];
        NSInteger multipler = lengthBytes[0];
        NSInteger remainder = lengthBytes[1];
        NSInteger length = (multipler << 8) + remainder;// multipler * 256 + remainder
        self.responseBodyLength = length;
        [_socket readDataToLength:length withTimeout:SDPTimeoutSocketRead tag:SDPTagSocketReadBody];
    }
    // kagReadBody
    else if (tag == SDPTagSocketReadBody) {
        Byte *bodyBytes = (Byte *)malloc(self.responseBodyLength);
        memcpy(bodyBytes, [data bytes], self.responseBodyLength);
        Byte *pBody = bodyBytes + 11;
        NSData *bodyData = [NSData dataWithBytes:pBody length:self.responseBodyLength - 11];
        if (_delegate && [_delegate respondsToSelector:@selector(socket:DidReceiveData:)]) {
            [_delegate socket:self DidReceiveData:bodyData];
        }
        free(bodyBytes);
    }
}
@end

