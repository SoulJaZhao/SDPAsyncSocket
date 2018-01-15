#import <Foundation/Foundation.h>

// 第三方库 for TCP
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@class SDPAsyncSocket;
@protocol   SDPAsyncSocketDelegate <NSObject>
@optional
/*
 *  连接完成
 *  @param  aSocket    SDPAsyncSocket
 */
- (void)socketDidConnectToServer:(SDPAsyncSocket *)aSocket;

/*
 *  写入完成
 *  @param  aSocket    SDPAsyncSocket
 */
- (void)socketDidSendToServer:(SDPAsyncSocket *)aSocket;

/*
 *  读取数据完成
 *  @param  aSocket    SDPAsyncSocket
 *  @param  aData      数据
 */
- (void)socket:(SDPAsyncSocket *)aSocket DidReceiveData:(NSData *)aData;

/*
 *  断开连接报错
 *  @param  aSocket    SDPAsyncSocket
 *  @param  aError     错误
 */
- (void)socket:(SDPAsyncSocket *)aSocket DidDisconnectWithError:(NSError *)aError;
@end

extern NSInteger const SDPTimeoutSocketConnect;// 连接socket的超时时间
extern NSInteger const SDPTimeoutSocketWrite;// 写入Socket的超时时间
extern NSInteger const SDPTimeoutSocketRead;// 读取Socket的超时时间

extern NSInteger const SDPTagSocketWrite;// 写入Socket的Tag
extern NSInteger const SDPTagSocketReadHeader;// 读取Socket的Tag
extern NSInteger const SDPTagSocketReadBody;// 读取Socket的Tag

extern NSInteger const SDPLengthSocketHeader;// SocketHeader的长度

@interface SDPAsyncSocket : NSObject
/**  连接地址 **/
@property (copy, nonatomic) NSString *host;
/**  端口 **/
@property (assign, nonatomic) NSInteger port;
/**  备用主机 **/
@property (copy, nonatomic) NSString *backUpHost;
/**  备用端口 **/
@property (assign, nonatomic) NSInteger backUpPort;
/**  代理 **/
@property (nonatomic, weak) id<SDPAsyncSocketDelegate> delegate;

/*
 *  初始化方法
 *  @param  aHost           主机
 *  @param  aPort           端口
 *  @param  aBackUpHost     备用主机
 *  @param  aBackUpPort     备用端口
 *  @param  aDelegate       代理
 *  @return SDPAsyncSocket  socket对象
 */
- (instancetype)initWithHost:(NSString *)aHost
                        Port:(NSInteger)aPort
                  BackUpHost:(NSString *)aBackUpHost
                  BackUpPort:(NSInteger)aBackUpPort
                    Delegate:(id<SDPAsyncSocketDelegate>)aDelegate;

/**
 *  连接socket方法
 *  @return BOOL 是否连接成功
 */
- (BOOL)connect;

/*
 *  发送数据
 *  @param  aData    数据
 */
- (void)sendData:(NSData *)aData;

/*
 *  断开连接
 */
- (void)disconnect;
@end
