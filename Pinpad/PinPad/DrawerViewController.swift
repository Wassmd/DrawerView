import UIKit


enum DrawerState {
    case closed
    case open

    // simplify this
    var opposite: DrawerState {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

class DrawerViewController: UIViewController {

    var drawerCurrentState: DrawerState = .open

    let drawerContentHolderView: DrawerHitAreaView = {
        let view = DrawerHitAreaView()
        view.backgroundColor = .white
        return view
    }()

    override func loadView() {
        super.loadView()
        
        view = TouchDismisserView(frame: view.frame)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
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
