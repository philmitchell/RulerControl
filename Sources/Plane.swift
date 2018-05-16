// Copyright (c) 2018 Phil Mitchell
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

struct Plane {

    let pointsPerUnit: Double
    let unit: DistanceUnit

    typealias Point = CGPoint

    /// Compute the unit-less distance between two points in the same coordinate system.
    static func distance(from a: Point, to b: Point) -> Double {

        let distance = sqrt((pow(a.x - b.x, 2.0) + pow(a.y - b.y, 2.0)))
        return Double(distance)
    }

    init(pointsPerUnit: Double, unit: DistanceUnit) {
        self.pointsPerUnit = pointsPerUnit
        self.unit = unit
    }

    init(pointsPerUnit: CGFloat, unit: DistanceUnit) {
        self.init(pointsPerUnit: Double(pointsPerUnit), unit: unit)
    }

    func physicalDistance(of length: Double) -> Distance {
        return physicalDistance(from: Point.zero, to: Point(x: length, y: 0), inUnit: self.unit)
    }

    func physicalDistance(from a: Point, to b: Point) -> Distance {
        return physicalDistance(from: a, to: b, inUnit: self.unit)
    }

    func physicalDistance(from a: Point, to b: Point, inUnit unit: DistanceUnit) -> Distance {

        let distance = Plane.distance(from: a, to: b)
        let units = distance / pointsPerUnit; // Distance in this plane's physical units
        let physicalDistance = Distance(length: units, unit: self.unit)
        return physicalDistance.inUnits(unit)
    }
    
    func coordinateDistance(of length: Distance) -> Double {
        let distance: Distance = length.inUnits(unit) // Convert to this plane's units
        let points = distance.length * pointsPerUnit
        return points
    }

}// Plane
