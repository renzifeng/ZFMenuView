//
//  LSSelectMenuView.m
//  MyDemo
//
//  Created by  任子丰 on 15/5/8.
//  Copyright (c) 2015年  tsou117. All rights reserved.
//

#import "LSSelectMenuView.h"
/**
 *  屏幕高度
 */
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
/**
 *  屏幕高度
 */
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@implementation LSSelectMenuView
{
    
    BOOL isShow;//YES已展开，NO已收起
    NSInteger selectIndex;//当前选择index
    
    NSInteger itemCount;//按钮个数
    
    CGRect maxShowRect;
    CGRect minShowRect;
}
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize showView = _showView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.frame = frame;
                
        UIView* line1 = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-0.5, frame.size.width, 0.5)];
        line1.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:line1];

    }
    

    
    return self;
}
#pragma mark - SET
- (void)setDataSource:(id<LSSelectMenuViewDataSource>)dataSource{
    _dataSource = dataSource;
    
    itemCount = [_dataSource numberOfItemsInMenuView:self];
    
    float ww = self.frame.size.width/itemCount;
    float hh = self.frame.size.height;
    
    for (int i = 0; i<itemCount; i++) {

        LSButton* btn = [[LSButton alloc] initWithFrame:CGRectMake(ww*i, 0, ww, hh)];
        btn.tag = 100+i;
        [btn setTitle:[_dataSource menuView:self titleForItemAtIndex:i]];
        [btn setMarkImg:[UIImage imageNamed:@"mark1.png"]];
        [btn setMarkAlignment:2];
        [self addSubview:btn];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionOfTap:)];
        [btn addGestureRecognizer:tap];
        
    }
}

- (void)setShowView:(UIView *)showView{
    _showView = showView;
    _showView.clipsToBounds = YES;
    
    maxShowRect = showView.frame;
    
    CGRect rect = _showView.frame;
    rect.size.height = 0;
    _showView.frame = rect;
    
    minShowRect = _showView.frame;
    
    _showView.backgroundColor = [UIColor colorWithRed:0.145 green:0.145 blue:0.145 alpha:0];

//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClose)];
//    [_showView addGestureRecognizer:tap];

    

}
- (void)tapClose{
    [self closeCurrViewOnIndex:selectIndex isCloseShowView:YES];

}

#pragma mark - item选择
- (void)actionOfTap:(UITapGestureRecognizer*)sender{
    
    self.userInteractionEnabled = NO;
    
    LSButton* btn = (LSButton*)sender.view;
    if (isShow)
    {
        //
        if (selectIndex == sender.view.tag-100)
        {
            //移除当前
            [self closeCurrViewOnIndex:selectIndex isCloseShowView:YES];
        }
        else
        {
            //先关闭当前
            [self closeCurrViewOnIndex:selectIndex isCloseShowView:NO];
            
            //展开新的
            [self showTListViewWIthSelectItemView:btn];
        }
    }
    else
    {
        //展开新的
        [self showTListViewWIthSelectItemView:btn];
    }
}

#pragma mark - 展开
- (void)showTListViewWIthSelectItemView:(LSButton*)sender{
    
    selectIndex = sender.tag-100;
    
    //按钮样式变化
    [sender settitleColor:[UIColor colorWithRed:1.000 green:0.502 blue:0.000 alpha:1]];
    [sender setMarkImg:[UIImage imageNamed:@"mark2.png"]];
    
    //背景变化
    [self openShowView];
    
    //动画过度
    [UIView animateWithDuration:DurationTime animations:^{
        sender.markImgView.transform = CGAffineTransformRotate(sender.markImgView.transform, -M_PI);
    } completion:^(BOOL ok){
        if (ok) {

            self.userInteractionEnabled = YES;
        }
    }];
    
    isShow = YES;
    [_delegate selectMenuView:self didSelectAtIndex:selectIndex];
    
    
}

