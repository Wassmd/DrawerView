import UIKit

class DrawerHitAreaView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let receiver = super.hitTest(point, with: event) {
            return receiver
        }

        return nil
    }
}
