import UIKit

enum DrawerState {
    case up
    case down

    var opposite: DrawerState {
        switch self {
            case .down:
                return .up
            case .up:
                return .down
        }
    }
}

class DrawerViewController: UIViewController {

    var drawerCurrentState: DrawerState = .up

    let drawerContentHolderView: DrawerHitAreaView = {
        let view = DrawerHitAreaView()
        view.backgroundColor = .white
        return view
    }()

    override func loadView() {
        super.loadView()
        
        view = TouchDismisserView(frame: view.frame)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        view.backgroundColor = .black
        //        view.backgroundColor = .clear

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubView()
    }

    private func setupRoundedCorners(for view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func setupSubView() {
        view.addSubview(drawerContentHolderView)
        setupRoundedCorners(for: drawerContentHolderView)
    }

    private func setupConstraints() {
        drawerContentHolderView.pinLeadingAndTrailingEdges(to: view)
        drawerContentHolderView.pinBottomEdge(greaterThanOrEqualTo: view)
    }

    func removeFromFaceOfEarth() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
