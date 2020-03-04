import UIKit

class ViewController: UIViewController {

    private let drawerViewController = DrawerViewController()

    // MARK: - Constants

    private lazy var drawerOffset: CGFloat = {
        return self.view.frame.height - 200
    }()

    private var bottomConstraint: NSLayoutConstraint?
    private var animationProgress: CGFloat = 0
    private var runningAnimator: UIViewPropertyAnimator!

    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Drawer", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        return button

    }()

    private let button1: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Present", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        return button

    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubViews()
        setupConstraints()
    }

    private func setupSubViews() {
        view.backgroundColor = .systemBlue
        view.addSubview(button)
        view.addSubview(button1)

        button.addTarget(self, action: #selector(setupAndShowDrawer), for: .touchUpInside)
        button1.addTarget(self, action: #selector(presentView), for: .touchUpInside)

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(detectTap)))
    }

    @objc private func detectTap(gestureRecognizer: UITapGestureRecognizer) {
        guard drawerViewController.drawerCurrentState == .open else { return }
        print("tap detected")
        // only accept touches in transparent View location
        let location = gestureRecognizer.location(in: view)
        let drawView = drawerViewController.drawerContentHolderView.frame

        guard location.y < drawView.origin.y else { return }

        //        animateCard(with: view.bounds.height - 150)
        animateTransitionIfNeeded(to: drawerViewController.drawerCurrentState.opposite)

        drawerViewController.drawerCurrentState = .open
    }

    @objc func setupAndShowDrawer() {
        setupDrawerController()
        setupDrawerConstraints()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.animateTransitionIfNeeded(to: DrawerState.open)
        }
    }

    @objc func presentView() {
        print("inside present View")

        present(DummyViewController(), animated: true)
    }

    func removeDrawer() {
        drawerViewController.removeFromFaceOfEarth()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 150),
            button.heightAnchor.constraint(equalToConstant: 30),

            button1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button1.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 40),
            button1.widthAnchor.constraint(equalToConstant: 150),
            button1.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func setupDrawerController() {
        addChild(drawerViewController)
        view.addSubview(drawerViewController.view)
        
        drawerViewController.didMove(toParent: self)
        drawerViewController.drawerCurrentState = .closed

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        drawerViewController.view.addGestureRecognizer(panGesture)

    }

    private func setupDrawerConstraints() {
        drawerViewController.drawerContentHolderView.pinLeadingAndTrailingEdges(to: view)
        drawerViewController.drawerContentHolderView.pinHeight(to: view.bounds.height - 110)
        bottomConstraint =  drawerViewController.drawerContentHolderView.pinBottomEdge(to: view, withOffset: drawerOffset)

    }

    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
            case .began:

                animateTransitionIfNeeded(to: drawerViewController.drawerCurrentState.opposite)
                runningAnimator.pauseAnimation()
                animationProgress = runningAnimator.fractionComplete

            case .changed:
                let translation = recognizer.translation(in: drawerViewController.drawerContentHolderView)
                var fraction = -translation.y / drawerOffset

                if drawerViewController.drawerCurrentState == .open { fraction *= -1 }
                if runningAnimator.isReversed { fraction *= -1 }
                runningAnimator.fractionComplete = fraction + animationProgress

            case .ended:

                let yVelocity = recognizer.velocity(in: drawerViewController.drawerContentHolderView).y
                let shouldClose = yVelocity > 0

                // Early exit if no motion
                if yVelocity == 0 {
                    runningAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                    break
                }

                // Reserve animations
                switch drawerViewController.drawerCurrentState {
                    case .open:
                        if !shouldClose && !runningAnimator.isReversed { runningAnimator.isReversed = !runningAnimator.isReversed }
                        if shouldClose && runningAnimator.isReversed { runningAnimator.isReversed = !runningAnimator.isReversed }
                    case .closed:
                        if shouldClose && !runningAnimator.isReversed { runningAnimator.isReversed = !runningAnimator.isReversed }
                        if !shouldClose && runningAnimator.isReversed { runningAnimator.isReversed = !runningAnimator.isReversed }
                }

                // continue all animations
                runningAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)

            default:
                ()
        }
    }

    private func animateTransitionIfNeeded(to state: DrawerState, duration: TimeInterval = 0.5) {
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
                case .open:
                    self.bottomConstraint?.constant = 0
                    self.drawerViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                case .closed:
                    self.bottomConstraint?.constant = self.drawerOffset
                    self.drawerViewController.view.backgroundColor = .clear
            }
            self.view.layoutIfNeeded()
        })

        transitionAnimator.addCompletion { position in
            switch position {
                case .start:
                    self.drawerViewController.drawerCurrentState = state.opposite
                case .end:
                    self.drawerViewController.drawerCurrentState = state
                default:
                    ()
            }

            switch self.self.drawerViewController.drawerCurrentState {
                case .open:
                    self.bottomConstraint?.constant = 0
                case .closed:
                    self.bottomConstraint?.constant = self.drawerOffset
            }

        }

        transitionAnimator.startAnimation()
        runningAnimator = transitionAnimator
    }
}

