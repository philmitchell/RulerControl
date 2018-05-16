//
//  RulerControl.swift
//
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

@IBDesignable
class RulerControl: UIControl {

    enum Side {
        case left, right, none
    }

    // MARK: - Public

    struct Defaults {
        static let thickness: CGFloat = 15.0
        static let color = UIColor.blue
        static let handleColor = UIColor.blue
        static let baseUnit: DistanceUnit = .centimeter
        static let hashMarkColor = UIColor.white
        static let handleSize = CGSize(width: 40.0, height: 120.0)
        static let handleLineWidth: CGFloat = 14.0
        static let minimumLineLength: CGFloat = 30.0 // Line segment never gets shorter than this
        static let isContinuous = false
        static let showActual = true
    }

    /// Length in points of visible line segmenet
    var pointsLength: CGFloat {
        let lineRect = _lineRect(for: frame)
        return lineRect.width
    }

    /// Length in actual units, as defined by baseUnit.
    var actualLength: Double? {
        guard let plane = self.plane else {
            return nil
        }
        let distance: Distance = plane.physicalDistance(of: Double(pointsLength)).inUnits(baseUnit)
        return distance.length
    }

    /// Thickness of line that defines the ruler
    @IBInspectable var thickness: CGFloat = Defaults.thickness { didSet { setNeedsLayout() } }

    /// Color of ruler
    @IBInspectable var color: UIColor = Defaults.color

    /// Color of handles
    @IBInspectable var handleColor: UIColor = Defaults.handleColor

    /// Color of hash marks
    @IBInspectable var hashMarkColor: UIColor = Defaults.hashMarkColor

    @IBInspectable var handleSize: CGSize = Defaults.handleSize  { didSet { setNeedsLayout() } }

    @IBInspectable var handleLineWidth: CGFloat = Defaults.handleLineWidth

    /// Units of length measurement (centimer, inch, etc.)
    var baseUnit: DistanceUnit = Defaults.baseUnit

    /// The plane that allows us to measure actual length
    var plane: Plane?

    /// Whether or not to show hash marks
    var showActual = Defaults.showActual {
        didSet {
            setNeedsDisplay()
            assert(plane != nil, "Cannot show actual without plane")
        }
    }

    /// If true, delegate is called continuously during handle motion; if false, only when released.
    var isContinuous = Defaults.isContinuous

    // MARK: - Private

    private var minimumFrameWidth = Defaults.minimumLineLength + Defaults.handleSize.width

    // Frame at beginning of touches
    private var startFrame: CGRect? = nil

    // Initial touch point
    private var touchStartPoint: CGPoint? = nil

    // Location of center when touch starts
    private var centerStartPoint: CGPoint? = nil