- (void)openShowView{
    
    BOOL mark = [_showView.accessibilityIdentifier boolValue];
    if (!mark) {
        //是展开的
        _showView.frame = maxShowRect;
        _showView.accessibilityIdentifier = @"YES";
        [UIView animateWithDuration:DurationTime animations:^{
            //
            _showView.backgroundColor = [UIColor colorWithRed:0.145 green:0.145 blue:0.145 alpha:0.65];
        }];
    }
    
    //展开当前视图
    UIView* nowView = [_dataSource menuView:self currViewAtIndex:selectIndex];
    if ([nowView isKindOfClass:[UITableView class]]) {
        UITableView * tableView = (UITableView *)nowView;
        tableView.delegate = self;
        tableView.dataSource = self;
    }else if ([nowView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collection = (UICollectionView *)nowView;
        collection.backgroundColor = [UIColor whiteColor];
        collection.delegate = self;
        collection.dataSource = self;
        [collection registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellWithReuseIdentifier:@"Customcell"];
        [collection registerNib:[UINib nibWithNibName:@"CollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    }
    nowView.frame = CGRectMake(0, 0, _showView.frame.size.width, 0);
    nowView.tag = 1000+selectIndex;
    [_showView addSubview:nowView];
    [UIView animateWithDuration:DurationTime animations:^{
        nowView.frame = CGRectMake(0, 0, nowView.frame.size.width, ScreenHeight-108);
    }completion:^(BOOL finished) {
        //
    }];
}

#pragma mark - 收起

- (void)closeCurrViewOnIndex:(NSInteger)index isCloseShowView:(BOOL)isshow{
    
    //关闭当前视图
    LSButton* btn = (LSButton*)[self viewWithTag:100+index];
    [self removeTListViewWithSelectItemView:btn];
    
    UIView* vv = (UIView*)[_showView viewWithTag:1000+selectIndex];
    [UIView animateWithDuration:DurationTime animations:^{
        //
        vv.frame = CGRectMake(0, 0, vv.frame.size.width, 0);
    }completion:^(BOOL finished) {
        //
        [vv removeFromSuperview];
    }];
    
    if (isshow) {
        //关闭背景
        [UIView animateWithDuration:DurationTime animations:^{
            //
            _showView.backgroundColor = [UIColor colorWithRed:0.145 green:0.145 blue:0.145 alpha:0];
            
        }completion:^(BOOL finished) {
            //
            _showView.frame = minShowRect;
            _showView.accessibilityIdentifier = @"NO";
        }];
    }
}

- (void)removeTListViewWithSelectItemView:(LSButton*)sender{
    
    //按钮样式变化
    [sender settitleColor:[UIColor darkGrayColor]];
    [sender setMarkImg:[UIImage imageNamed:@"mark1.png"]];
    
    
    //动画过度
    [UIView animateWithDuration:DurationTime animations:^{
        sender.markImgView.transform = CGAffineTransformRotate(sender.markImgView.transform, M_PI);
    } completion:^(BOOL ok){
        if (ok) {
            self.userInteractionEnabled = YES;

        }
    
    }];
    isShow = NO;
    [_delegate selectMenuView:self didRemoveAtIndex:selectIndex];
}


#pragma mark - //在当前视图的操作中如需关闭视图，执行此方法
- (void)closeCurrViewWithIndex:(NSInteger)index{
    
    
    
    LSButton* btn = (LSButton*)[self viewWithTag:100+index];
    UIView* vv = (UIView*)[_showView viewWithTag:1000+index];
    
    //关闭当前视图
    //按钮样式变化
    [btn settitleColor:[UIColor darkGrayColor]];
    [btn setMarkImg:[UIImage imageNamed:@"mark1.png"]];
    
    
    //动画过度
    [UIView animateWithDuration:DurationTime animations:^{
        btn.markImgView.transform = CGAffineTransformRotate(btn.markImgView.transform, M_PI);
    } completion:^(BOOL ok){
        if (ok) {
            self.userInteractionEnabled = YES;
            
        }
        
    }];
    isShow = NO;
    
    [UIView animateWithDuration:DurationTime animations:^{
        //
        _showView.backgroundColor = [UIColor colorWithRed:0.145 green:0.145 blue:0.145 alpha:0];
        vv.frame = CGRectMake(0, 0, vv.frame.size.width, 0);
    }completion:^(BOOL finished) {
        //
        _showView.frame = minShowRect;
        _showView.accessibilityIdentifier = @"NO";
        [vv removeFromSuperview];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellID = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"第%zd行",indexPath.row+1];
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tapClose];
    LSButton* btn = (LSButton*)[self viewWithTag:100+selectIndex];
    [btn setTitle:[NSString stringWithFormat:@"第%zd个，%zd行",selectIndex,indexPath.row+1]];
}

#pragma mark - CollectionView Delagate

//设置分区
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CustomCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Customcell" forIndexPath:indexPath];
    return cell;
}
//header与footer(也是采用重用机制) 增补视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //从重用队列中取可用的header,如果没有到上边的注册,会帮我们创建
    CollectionHeaderView * reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
    return reusableView;
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self tapClose];
    LSButton* btn = (LSButton*)[self viewWithTag:100+selectIndex];
    [btn setTitle:[NSString stringWithFormat:@"第%zd个，%zd行",selectIndex,indexPath.row+1]];

}
@end
