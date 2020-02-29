import UIKit

/// Class that dismisses every touch, causing the Hit testing to be propagated to the next View
class TouchDismisserView: UIView {

    // MARK: - Overrides

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)

        if hitView == self {
            return nil
        } else {
            return hitView
        }
    }
}
