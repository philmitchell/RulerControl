import UIKit

// /// Physical distance based on device PPI.
// extension CGPoint {

//     func physicalDistance(to other: CGPoint) -> Double {

//         return physicalDistance(to: other, inUnit: .meter)
//     }

//     func physicalDistance(to other: CGPoint, inUnit unit: DistanceUnit) -> Double {

        
//         return physicalDistance(to: other, inUnit: unit, device: UIDevice.current)
//     }

//     func physicalDistance(to other: CGPoint, inUnit: DistanceUnit, device: UIDevice) -> Double {

//     }
// }

/// Offset
extension CGPoint {

    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}
