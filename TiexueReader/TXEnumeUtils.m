//
//  TXEnumeUtils.m
//  TiexueReader
//
//  Created by 齐宇 on 14-4-14.
//  Copyright (c) 2014年 tiexue. All rights reserved.
//

#import "TXEnumeUtils.h"

@implementation TXEnumeUtils
+ (NSString *)getBookListTypeName:(TXBookListType)type
{
    NSString *name;
    switch (type) {
        case TX_ENUME_MALL_BOOKLIST_TYPE_QIANG_TUI:
            name = @"本周强推";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_JING_DIAN:
            name = @"经典全本";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_RE_XIAO:
            name = @"24小时热销";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_MIAN_FEI:
            name = @"免费全本";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_JUN_SHI:
            name = @"军事小说";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_LI_SHI:
            name = @"历史小说";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_XIN_SHU:
            name = @"潜力新书";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_GENG_DUO:
            name = @"更多爽文";
            break;
          
        case TX_ENUME_MALL_BOOKLIST_TYPE_END_TE_HUI:
            name = @"全本特惠";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_END_MIAN_FEI:
            name = @"全本免费";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_END_QUAN_BU:
            name = @"全本全部";
            break;
            
        case TX_ENUME_MALL_BOOKLIST_TYPE_RANK_DIAN_JI:
            name = @"点击排行";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_RANK_RE_XIAO:
            name = @"热销排行";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_RANK_GENG_XIN:
            name = @"更新排行";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_RANK_JUN_SHI:
            name = @"军事排行";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_RANK_LI_SHI:
            name = @"历史排行";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_RANK_SHOU_CANG:
            name = @"收藏排行";
            break;
            
        case TX_ENUME_MALL_BOOKLIST_TYPE_KIND_JUNSHI:
            name = @"军事小说";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_KIND_LISHI:
            name = @"历史小说";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_KIND_XUANHUAN:
            name = @"玄幻小说";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_KIND_XIANXIA:
            name = @"仙侠小说";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_KIND_DUSHI:
            name = @"都市小说";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_KIND_QINGGAN:
            name = @"情感小说";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_KIND_TUILI:
            name = @"推理小说";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_KIND_XUANYI:
            name = @"悬疑小说";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_KIND_DUANPIAN:
            name = @"短片小说";
            break;
        case TX_ENUME_MALL_BOOKLIST_TYPE_KIND_CHUBAN:
            name = @"出版小说";
            break;
        default:
            break;
    }
    return name;
}

+ (NSString *)getBookStatusName:(TXBookStatus)status
{
    NSString *name;
    switch (status) {
        case TX_BOOK_STATUS_LIANZAI:
            name = @"连载";
            break;
        case TX_BOOK_STATUS_WANBEN:
            name = @"完本";
            break;
        
        default:
            break;
    }
    return name;
}
@end
