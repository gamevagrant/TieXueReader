//
//  TXPageSegmentationController.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-18.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXPageSegmentationController.h"

@interface TXPageSegmentationController ()

@property (nonatomic,strong) NSMutableArray *pageOffset;//当前章节偏移量序列
@property (nonatomic,strong) NSString *filePath;//文件路径
@property (nonatomic,strong) NSDictionary *stringAttribute;//文本数据的格式数据
@property (nonatomic) CGSize pageSize;//页面尺寸



@end

@implementation TXPageSegmentationController
{
    BOOL _allowOffsetHandle;//判断是否允许继续进行偏移量计算
    
    dispatch_queue_t _queue;//串行队列
}

- (id)init
{
    self = [super init];
    if (self) {
        _allowOffsetHandle = YES;
        _queue = dispatch_queue_create("PageSegmentationQueue", NULL);
        _pageOffset = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - geter seter
- (NSInteger)totalPage
{
    return self.pageOffset.count;
}


#pragma mark - 私有方法
//停止当前的分页运算
- (void)stopCurrentOffsetHandle
{
    if (_isRuning) {
        _allowOffsetHandle = NO;
    }
    
}

//查找目标数值
- (NSInteger)binarySearchWithList:(NSArray *)list len:(NSInteger)len target:(unsigned long long)target
{

    for (NSInteger i = 0; i<list.count; i++)
    {
        
        if (target <= [list[i]integerValue] )
        {
            return i ;
        }
    }
    return -1;
}

#pragma mark - 公共方法
//根据页数 返回offset
- (unsigned long long)getOffsetWithPage:(NSUInteger)page
{
    unsigned long long offset;

    if (self.pageOffset.count == 0) {
        offset = 0 ;
    }else
    if (self.pageOffset.count <= page - 1) {
        offset = [[self.pageOffset objectAtIndex:self.pageOffset.count-1] integerValue];
    }else
    {
        offset = [self.pageOffset[page - 1]unsignedLongLongValue];
    }
    
    return offset;
}
//根据现在文件句柄所在位置 查找应该属于第几页 （假定分页数据处理完毕）
- (NSUInteger)getPageWithOffset:(unsigned long long)offset
{
    NSInteger page = [self binarySearchWithList:self.pageOffset len:self.pageOffset.count target:offset] + 1;
    
    return page;
    
}

//根据页数返回需要显示的内容 （假定分页数据处理完毕）
- (NSString *)getContentWithPage:(NSUInteger)pageNum;
{
    if (pageNum > [self.pageOffset count] || pageNum<1) {
		return nil;
	}
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:self.filePath];
    
    unsigned long long offset = 0;
    if (pageNum>1)
    {
        offset = [[self.pageOffset objectAtIndex:pageNum-2] unsignedLongLongValue];
    }
    
    unsigned long long length = [[self.pageOffset objectAtIndex:pageNum-1] unsignedLongLongValue] - offset;
    
    [fileHandle seekToFileOffset:offset];
    NSData *data = [fileHandle readDataOfLength:(NSInteger)length];//读取一段length长度的数据
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];//将数据转成字符串
    str = [str stringByReplacingOccurrencesOfString:@"\r\n\r\n" withString:@"\r\n"];
    str = [str stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n     "];
    
    [fileHandle closeFile];
    return str;
}

//开始分页计算
- (void)setFileWithPath:(NSString *)path attribute:(NSDictionary *)attribute pageSize:(CGSize)pageSize
{
    if (_isRuning) {
        [self stopCurrentOffsetHandle];
    }
    
    self.filePath = path;
    self.stringAttribute = attribute;
    self.pageSize = pageSize;
    self.pageOffset = [[NSMutableArray alloc]init];
//    [self.pageOffset removeAllObjects];
    

    
    
    //异步处理数据 避免影响主线程  反复打开书再返回 会创建多个modle同时处理多本书 有时间再处理
    dispatch_async(_queue, ^{
        _isRuning = YES;
        //在异步处理的时候如果长时间非常快速翻页可能会造成程序奔溃（概率很小）可能是因为处理后续分页合读当前页内容的时候都需要用文件句柄读取指定内容 复制一份文件到缓存文件夹分开处理
        NSString *tempPath = NSTemporaryDirectory();
        tempPath = [tempPath stringByAppendingPathComponent:[path lastPathComponent]];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:tempPath])
        {
            [fm removeItemAtPath:tempPath error:NULL];
        }
        if(![fm copyItemAtPath:path toPath:tempPath error:nil])
        {
            NSLog(@"处理分页：拷贝临时文件失败");
            return;
        }
        
        

        [self handleOffsetListWithPath:tempPath offsetList:self.pageOffset attribute:attribute pageSize:pageSize];
        
        if ([fm fileExistsAtPath:tempPath])
        {
            [fm removeItemAtPath:tempPath error:NULL];
        }
        
        _allowOffsetHandle = YES;
        _isRuning = NO;
    });
    
}

