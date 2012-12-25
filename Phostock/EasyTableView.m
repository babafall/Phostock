//
//  EasyTableView.m
//  EasyTableView
//
//  Created by Aleksey Novicov on 5/30/10.
//  Copyright 2010 Yodel Code. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EasyTableView.h"
#import "UIImageView+AFNetworking.h"

#define ANIMATION_DURATION	0.30

#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_5_0
#define kCFCoreFoundationVersionNumber_iPhoneOS_5_0 675.000000
#endif

@interface EasyTableView (PrivateMethods)
- (void)createTableWithOrientation:(EasyTableViewOrientation)orientation;
- (void)prepareRotatedView:(UIView *)rotatedView;
- (void)setDataForRotatedView:(UIView *)rotatedView forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation EasyTableView

@synthesize delegate, cellBackgroundColor;
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize orientation = _orientation;
@synthesize numberOfCells = _numItems;

#pragma mark -
#pragma mark Initialization


- (id)initWithFrame:(CGRect)frame numberOfColumns:(NSUInteger)numCols ofWidth:(CGFloat)width {
    if (self = [super initWithFrame:frame]) {
		_numItems			= numCols;
		_cellWidthOrHeight	= width;
		
		[self createTableWithOrientation:EasyTableViewOrientationHorizontal];
	}
    return self;
}


- (id)initWithFrame:(CGRect)frame numberOfRows:(NSUInteger)numRows ofHeight:(CGFloat)height {
    if (self = [super initWithFrame:frame]) {
		_numItems			= numRows;
		_cellWidthOrHeight	= height;
		
		[self createTableWithOrientation:EasyTableViewOrientationVertical];
    }
    return self;
}


- (void)createTableWithOrientation:(EasyTableViewOrientation)orientation {
	// Save the orientation so that the table view cell knows how to set itself up
	_orientation = orientation;
	
	UITableView *tableView;
	if (orientation == EasyTableViewOrientationHorizontal) {
		int xOrigin	= (self.bounds.size.width - self.bounds.size.height)/2;
		int yOrigin	= (self.bounds.size.height - self.bounds.size.width)/2;
		tableView	= [[UITableView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, self.bounds.size.height, self.bounds.size.width)];
	}
	else
		tableView	= [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
	
	tableView.tag				= TABLEVIEW_TAG;
	tableView.delegate			= self;
	tableView.dataSource		= self;
	tableView.autoresizingMask	= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Rotate the tableView 90 degrees so that it is horizontal
	if (orientation == EasyTableViewOrientationHorizontal)
		tableView.transform	= CGAffineTransformMakeRotation(-M_PI/2);
	
	tableView.showsVerticalScrollIndicator	 = NO;
	tableView.showsHorizontalScrollIndicator = NO;
	
	[self addSubview:tableView];
}


#pragma mark -
#pragma mark Properties

- (UITableView *)tableView {
	return (UITableView *)[self viewWithTag:TABLEVIEW_TAG];
}


- (NSArray *)visibleViews {
	NSArray *visibleCells = [self.tableView visibleCells];
	NSMutableArray *visibleViews = [NSMutableArray arrayWithCapacity:[visibleCells count]];
	
	for (UIView *aView in visibleCells) {
		[visibleViews addObject:[aView viewWithTag:CELL_CONTENT_TAG]];
	}
	return visibleViews;
}


- (CGPoint)contentOffset {
	CGPoint offset = self.tableView.contentOffset;
	
	if (_orientation == EasyTableViewOrientationHorizontal)
		offset = CGPointMake(offset.y, offset.x);
	
	return offset;
}


- (void)setContentOffset:(CGPoint)offset {
	if (_orientation == EasyTableViewOrientationHorizontal)
		self.tableView.contentOffset = CGPointMake(offset.y, offset.x);
	else
		self.tableView.contentOffset = offset;
}


- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
	CGPoint newOffset;
	
	if (_orientation == EasyTableViewOrientationHorizontal) {
		newOffset = CGPointMake(offset.y, offset.x);
	}
	else {
		newOffset = offset;
	}
	[self.tableView setContentOffset:newOffset animated:animated];
}


#pragma mark -
#pragma mark Selection

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
	self.selectedIndexPath	= indexPath;
	CGPoint defaultOffset	= CGPointMake(0, indexPath.row  *_cellWidthOrHeight);
    int total = [delegate numberOfCellsForEasyTableView:self inSection:indexPath.section];
    if (indexPath.row > total - 5)
    {
        int rollBack = 5 - (total - indexPath.row);
        defaultOffset.y -= _cellWidthOrHeight * rollBack;
    }
    
	
	[self.tableView setContentOffset:defaultOffset animated:animated];
}
- (void)deselectAll
{
    if (_selectedIndexPath)
    {
        [self.tableView deselectRowAtIndexPath:_selectedIndexPath animated:NO];
        _selectedIndexPath = nil;
    }
}

