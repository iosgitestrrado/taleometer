//
//  Array+Extension.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import Foundation

extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
