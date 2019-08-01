import UIKit

extension SwipeCollectionKitCell {
    public var swipeOffset: CGFloat {
        set { setSwipeOffset(newValue, animated: false) }
        get { return frame.midX - bounds.midX }
    }

    public func hideSwipe(animated: Bool, completion: ((Bool) -> Void)? = nil) {
        swipeController.hideSwipe(animated: animated, completion: completion)
    }
    
    public func showSwipe(orientation: SwipeActionsOrientation, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        setSwipeOffset(.greatestFiniteMagnitude * orientation.scale * -1,
                       animated: animated,
                       completion: completion)
    }
    
    public func setSwipeOffset(_ offset: CGFloat, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        swipeController.setSwipeOffset(offset, animated: animated, completion: completion)
    }
}
