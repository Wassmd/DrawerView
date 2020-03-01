import UIKit

class ViewController: UIViewController {

    private let drawerViewController = DrawerViewController()
    //    private var animator = UIViewPropertyAnimator.produceCardAnimator(animationDistance: 0)
    private var animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut)
    private var animationProgress: CGFloat = 0

    var topCardConstraint: NSLayoutConstraint?

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
        guard drawerViewController.drawerCurrentState == .up else { return }
        print("tap detected")
        // only accept touches in transparent View location
        let location = gestureRecognizer.location(in: view)
        let drawView = drawerViewController.drawerContentHolderView.frame

        guard location.y < drawView.origin.y else { return }

        animateCard(with: view.bounds.height - 150)
        drawerViewController.drawerCurrentState = .up
    }

    @objc func setupAndShowDrawer() {
//        present(DummyViewController(), animated: true)
        setupDrawerController()
        setupDrawerConstraints()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.animateCard(with: 66)
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
        drawerViewController.drawerCurrentState = .down

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        drawerViewController.view.addGestureRecognizer(panGesture)

    }

    private func setupDrawerConstraints() {
        topCardConstraint = drawerViewController.drawerContentHolderView.pinTopEdge(to: view.safeAreaLayoutGuide, withOffset: view.frame.height)
        drawerViewController.drawerContentHolderView.pinLeadingAndTrailingEdges(to: view)
        drawerViewController.drawerContentHolderView.pinHeight(to: view.bounds.height)
    }

    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let offset = drawerViewController.drawerCurrentState == .up ? 66 : view.bounds.height

        switch recognizer.state {
            case .began:
                animateCard(with: offset)
                animator.pauseAnimation()
                animationProgress = animator.fractionComplete

            case .changed:
                let translation = recognizer.translation(in: drawerViewController.view)
                var fraction = -translation.y / offset
                if drawerViewController.drawerCurrentState == .up || animator.isReversed { fraction *= -1 }
                animator.fractionComplete = fraction + animationProgress

            case .ended:
                let yVelocity = recognizer.velocity(in: drawerViewController.view).y
                let shouldClose = yVelocity > 0
                if yVelocity == 0 {
                    animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                    break
                }
                switch drawerViewController.drawerCurrentState {
                    case .up:
                        if !shouldClose && !animator.isReversed { animator.isReversed = !animator.isReversed }
                        if shouldClose && animator.isReversed { animator.isReversed = !animator.isReversed }
                    case .down:
                        if shouldClose && !animator.isReversed { animator.isReversed = !animator.isReversed }
                        if !shouldClose && animator.isReversed { animator.isReversed = !animator.isReversed }
                }
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            @unknown default:
                print("inside default")
                break
        }
    }

    private func animateCard(with topOffset: CGFloat) {
        let state = drawerViewController.drawerCurrentState.opposite

        animator.addAnimations { [weak self] in
            guard let self = self else { return }

            switch self.drawerViewController.drawerCurrentState {
                case .down:
                    self.topCardConstraint?.constant = 66
                case .up:
                    self.topCardConstraint?.constant = self.view.bounds.height - 150
            }

            self.view.layoutIfNeeded()
        }

        animator.addCompletion { position in
            switch position {
                case .start:
                    self.drawerViewController.drawerCurrentState = state.opposite
                case .end:
                    self.drawerViewController.drawerCurrentState = state
                default:
                    fatalError()
            }

            switch self.drawerViewController.drawerCurrentState {
                case .down:
                    self.topCardConstraint?.constant = self.view.bounds.height - 150
//                    self.removeDrawer()
                case .up:
                    self.topCardConstraint?.constant = 66
            }
        }

        animator.startAnimation()
    }
}