- (void)setSelectedIndexPath:(NSIndexPath *)indexPath {
	if (![_selectedIndexPath isEqual:indexPath]) {
		NSIndexPath *oldIndexPath = [_selectedIndexPath copy];
		
		_selectedIndexPath = indexPath;
		
		UITableViewCell *deselectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:oldIndexPath];
		UITableViewCell *selectedCell	= (UITableViewCell *)[self.tableView cellForRowAtIndexPath:_selectedIndexPath];
		
		if ([delegate respondsToSelector:@selector(easyTableView:selectedView:atIndexPath:deselectedView:)]) {
			UIView *selectedView = [selectedCell viewWithTag:CELL_CONTENT_TAG];
			UIView *deselectedView = [deselectedCell viewWithTag:CELL_CONTENT_TAG];
			
			[delegate easyTableView:self
					   selectedView:selectedView
						atIndexPath:_selectedIndexPath
					 deselectedView:deselectedView];
		}
	}
}

#pragma mark -
#pragma mark Multiple Sections

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
        UIView *headerView = [delegate easyTableView:self viewForHeaderInSection:section];
		if (_orientation == EasyTableViewOrientationHorizontal)
			return headerView.frame.size.width;
		else 
			return headerView.frame.size.height;
    }
    return 0.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
        UIView *footerView = [delegate easyTableView:self viewForFooterInSection:section];
		if (_orientation == EasyTableViewOrientationHorizontal)
			return footerView.frame.size.width;
		else 
			return footerView.frame.size.height;
    }
    return 0.0;
}

- (UIView *)viewToHoldSectionView:(UIView *)sectionView {
	// Enforce proper section header/footer view height abd origin. This is required because
	// of the way UITableView resizes section views on orientation changes.
	if (_orientation == EasyTableViewOrientationHorizontal)
		sectionView.frame = CGRectMake(0, 0, sectionView.frame.size.width, self.frame.size.height);
	
	UIView *rotatedView = [[UIView alloc] initWithFrame:sectionView.frame];
	
	if (_orientation == EasyTableViewOrientationHorizontal) {
		rotatedView.transform = CGAffineTransformMakeRotation(M_PI/2);
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	}
	else {
		sectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}
	[rotatedView addSubview:sectionView];
	return rotatedView;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(easyTableView:viewForHeaderInSection:)]) {
		UIView *sectionView = [delegate easyTableView:self viewForHeaderInSection:section];
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([delegate respondsToSelector:@selector(easyTableView:viewForFooterInSection:)]) {
		UIView *sectionView = [delegate easyTableView:self viewForFooterInSection:section];
		return [self viewToHoldSectionView:sectionView];
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([delegate respondsToSelector:@selector(numberOfSectionsInEasyTableView:)]) {
        return [delegate numberOfSectionsInEasyTableView:self];
    }
    return 1;
}

#pragma mark -
#pragma mark Location and Paths

- (UIView *)viewAtIndexPath:(NSIndexPath *)indexPath {
	UIView *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	return [cell viewWithTag:CELL_CONTENT_TAG];
}

- (NSIndexPath *)indexPathForView:(UIView *)view {
	NSArray *visibleCells = [self.tableView visibleCells];
	
	__block NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	[visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		UITableViewCell *cell = obj;
        if (cell == view)
        {
            indexPath = [self.tableView indexPathForCell:cell];
			*stop = YES;
        }
		if ([cell viewWithTag:CELL_CONTENT_TAG] == view) {
            indexPath = [self.tableView indexPathForCell:cell];
			*stop = YES;
		}
	}];
	return indexPath;
}

- (CGPoint)offsetForView:(UIView *)view {
	// Get the location of the cell
	CGPoint cellOrigin = [view convertPoint:view.frame.origin toView:self];
	
	// No need to compensate for orientation since all values are already adjusted for orientation
	return cellOrigin;
}

