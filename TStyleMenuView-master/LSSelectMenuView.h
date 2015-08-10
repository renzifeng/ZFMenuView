//
//  LSSelectMenuView.h
//  MyDemo
//
//  Created by  任子丰 on 15/5/8.
//  Copyright (c) 2015年  tsou117. All rights reserved.
//

#define DurationTime 0.35

#import <UIKit/UIKit.h>
#import "LSButton.h"
#import "CustomCell.h"
#import "CollectionHeaderView.h"

@class LSSelectMenuView;

@protocol LSSelectMenuViewDataSource <NSObject>

- (NSInteger)numberOfItemsInMenuView:(LSSelectMenuView*)menuview;

- (NSString*)menuView:(LSSelectMenuView*)menuview titleForItemAtIndex:(NSInteger)index;

- (CGFloat)menuView:(LSSelectMenuView*)menuview heightForCurrViewAtIndex:(NSInteger)index;
- (UIView*)menuView:(LSSelectMenuView*)menuview currViewAtIndex:(NSInteger)index;
@end

@protocol LSSelectMenuViewDelegate <NSObject>

//
- (void)selectMenuView:(LSSelectMenuView*)selectmenuview didSelectAtIndex:(NSInteger)index;
- (void)selectMenuView:(LSSelectMenuView *)selectmenuview didRemoveAtIndex:(NSInteger)index;

@end

@interface LSSelectMenuView : UIView<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,weak) id<LSSelectMenuViewDelegate> delegate;
@property (nonatomic,weak) id<LSSelectMenuViewDataSource> dataSource;
@property (nonatomic,strong) UIView* showView;//背景层

- (void)closeCurrViewWithIndex:(NSInteger)index;//在当前视图的操作中如需关闭视图，执行此方法

@end