    // Which handle initial touch was closest to (left, right or none)
    private var touchSide: Side?

    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        _setup()
    }

    private func _setup() {
        isOpaque = false
        contentMode = .redraw
        backgroundColor = UIColor.clear
    }// _setup

    // MARK: - Drawing
    override func draw(_ rect: CGRect) {

        let lineRect = _lineRect(for: rect)
        _createLinePath(in: lineRect)

        if showActual {
            _createHashMarks(in: lineRect)
        }

        let leftHandleRect = CGRect(x: rect.minX,
                                    y: rect.minY + thickness,
                                    width: handleSize.width,
                                    height: handleSize.height)

        _createHandlePath(in: leftHandleRect, circleInset: 3.0)

        let rightHandleRect = CGRect(x: rect.maxX - handleSize.width,
                                     y: rect.minY + thickness,
                                     width: handleSize.width,
                                     height: handleSize.height)

        _createHandlePath(in: rightHandleRect, circleInset: 3.0)

    }

    private func _lineRect(for rect: CGRect) -> CGRect {
        // The line is at top of view, inset by half handle width on each side
        let lineRect = CGRect(x: rect.minX + handleSize.width / 2,
                              y: rect.minY,
                              width: rect.width - handleSize.width,
                              height: thickness)

        return lineRect
    }

    private func _createLinePath(in rect: CGRect) {
        let path = UIBezierPath(rect: rect)        
        color.setFill()
        path.fill()
    }

    private func _createHashMarks(in rect: CGRect) {
        // Can't create hashmarks without a plane
        guard let plane = self.plane else {
            return
        }
        // Can't create hashmarks unless our base distance unit has a reasonable subdivision (eg., centimeter => millimeter)
        guard let hashMarkUnit = baseUnit.subdivision else {
            return
        }
        let path = UIBezierPath()        
        let startPoint = rect.lowerLeft
        let endPoint = rect.lowerRight
        var x = startPoint.x
        let startY = rect.minY
        let shortY = startY + 0.15 * rect.height
        let midY = startY + 0.3 * rect.height
        let longY = startY + 0.75 * rect.height
        let baseCount = baseUnit.subdivisionCount
        var hashCount = 0
        var hashDistance = Distance(length: 0, unit: hashMarkUnit)
        while x < endPoint.x {
            path.move(to: CGPoint(x: x, y: startY))
            let y = hashCount % baseCount == 0 ? longY : hashCount % (baseCount/2) == 0 ? midY : shortY
            path.addLine(to: CGPoint(x: x, y: y))
            hashCount += 1
            // NOTE: To avoid error accumulation, don't calculate x cumulatively; each calculation is relative to same start point
            hashDistance = Distance(length: Double(hashCount), unit: hashDistance.unit)
            x = startPoint.x + CGFloat(plane.coordinateDistance(of: hashDistance))
        }
        hashMarkColor.setStroke()
        path.stroke()
    }

    private func _createHandlePath(in rect: CGRect, circleInset: CGFloat) {
        // Upper half
        let upper = rect.upperHalf
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: upper.midX, y: upper.minY))
        linePath.addLine(to: CGPoint(x: upper.midX, y: upper.maxY))
        handleColor.setStroke()
        let dashPattern: [CGFloat] = [5.0, 4.0]
        linePath.setLineDash(dashPattern, count: dashPattern.count, phase: 1)
        linePath.stroke()
        // Lower half (small square)
        let lower = rect.lowerHalf.insetBy(dx: circleInset, dy: circleInset).offsetBy(dx: 0, dy: -circleInset)
        let radius: CGFloat = 6.0
        let squareCenter = CGPoint(x: lower.midX, y: lower.minY + radius)
        let squareRect = CGRect(center: squareCenter, width: 2 * radius, height: 2 * radius)
        let squarePath = UIBezierPath(roundedRect: squareRect, cornerRadius: 0.0)        
        squarePath.lineWidth = 1.0
        squarePath.stroke()
    }// _createHandlePath

    // MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            startFrame = frame // Capture frame at start
            // For resizing, do calculations in superview coordinates, to avoid jitter when our origin changes
            let startPoint = touch.location(in: self.superview)
            touchSide = sideClosest(to: startPoint) // Which handle is moving?
            touchStartPoint = startPoint
            centerStartPoint = center
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // For resizing, do calculations in superview coordinates, to avoid jitter when our origin changes
            let newPoint = touch.location(in: self.superview)
            // If side is .none, drag to new location
            if let side = touchSide, side == .none, let startPoint = touchStartPoint, let centerStart = centerStartPoint {
                center = centerStart.offsetBy(dx: newPoint.x - startPoint.x, dy: newPoint.y - startPoint.y)
            }
            // Otherwise, resize
            else {
                updateFrame(with: newPoint)
                if isContinuous {
                    sendActions(for: .valueChanged)                    
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Don't send actions when segment is dragged to new position
        if let side = touchSide, side != .none {
            sendActions(for: .valueChanged)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Nothing to do
    }


    // To prevent touches on line segment from being intepreted as taps in superview
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    // <endPoint> is in superview coordinates
    private func updateFrame(with endPoint: CGPoint) {
        guard let startPoint = touchStartPoint,
              let startFrame = self.startFrame,
              let handleSide = touchSide else {
            return
        }
        guard handleSide != .none else {
            return
        }

        // Depending on side, we need a +/- factor
        let widthParity: CGFloat = handleSide == .right ? 1.0 : -1.0

        // For either handle side, update width
        let dx = endPoint.x - startPoint.x
        let newWidth = startFrame.width + widthParity * dx

        // Prevent width from going below minimum size
        guard newWidth >= minimumFrameWidth else {
            return
        }

        // For left handle only, update origin
        var newX = startFrame.origin.x
        let newY = startFrame.origin.y
        if handleSide == .left {
            newX = startFrame.origin.x + dx
        }

        let newFrame = CGRect(x: newX, y: newY, width: newWidth, height: startFrame.height)
        frame = newFrame
    }

    // <point> is in superview coordinates
    private func sideClosest(to point: CGPoint) -> Side {
        let leftReferencePoint = frame.lowerLeft
        let leftDistance = Plane.distance(from: point, to: leftReferencePoint)
        let rightReferencePoint = frame.lowerRight
        let rightDistance = Plane.distance(from: point, to: rightReferencePoint)
        let topReferencePoint = frame.upperMid
        let topDistance = Plane.distance(from: point, to: topReferencePoint)
        if topDistance <= leftDistance && topDistance <= rightDistance {
            return .none
        }
        return leftDistance <= rightDistance ? .left : .right
    }

} // RulerControl

