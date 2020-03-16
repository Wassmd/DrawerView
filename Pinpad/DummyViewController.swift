//
//  DummyViewController.swift
//  Pinpad
//
//  Created by Mohammed Wasimuddin on 27.02.20.
//  Copyright © 2020 payback. All rights reserved.
//

import UIKit

class DummyViewController: UIViewController {

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
        view.backgroundColor = .systemRed
        view.addSubview(button)
        view.addSubview(button1)

//        button.addTarget(self, action: #selector(setupAndShowDrawer), for: .touchUpInside)
        button1.addTarget(self, action: #selector(presentView), for: .touchUpInside)
//
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(detectTap)))
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

    @objc private func presentView() {
        let vc = UIViewController()

        vc.modalPresentationStyle = .fullScreen
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        vc.view.backgroundColor = .purple
        vc.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
        present(vc, animated: true)
    }

    @objc func dismissView() {
        dismiss(animated: true)
    }
}
