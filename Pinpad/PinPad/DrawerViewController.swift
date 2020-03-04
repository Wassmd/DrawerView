import UIKit

class DrawerViewController: UIViewController {

    enum DrawerState {
        case closed
        case open

        var opposite: DrawerState {
            switch self {
            case .open: return .closed
            case .closed: return .open
            }
        }
    }

    private let topOffset: CGFloat
    private let bottomOffset: CGFloat

    private var animationProgress: CGFloat = 0
    private var runningAnimator: UIViewPropertyAnimator!
    private var bottomConstraint: NSLayoutConstraint?

    var drawerCurrentState: DrawerState = .closed

    private let drawerContentHolderView: DrawerHitAreaView = {
        let view = DrawerHitAreaView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var drawerOffset: CGFloat = {
           return self.view.frame.height - bottomOffset
       }()

    var drawViewFrame: CGRect {
        return drawerContentHolderView.frame
    }
    init(topOffset: CGFloat = 110, bottomOffset: CGFloat = 200) {
        self.topOffset = topOffset
        self.bottomOffset = bottomOffset

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        
        view = TouchDismisserView(frame: view.frame)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubView()

        setupConstraints()
    }

    private func setupRoundedCorners(for view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private func setupSubView() {
        view.addSubview(drawerContentHolderView)
        setupRoundedCorners(for: drawerContentHolderView)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        view.addGestureRecognizer(panGesture)
    }

    private func setupConstraints() {
        drawerContentHolderView.pinLeadingAndTrailingEdges(to: view)
        drawerContentHolderView.pinHeight(to: view.bounds.height - topOffset)
        bottomConstraint =  drawerContentHolderView.pinBottomEdge(to: view, withOffset: drawerOffset)
    }

    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}


// Drawer Animation
extension DrawerViewController {
    func animateTransitionIfNeeded(to state: DrawerState, duration: TimeInterval = 0.5) {
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
                case .open:
                    self.bottomConstraint?.constant = 0
                    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                case .closed:
                    self.bottomConstraint?.constant = self.drawerOffset
                    self.view.backgroundColor = .clear
            }
            self.view.layoutIfNeeded()
        })

        transitionAnimator.addCompletion { position in
            switch position {
                case .start:
                    self.drawerCurrentState = state.opposite
                case .end:
                    self.drawerCurrentState = state
                default:
                    break
            }

            switch self.drawerCurrentState {
                case .open:
                    self.bottomConstraint?.constant = 0
                case .closed:
                    self.bottomConstraint?.constant = self.drawerOffset
            }

        }

        transitionAnimator.startAnimation()

        runningAnimator = transitionAnimator
    }

    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
            case .began:
                animateTransitionIfNeeded(to: drawerCurrentState.opposite)
                runningAnimator.pauseAnimation()
                animationProgress = runningAnimator.fractionComplete

            case .changed:
                let translation = recognizer.translation(in: drawerContentHolderView)
                var fraction = -translation.y / drawerOffset

                if drawerCurrentState == .open { fraction *= -1 }
                if runningAnimator.isReversed { fraction *= -1 }
                runningAnimator.fractionComplete = fraction + animationProgress

            case .ended:
                let yVelocity = recognizer.velocity(in: drawerContentHolderView).y
                let shouldClose = yVelocity > 0

                // Early exit if no motion
                if yVelocity == 0 {
                    runningAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                    break
                }

                // Reserve animations
                switch drawerCurrentState {
                    case .open:
                        if !shouldClose && !runningAnimator.isReversed { runningAnimator.isReversed = !runningAnimator.isReversed }
                        if shouldClose && runningAnimator.isReversed { runningAnimator.isReversed = !runningAnimator.isReversed }
                    case .closed:
                        if shouldClose && !runningAnimator.isReversed { runningAnimator.isReversed = !runningAnimator.isReversed }
                        if !shouldClose && runningAnimator.isReversed { runningAnimator.isReversed = !runningAnimator.isReversed }
                }

                // continue with animation
                runningAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)

            default:
                break
        }
    }

    func updateDrawerCurrentState(state: DrawerState) {
        drawerCurrentState = state
    }
}