#pragma mark -
#pragma mark TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self setSelectedIndexPath:indexPath];
    if ([delegate respondsToSelector:@selector(easyTableView:didSelectRowAtIndexPath:)])
    {
        [delegate easyTableView:self didSelectRowAtIndexPath:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([delegate respondsToSelector:@selector(easyTableView:heightOrWidthForCellAtIndexPath:)]) {
        return [delegate easyTableView:self heightOrWidthForCellAtIndexPath:indexPath];
    }
    return _cellWidthOrHeight;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if ([delegate respondsToSelector:@selector(easyTableView:scrolledToOffset:)])
		[delegate easyTableView:self scrolledToOffset:self.contentOffset];
}


#pragma mark -
#pragma mark TableViewDataSource

- (void)setCell:(UITableViewCell *)cell boundsForOrientation:(EasyTableViewOrientation)theOrientation {
	if (theOrientation == EasyTableViewOrientationHorizontal) {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.height, _cellWidthOrHeight);
	}
	else {
		cell.bounds	= CGRectMake(0, 0, self.bounds.size.width, _cellWidthOrHeight);
	}
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"EasyTableViewCell"];
    UIImageView * targetView = nil;
    UIActivityIndicatorView * activity = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EasyTableViewCell"];
		
		[self setCell:cell boundsForOrientation:_orientation];
		cell.contentView.tag = CELL_CONTENT_TAG;
		cell.contentView.frame = cell.bounds;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// Add a view to the cell's content view that is rotated to compensate for the table view rotation
		CGRect viewRect;
		viewRect = CGRectMake(0, 0, _cellWidthOrHeight, _cellWidthOrHeight);
        
		targetView		= [[UIImageView alloc] initWithFrame:viewRect];
		targetView.tag					= ROTATED_CELL_VIEW_TAG;
		targetView.center				= cell.contentView.center;
		targetView.backgroundColor		= self.cellBackgroundColor;
		
		if (_orientation == EasyTableViewOrientationHorizontal) {
			targetView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			targetView.transform = CGAffineTransformMakeRotation(M_PI/2);
		}
		else 
			targetView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

		targetView.clipsToBounds = YES;
        
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activity.frame = CGRectMake((targetView.frame.size.width    - activity.frame.size.width) / 2,
                                    (targetView.frame.size.height   - activity.frame.size.height) / 2,
                                    activity.frame.size.width, activity.frame.size.height);
        activity.tag = ANIMATION_TAG;
        [targetView addSubview:activity];
        [activity startAnimating];
        [activity setHidesWhenStopped:YES];
		
		[cell.contentView addSubview:targetView];
	}
    UIImage * imageToSet = nil;
    if ([delegate respondsToSelector:@selector(easyTableView:imageForCellAtIndexPath:cell:)])
    {
        imageToSet = [delegate easyTableView:self imageForCellAtIndexPath:indexPath cell:cell];
    }
    else if ([delegate respondsToSelector:@selector(easyTableView:imageForCellAtIndexPath:)])
    {
        imageToSet = [delegate easyTableView:self imageForCellAtIndexPath:indexPath];
    }
    [self setImage:imageToSet forCell:cell atIndexPath:indexPath];
    return cell;
}
-(void) setImage:(UIImage*) img forCell:(UITableViewCell*)cell
{
    [self setImage:img forCell:cell atIndexPath:[self indexPathForView:cell]];
}
-(void) setImage:(UIImage*) img forCell:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath
{
    UIImageView * targetView = nil;
    UIActivityIndicatorView * activity = nil;
    targetView = (UIImageView*)[cell.contentView viewWithTag:ROTATED_CELL_VIEW_TAG];
    activity = (UIActivityIndicatorView *)[targetView viewWithTag:ANIMATION_TAG];
    
	[self setCell:cell boundsForOrientation:_orientation];
    
    if (img) {
        [activity stopAnimating];
        CGSize imageSize = [delegate easyTableView:self sizeForImageAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0 ]];
        targetView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        [targetView setImage:img];
        if (_lastLoaded < indexPath.row)
        {
            _lastLoaded = indexPath.row;
IF_IOS5_OR_GREATER(
            targetView.alpha = 0;
            runOnMainQueueWithoutDeadlocking(^{
                [UIView animateWithDuration:0.3 animations:^{
                    targetView.alpha = 1;
                }];
            });
                   );
        }
        if(self.selectedMask)
        {
            if (self.selectedIndexPath.row == indexPath.row)
            {
                [self.selectedMask removeFromSuperview];
                [cell addSubview:self.selectedMask];
            }
            else if([cell.subviews containsObject:self.selectedMask])
                [self.selectedMask removeFromSuperview];
        }
    }
    else
    {
        [activity startAnimating];
        [targetView setImage:nil];
    }

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUInteger numOfItems = _numItems;
	
	if ([delegate respondsToSelector:@selector(numberOfCellsForEasyTableView:inSection:)]) {
		numOfItems = [delegate numberOfCellsForEasyTableView:self inSection:section];
	}
	
    return numOfItems;
}

-(void)reloadData{
    [self.tableView reloadData];
}
-(void)clear
{
    _lastLoaded = 0;
}

@end

