//
//  CGPoint+Extension.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import UIKit

extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}
