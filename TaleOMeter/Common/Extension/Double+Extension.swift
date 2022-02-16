//
//  Double+Extension.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import Foundation

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
