enum UnitSystem {
    case metric, imperial
}

protocol Measurement {

    var amount: Double { get }
    var measurementUnit: MeasurementUnit { get }
}

protocol MeasurementUnit {

    var abbreviation: String { get }

}

/// A concept is a range of values that has some identifiable meaning. EG., 90-100°F -> "sweltering".
protocol MeasurementConcept {

    func lowerBound(in unit: MeasurementUnit) -> Double

    func upperBound(in unit: MeasurementUnit) -> Double

    func average(in unit: MeasurementUnit) -> Measurement

    func includes(measurement: Measurement) -> Bool

}

// MARK: - Distance
enum DistanceUnit: MeasurementUnit {
    case millimeter
    case centimeter
    case meter
    case kilometer
    case eigthOfInch
    case inch
    case foot
    case yard
    case mile

    var abbreviation: String {
        switch self {
        case .millimeter:
            return "mm"
        case .centimeter:
            return "cm"
        case .meter:
            return "m"
        case .kilometer:
            return "km"
        case .eigthOfInch:
            return "1/8 in"
        case .inch:
            return "in"
        case .foot:
            return "ft"
        case .yard:
            return "yd"
        case .mile:
            return "mi"
        }
    }// abbreviation

    var subdivision: DistanceUnit? {
        switch self {
        case .millimeter:
            return nil
        case .centimeter:
            return .millimeter
        case .meter:
            return .centimeter
        case .kilometer:
            return .meter
        case .eigthOfInch:
            return nil
        case .inch:
            return .eigthOfInch
        case .foot:
            return .inch
        case .yard:
            return .foot
        case .mile:
            return .foot
        }
    }//subdivision

    // How many of subdivision units in unit?
    var subdivisionCount: Int {
        switch self {
        case .millimeter:
            return 0
        case .centimeter:
            return 10
        case .meter:
            return 100
        case .kilometer:
            return 1000
        case .eigthOfInch:
            return 0
        case .inch:
            return 8
        case .foot:
            return 12
        case .yard:
            return 3
        case .mile:
            return 5280
        }
    }//subdivision

}// DistanceUnit

struct Distance: Measurement {

    // MARK: - Conformance to Measurement
    var amount: Double {
        return length
    }

    var measurementUnit: MeasurementUnit {
        return unit
    }

    // MARK: - Main
    let length: Double

    let unit: DistanceUnit

    // Internally, all distances are represented in meters
    private let _meters: Double

    init(length: Double, unit: DistanceUnit) {
        self.length = length
        self.unit = unit
        _meters = Distance._convertToMeters(length: length, unit: unit)
    }

    /// Subtract two distances; resulting distance is in units of
    /// lhs. Rhs does not have to be in same units.
    static func -(lhs: Distance, rhs: Distance) -> Distance {
        let meters = lhs._meters - rhs._meters
        return Distance(length: meters, unit: .meter).inUnits(lhs.unit)
    }

    func inUnits(_ unit: DistanceUnit) -> Distance {
        return Distance(length: self.inUnits(unit), unit: unit)
    }

    func inUnits(_ unit: DistanceUnit) -> Double {
        let conversionFactor: Double
        switch unit {
        case .millimeter:
            conversionFactor = 1000
        case .centimeter:
            conversionFactor = 100
        case .meter:
            conversionFactor = 1
        case .kilometer:
            conversionFactor = 0.001
        // case .sixteenthOfInch:
        //     conversionFactor = 629.921259843
        case .eigthOfInch:
            conversionFactor = 312.5
        case .inch:
            conversionFactor = 39.37007874015748
        case .foot:
            conversionFactor = 3.280839895013123
        case .yard:
            conversionFactor = 1.093613298337708
        case .mile:
            conversionFactor = 0.000621371192237334
        }
        return conversionFactor * _meters
    }// inUnits

    // https://www.nist.gov/pml/weights-and-measures/si-units-length
    private static func _convertToMeters(length: Double, unit: DistanceUnit) -> Double {
        let conversionFactor: Double
        switch unit {
        case .millimeter:
            conversionFactor = 0.001
        case .centimeter:
            conversionFactor = 0.01
        case .meter:
            conversionFactor = 1
        case .kilometer:
            conversionFactor = 1000
        case .eigthOfInch:
            conversionFactor = 0.0032
        // case .sixteenthOfInch:
        //     conversionFactor = 0.0015875
        case .inch:
            conversionFactor = 0.0254
        case .foot:
            conversionFactor = 0.3048
        case .yard:
            conversionFactor = 0.9144
        case .mile:
            conversionFactor = 1609.344
        }
        return conversionFactor * length
    }// _convertToMeters

}// Distance

extension Distance: Equatable {

    static func ==(lhs: Distance, rhs: Distance) -> Bool {

        return lhs._meters == rhs._meters
    }
}

extension Distance: Comparable {

    static func <(lhs: Distance, rhs: Distance) -> Bool {

        return lhs._meters < rhs._meters
    }

    static func <=(lhs: Distance, rhs: Distance) -> Bool {

        return lhs._meters <= rhs._meters
    }

    static func >(lhs: Distance, rhs: Distance) -> Bool {

        return lhs._meters > rhs._meters
    }

    static func >=(lhs: Distance, rhs: Distance) -> Bool {

        return lhs._meters >= rhs._meters
    }
}

extension Distance: CustomStringConvertible {
    
    var description: String {
        return String(format: "%.1f \(unit.abbreviation)", length)
    }
}

