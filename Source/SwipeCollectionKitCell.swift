import UIKit
import CollectionKit

open class SwipeCollectionKitCell: UIView {
    public weak var delegate: SwipeCollectionKitCellDelegate?
    
    var state = SwipeState.center
    var actionsView: SwipeActionsView?
    var scrollView: UIScrollView? {
        return collectionView
    }
    var indexPath: IndexPath? {
        if let index = self.index {
            return IndexPath(row: index, section: 0)
        } else {
            return nil
        }
    }
    var index: Int? {
        return collectionView?.index(for: self)
    }
    var panGestureRecognizer: UIGestureRecognizer {
        return swipeController.panGestureRecognizer
    }
    
    var swipeController: SwipeController!
    
    weak var collectionView: CollectionView?
    
    open override var frame: CGRect {
        set { super.frame = state.isActive ? CGRect(origin: CGPoint(x: frame.minX, y: newValue.minY), size: newValue.size) : newValue }
        get { return super.frame }
    }
    
    /// :nodoc:
    open override var layoutMargins: UIEdgeInsets {
        get {
            return frame.origin.x != 0 ? swipeController.originalLayoutMargins : super.layoutMargins
        }
        set {
            super.layoutMargins = newValue
        }
    }
    
    /// :nodoc:
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    /// :nodoc:
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    deinit {
        collectionView?.panGestureRecognizer.removeTarget(self, action: nil)
    }
    
    func configure() {
        clipsToBounds = false
        
        swipeController = SwipeController(swipeable: self, actionsContainerView: self)
        swipeController.delegate = self
    }
    
    /// :nodoc:
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        var view: UIView = self
        while let superview = view.superview {
            view = superview
            
            if let collectionView = view as? CollectionView {
                self.collectionView = collectionView
                
                swipeController.scrollView = scrollView
                
                collectionView.panGestureRecognizer.removeTarget(self, action: nil)
                collectionView.panGestureRecognizer.addTarget(self, action: #selector(handleCollectionPan(gesture:)))
                return
            }
        }
    }
    
    /// :nodoc:
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow == nil {
            reset()
        }
    }
    
    // Override so we can accept touches anywhere within the cell's original frame.
    // This is required to detect touches on the `SwipeActionsView` sitting alongside the
    // `SwipeCollectionViewCell`.
    /// :nodoc:
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superview = superview else { return false }
        
        let point = convert(point, to: superview)
        
        if !UIAccessibility.isVoiceOverRunning {
            for cell in collectionView?.swipeCells ?? [] {
                if (cell.state == .left || cell.state == .right) && !cell.contains(point: point) {
                    collectionView?.hideSwipeCell()
                    return false
                }
            }
        }
        
        return contains(point: point)
    }
    
    func contains(point: CGPoint) -> Bool {
        return frame.contains(point)
    }
    
    // Override hitTest(_:with:) here so that we can make sure our `actionsView` gets the touch event
    //   if it's supposed to, since otherwise, our `contentView` will swallow it and pass it up to
    //   the collection view.
    /// :nodoc:
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard
            let actionsView = actionsView,
            isHidden == false
            else { return super.hitTest(point, with: event) }
        
        let modifiedPoint = actionsView.convert(point, from: self)
        return actionsView.hitTest(modifiedPoint, with: event) ?? super.hitTest(point, with: event)
    }
    
    /// :nodoc:
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return swipeController.gestureRecognizerShouldBegin(gestureRecognizer)
    }
    
    /// :nodoc:
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        swipeController.traitCollectionDidChange(from: previousTraitCollection, to: self.traitCollection)
    }
    
    @objc func handleCollectionPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            hideSwipe(animated: true)
        }
    }
    
    func reset() {
        clipsToBounds = false
        swipeController.reset()
        collectionView?.setGestureEnabled(true)
    }
}

extension SwipeCollectionKitCell: SwipeControllerDelegate {
    func swipeController(_ controller: SwipeController, canBeginEditingSwipeableFor orientation: SwipeActionsOrientation) -> Bool {
        return true
    }
    
    func swipeController(_ controller: SwipeController, editActionsForSwipeableFor orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let collectionView = collectionView, let index = self.index else { return nil }
        
        return delegate?.collectionView(collectionView, editActionsForItemAt: index, for: orientation)
    }
    
    func swipeController(_ controller: SwipeController, editActionsOptionsForSwipeableFor orientation: SwipeActionsOrientation) -> SwipeOptions {
        guard let collectionView = collectionView, let index = self.index else { return SwipeOptions() }
        
        return delegate?.collectionView(collectionView, editActionsOptionsForItemAt: index, for: orientation) ?? SwipeOptions()
    }
    
    func swipeController(_ controller: SwipeController, visibleRectFor scrollView: UIScrollView) -> CGRect? {
        guard let collectionView = collectionView else { return nil }
        
        return delegate?.visibleRect(for: collectionView)
    }
    
    func swipeController(_ controller: SwipeController, willBeginEditingSwipeableFor orientation: SwipeActionsOrientation) {
        guard let collectionView = collectionView, let index = self.index else { return }
        delegate?.collectionView(collectionView, willBeginEditingItemAt: index, for: orientation)
    }
    
    func swipeController(_ controller: SwipeController, didEndEditingSwipeableFor orientation: SwipeActionsOrientation) {
        guard let collectionView = collectionView, let index = self.index, let actionsView = self.actionsView else { return }
        
        delegate?.collectionView(collectionView, didEndEditingItemAt: index, for: actionsView.orientation)
    }
    
    func swipeController(_ controller: SwipeController, didDeleteSwipeableAt indexPath: IndexPath) {
        // TODO: improve delete animation
//        collectionView?.deleteItems(at: [indexPath])
    }
}

extension SwipeCollectionKitCell: Swipeable {}

extension SwipeCollectionKitCell: CollectionViewReusableView {
    public func prepareForReuse() {
        reset()
    }
}

extension CollectionView {
    var swipeCells: [SwipeCollectionKitCell] {
        return visibleCells.compactMap({ $0 as? SwipeCollectionKitCell })
    }
    
    func hideSwipeCell() {
        swipeCells.forEach { $0.hideSwipe(animated: true) }
    }
    
    func setGestureEnabled(_ enabled: Bool) {
        gestureRecognizers?.forEach {
            guard $0 != panGestureRecognizer else { return }
            
            $0.isEnabled = enabled
        }
    }
}
