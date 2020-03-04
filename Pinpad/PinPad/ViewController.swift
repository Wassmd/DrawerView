import UIKit

class ViewController: UIViewController {

    private let drawerViewController = DrawerViewController()

    // MARK: - Constants

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
        // only accept touches in transparent View location
        let location = gestureRecognizer.location(in: view)

        drawerViewController.closeDrawerIfNeededTap(on: location)
    }

    @objc func setupAndShowDrawer() {
        setupDrawerController()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.drawerViewController.animateTransitionIfNeeded(to: DrawerViewController.DrawerState.open)
        }
    }

    @objc func presentView() {
        present(DummyViewController(), animated: true)
    }

    func removeDrawer() {
        drawerViewController.remove()
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
    }
}

