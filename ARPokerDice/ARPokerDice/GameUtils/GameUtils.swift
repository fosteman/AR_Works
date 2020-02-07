import Foundation
import CoreGraphics

let DegreesPerRadians = Float(Double.pi/180)
let RadiansPerDegrees = Float(180/Double.pi)

func convertToRadians(_ angle: Float) -> Float {
  return angle * DegreesPerRadians
}

func convertToRadians(_ angle: CGFloat) -> CGFloat {
  return CGFloat(CGFloat(angle) * CGFloat(DegreesPerRadians))
}

/// Convert Radians to Degrees
func convertToDegrees(_ angle: Float) -> Float {
  return angle * RadiansPerDegrees
}

func convertToDegrees(_ angle: CGFloat) -> CGFloat {
  return CGFloat(CGFloat(angle) * CGFloat(RadiansPerDegrees))
}

