
#import <UIKit/UIKit.h>

/**
 Provides extensions for `UIView`.
 */
@interface UIView (XHAdd)

/**
 Create a snapshot image of the complete view hierarchy.
 */
- (UIImage *)xh_snapshotImage;

/**
 Create a snapshot image of the complete view hierarchy.
 @discussion It's faster than "snapshotImage", but may cause screen updates.
 See -[UIView drawViewHierarchyInRect:afterScreenUpdates:] for more information.
 */
- (UIImage *)xh_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

/**
 Remove all subviews.
 
 @warning Never call this method inside your view's drawRect: method.
 */
- (void)xh_removeAllSubviews;

/**
 Returns the view's view controller (may be nil).
 */
@property (nonatomic, readonly) UIViewController *xh_viewController;

@property (nonatomic) CGFloat xh_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat xh_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat xh_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat xh_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat xh_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat xh_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat xh_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat xh_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint xh_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  xh_size;        ///< Shortcut for frame.size.

@end
