//
//  ActualGradientButton.swift
//  tinderClone
//
//  Created by Nishant Thakur on 29/05/20.
//  Copyright © 2020 Nishant Thakur. All rights reserved.
//

import Foundation
import UIKit

class ActualGradientButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        
        l.colors = [UIColor.systemPink.cgColor, UIColor.systemOrange.cgColor]
        l.startPoint = CGPoint(x: 0, y: 0.5)
        l.endPoint = CGPoint(x: 1, y: 0.5)
        l.cornerRadius = self.frame.height/2
        layer.insertSublayer(l, at: 0)
        return l
    }()
}
