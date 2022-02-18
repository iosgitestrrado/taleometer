//
//  ImageNode.swift
//  TaleOMeter
//
//  Created by Durgesh on 15/02/22.
//

import Magnetic
import SpriteKit

class ImageNode: Node {
    override var image: UIImage? {
        didSet {
            texture = image.map { SKTexture(image: $0) }
        }
    }
    override func selectedAnimation() {}
    override func deselectedAnimation() {}
}
