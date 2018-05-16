import UIKit

/// Center of rect and init with center.
extension CGRect {

    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }

    init(center: CGPoint, width: CGFloat, height: CGFloat) {
        self.init(x: center.x - width / 2, y: center.y - height / 2, width: width, height: height)
    }

    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }

}

/// Upper, lower, left, right halves.
extension CGRect {

    var upperHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width, height: height / 2)
    }

    var lowerHalf: CGRect {
        return CGRect(x: minX, y: midY, width: width, height: height / 2)
    }

    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width / 2, height: height)
    }

    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width / 2, height: height)
    }
}

/// Points at the four corners
extension CGRect {

    var upperLeft: CGPoint {
        return CGPoint(x: minX, y: minY)
    }

    var lowerLeft: CGPoint {
        return CGPoint(x: minX, y: maxY)
    }

    var upperRight: CGPoint {
        return CGPoint(x: maxX, y: minY)
    }

    var lowerRight: CGPoint {
        return CGPoint(x: maxX, y: maxY)
    }
}

/// Four midpoints
extension CGRect {

    var leftMid: CGPoint {
        return CGPoint(x: minX, y: midY)
    }

    var rightMid: CGPoint {
        return CGPoint(x: maxX, y: midY)
    }

    var upperMid: CGPoint {
        return CGPoint(x: midX, y: minY)
    }

    var lowerMid: CGPoint {
        return CGPoint(x: midX, y: maxY)
    }

}
