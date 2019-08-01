import UIKit
import CollectionKit

public protocol SwipeCollectionKitCellDelegate: class {
    func collectionView(_ collectionView: CollectionView, editActionsForItemAt index: Int, for orientation: SwipeActionsOrientation) -> [SwipeAction]?
    func collectionView(_ collectionView: CollectionView, editActionsOptionsForItemAt index: Int, for orientation: SwipeActionsOrientation) -> SwipeOptions
    func collectionView(_ collectionView: CollectionView, willBeginEditingItemAt index: Int, for orientation: SwipeActionsOrientation)
    func collectionView(_ collectionView: CollectionView, didEndEditingItemAt index: Int, for orientation: SwipeActionsOrientation)
    func visibleRect(for collectionView: CollectionView) -> CGRect?
}

public extension SwipeCollectionKitCellDelegate {
    func collectionView(_ collectionView: CollectionView, editActionsOptionsForItemAt index: Int, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        return SwipeOptions()
    }
    func collectionView(_ collectionView: CollectionView, willBeginEditingItemAt index: Int, for orientation: SwipeActionsOrientation) {}
    func collectionView(_ collectionView: CollectionView, didEndEditingItemAt index: Int, for orientation: SwipeActionsOrientation) {}
    func visibleRect(for collectionView: CollectionView) -> CGRect? {
        return nil
    }
}
