//
//  EnlargeHitAreaView.swift
//  Pinpad
//
//  Created by Mohammed Wasimuddin on 27.02.20.
//  Copyright © 2020 payback. All rights reserved.
//

import UIKit

class DrawerHitAreaView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let receiver = super.hitTest(point, with: event) {
            return receiver
        }

        return nil
    }
}
