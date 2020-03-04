import UIKit

class ViewController: UIViewController {

    private let drawerViewController = DrawerViewController()
    //    private var animationProgress: CGFloat = 0

    // MARK: - Constants
    // TODO: Name is better
    private lazy var popupOffset: CGFloat = {
        return self.view.frame.height - 200
    }()

    private var bottomConstraint: NSLayoutConstraint?
    private var animationProgress = [CGFloat]()

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
        animateTransitionIfNeeded(to: drawerViewController.drawerCurrentState.opposite, duration: 0.5)

        drawerViewController.drawerCurrentState = .open
    }

    @objc func setupAndShowDrawer() {
        setupDrawerController()
        setupDrawerConstraints()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            //            self?.animateCard(with: 66)
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
        bottomConstraint =  drawerViewController.drawerContentHolderView.pinBottomEdge(to: view, withOffset: popupOffset)

    }

    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
            case .began:

                // start the animations
                animateTransitionIfNeeded(to: drawerViewController.drawerCurrentState.opposite, duration: 0.5)

                // pause all animations, since the next event may be a pan changed
                runningAnimators.forEach { $0.pauseAnimation() }

                // keep track of each animator's progress
                animationProgress = runningAnimators.map { $0.fractionComplete }

            case .changed:

                // variable setup
                let translation = recognizer.translation(in: drawerViewController.drawerContentHolderView)
                var fraction = -translation.y / popupOffset

                // adjust the fraction for the current state and reversed state
                if drawerViewController.drawerCurrentState == .open { fraction *= -1 }
                if runningAnimators[0].isReversed { fraction *= -1 }

                // apply the new fraction
                for (index, animator) in runningAnimators.enumerated() {
                    animator.fractionComplete = fraction + animationProgress[index]
            }

            case .ended:

                // variable setup
                let yVelocity = recognizer.velocity(in: drawerViewController.drawerContentHolderView).y
                let shouldClose = yVelocity > 0

                // if there is no motion, continue all animations and exit early
                if yVelocity == 0 {
                    runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                    break
                }

                // reverse the animations based on their current state and pan motion
                switch drawerViewController.drawerCurrentState {
                    case .open:
                        if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                        if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                    case .closed:
                        if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                        if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                }

                // continue all animations
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }

            default:
                ()
        }
    }

    // TODO: Place it to its position
    private var runningAnimators = [UIViewPropertyAnimator]()

    /// Animates the transition, if the animation is not already running.
    private func animateTransitionIfNeeded(to state: DrawerState, duration: TimeInterval) {
        // an animator for the transition
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
                case .open:
                    self.bottomConstraint?.constant = 0
                    self.drawerViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                case .closed:
                    self.bottomConstraint?.constant = self.popupOffset
                    self.drawerViewController.view.backgroundColor = .clear
            }
            self.view.layoutIfNeeded()
        })

        // the transition completion block
        transitionAnimator.addCompletion { position in

            // update the state
            switch position {
                case .start:
                    self.drawerViewController.drawerCurrentState = state.opposite
                case .end:
                    self.drawerViewController.drawerCurrentState = state
                default:
                    ()
            }

            // manually reset the constraint positions
            switch self.self.drawerViewController.drawerCurrentState {
                case .open:
                    self.bottomConstraint?.constant = 0
                case .closed:
                    self.bottomConstraint?.constant = self.popupOffset
            }

        }


        // start all animators
        transitionAnimator.startAnimation()

        // keep track of all running animators
        runningAnimators.append(transitionAnimator)
    }
}

