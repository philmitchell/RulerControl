//
//  ViewController.swift
//  RulerControlDemo
//
//  Created by PHILIP MITCHELL on 5/16/18.
//  Copyright © 2018 Larkwire. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var rulerLabel: UILabel! {
        didSet {
            rulerLabel.textColor = UIColor.white
        }
    }
    
    @IBOutlet weak var rulerControl: RulerControl!
    
    @objc func rulerChanged() {
        if let length = rulerControl.actualLength {
            let lengthString = String(format: "%0.1f", length)
            rulerLabel.text = "\(lengthString) \(rulerControl.baseUnit.abbreviation)"
        }
    }

    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add background color just for demo
        let start = UIColor(red:0.59, green:0.58, blue:0.94, alpha:1.0)
        let end = UIColor(red:0.98, green:0.77, blue:0.82, alpha:1.0)
        gradientLayer.zPosition = -1.0
        gradientLayer.colors = [start.cgColor, end.cgColor]
        view.layer.addSublayer(gradientLayer)

        // Prepare plane and ruler
        let device = Device()
        if let ppi = device.pointsPerInch {
            let plane = Plane(pointsPerUnit: ppi, unit: .inch)
            rulerControl.plane = plane
            rulerControl.baseUnit = .centimeter
            rulerControl.color = #colorLiteral(red: 0.9886914062, green: 0.05487908777, blue: 0.813106653, alpha: 1)
            rulerControl.handleColor = UIColor.white
            rulerChanged()
        }
        rulerControl.addTarget(self, action: #selector(rulerChanged), for: .valueChanged)
        rulerControl.isContinuous = true
    }

    override func viewWillLayoutSubviews() {
        gradientLayer.frame = view.layer.frame
    }

}

