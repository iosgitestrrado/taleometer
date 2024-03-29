//
//  UIInt+Extenstion.swift
//  TaleOMeter
//
//  Created by Durgesh on 10/03/22.
//


extension Int {
    func formatPoints() -> String {
        let newNum = Double(self) / 1000.0
        var newNumString = "\(self)"
        if self > 1000 && self < 1000000 {
            newNumString = "\(newNum)k"
        } else if self > 1000000 {
            newNumString = "\(newNum)m"
        }

        return newNumString
    }
}
