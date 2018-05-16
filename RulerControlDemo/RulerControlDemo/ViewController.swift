//
//  ViewController.swift
//  RulerControlDemo
//
//  Created by PHILIP MITCHELL on 5/16/18.
//  Copyright © 2018 Larkwire. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var rulerLabel: UILabel!
    
    @IBOutlet weak var rulerControl: RulerControl!
    
    @objc func rulerChanged() {
        if let length = rulerControl.actualLength {
            let lengthString = String(format: "%0.1f", length)
            rulerLabel.text = "\(lengthString) \(rulerControl.baseUnit.abbreviation)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = Device()
        if let ppi = device.pointsPerInch {
            let plane = Plane(pointsPerUnit: ppi, unit: .inch)
            rulerControl.plane = plane
            rulerControl.baseUnit = .centimeter
            rulerChanged()
        }
        rulerControl.addTarget(self, action: #selector(rulerChanged), for: .valueChanged)
        rulerControl.isContinuous = true
    }

}