//不进行分页运算 而是把运算结果直接传进来备用
- (void)setFileWithPath:(NSString *)path attribute:(NSDictionary *)attribute pageSize:(CGSize)pageSize offsetList:(NSMutableArray *)offsetList
{
    [self stopCurrentOffsetHandle];
    self.filePath = path;
    self.stringAttribute = attribute;
    self.pageSize = pageSize;
    self.pageOffset = [[NSMutableArray alloc]init];

    self.pageOffset = offsetList;
    [self.delegate updateProgressWithOffsetList:offsetList contentSize:[offsetList[offsetList.count-1] unsignedLongLongValue] progress:1];

    
    
}


#pragma mark - 分页相关方法
//处理分页列表数据
- (void)handleOffsetListWithPath:(NSString *)path offsetList:(NSMutableArray *)offsetList attribute:(NSDictionary *)attribute pageSize:(CGSize)pageSize
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fm attributesOfItemAtPath:path error:nil];
    unsigned long long contentSize = [[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    
    [offsetList removeAllObjects];
    [fileHandle seekToFileOffset:0];
    unsigned long long currentOffset = fileHandle.offsetInFile;//__block 申明的局部变量才能在多线程中更改

    while (currentOffset<contentSize)
    {
        unsigned long long offset = [self offsetOfPage:fileHandle attribute:attribute contentSize:contentSize pageSize:pageSize];
        
        if (!_allowOffsetHandle)
        {
            offsetList = nil;
            
            break;
        }

        [offsetList addObject:[NSNumber numberWithUnsignedLongLong:offset]];
        currentOffset = fileHandle.offsetInFile;
        self.progress = (CGFloat)currentOffset/(CGFloat)contentSize;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate updateProgressWithOffsetList:self.pageOffset contentSize:contentSize progress:self.progress];
        });
        
    }
    [fileHandle closeFile];

}

//取得下一页末尾的offset 分页主算法
- (unsigned long long )offsetOfPage:(NSFileHandle *)handle attribute:(NSDictionary *)attribute contentSize:(unsigned long long)contentSize pageSize:(CGSize)pageSize
{
    BOOL isEndOfFile = NO;
    unsigned long long offset = handle.offsetInFile;
    unsigned long long fileSize = contentSize;
    NSUInteger maxWidth = pageSize.width;
    NSUInteger maxHeigth = pageSize.height;
    NSUInteger length = 512;//截取长度，这个数越小，计算的偏移量越精准，相对运算速度越慢
    NSUInteger appendLength = 0;//附加读取长度 因为读取的长度不可能刚好读取完整最后一个字所以在数据无法生成字符串的时候向后多读取一个或多个字节
    NSMutableString *labelStr = [[NSMutableString alloc] init];
    CGSize viewSize = CGSizeMake(maxWidth, 0);
    do
    {
        
        
        [handle seekToFileOffset:offset];
        NSData *data = [handle readDataOfLength:length + appendLength];//读取一段length长度的数据
        if (data)
        {
            NSString *iStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];//将数据转成字符串
            if (iStr)
            {
                //修改windows回车换行为mac的回车换行
                iStr = [iStr stringByReplacingOccurrencesOfString:@"\r\n\r\n" withString:@"\r\n"];
                iStr = [iStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n     "];
                
                //NSLog(@"有－－%llu－－%i",handle.offsetInFile,appendLength);
                NSString *oStr = [NSString stringWithFormat:@"%@%@",labelStr,iStr];//将新读取的字符串添加到之前读取的文本中
                
                NSAttributedString *aStr = [[NSAttributedString alloc] initWithString:oStr attributes:attribute];
                
                //计算当前文本所占显示空间的大小
                CGSize labelSize = [aStr boundingRectWithSize:viewSize options: NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                
                if (labelSize.height>maxHeigth && length!=1)
                {
                    //将length/2再进行一次检测
                    length = floor(length/2);
                }else if(labelSize.height>maxHeigth && length==1)
                {
                    //增加一个字符刚好炒范围判断为当前字符串刚好到末尾
                    //只有在增加一字节才超范围的时候才能断定到末尾
                    offset = [handle offsetInFile] - length - appendLength;
                    [handle seekToFileOffset:offset];
                    isEndOfFile = YES;
                }
                else
                {
                    //检查是否读到文件末尾
                    if ((offset+length + appendLength) > fileSize)
                    {
                        offset = fileSize;
                        isEndOfFile = YES;
                        [handle seekToEndOfFile];
                        break ;
                    }
                    
                    //继续执行循环
                    offset += length + appendLength;
                    [labelStr appendString:iStr];
                    
                    
                }
                appendLength = 0;
            }else
            {
                appendLength++;
            }
            
        }
        
    } while (!isEndOfFile);
    
    return offset;
}

@end
