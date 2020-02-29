import UIKit

extension UIViewPropertyAnimator {

    enum Constants {
        static let defaultSpringMass: CGFloat = 1
        static let defaultSpringStiffness: CGFloat = 400
        static let defaultSpringDamping: CGFloat = 100
        static var velocityDivider: CGFloat = 1.3
    }

    /// Initializes a `UIViewPropertyAnimator` with given values
    ///
    /// - Parameters:
    ///   - velocity: The initial velocity of the animation. Input can be a velocity of a Gesture
    ///     Recognizer. It will automatically be converted into a velocity that `UISpringTimingParameters` can use
    ///   - animationDistance: The distance which the animation travels from start to end. Needed to
    ///     calculate the initial velocity for `UISpringTimingParameters`
    ///   - duration: The duration of the animation. When using `UISpringTimingParameters`, this value has no effect
    ///   - mass: The Springmass for the UIViewPropertyAnimator
    ///   - stiffness: The Springstiffnes for the UIViewPropertyAnimator
    ///   - damping: The Springdamping for the UIViewPropertyAnimator
    /// - Returns: An instance of `UIViewPropertyAnimator`
    class func produceCardAnimator(with velocity: CGPoint = CGPoint.zero, animationDistance: CGFloat = 0, duration: TimeInterval = 0, mass: CGFloat = Constants.defaultSpringMass, stiffness: CGFloat = Constants.defaultSpringStiffness, damping: CGFloat = Constants.defaultSpringDamping) -> UIViewPropertyAnimator {
        let convertedVelocity = animationDistance > 0 ? convertTapVelocityToSpringVelocity(velocity, animationDistance: animationDistance) : .zero
        let dividedVelocity = divideVelocityByConstant(convertedVelocity)
        let timingParameter = produceTimingParameter(with: dividedVelocity, mass: mass, stiffness: stiffness, damping: damping)
        let animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameter)
        return animator
    }


    // MARK: - Internal Helpers

    private class func produceTimingParameter(with velocity: CGVector = CGVector.zero, mass: CGFloat, stiffness: CGFloat, damping: CGFloat) -> UITimingCurveProvider {
        UISpringTimingParameters(mass: mass,
                                 stiffness: stiffness,
                                 damping: damping,
                                 initialVelocity: velocity)
    }

    // Tap velocity is in pt/s
    // Spring velocity of 1.0 means it covers all way of the animation in 1s.
    // Thus, we need to divide the tap velocity by the animation distance
    private class func convertTapVelocityToSpringVelocity(_ velocity: CGPoint, animationDistance: CGFloat) -> CGVector {
        CGVector(dx: 0, dy: abs(velocity.y / animationDistance))
    }

    private class func divideVelocityByConstant(_ velocity: CGVector) -> CGVector {
        CGVector(dx: velocity.dx / Constants.velocityDivider, dy: velocity.dy / Constants.velocityDivider)
    }
}
