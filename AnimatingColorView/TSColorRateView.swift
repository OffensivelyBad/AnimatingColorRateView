//
//  TSColorRateView.swift
//  AnimatingColorView
//
//  Created by Shawn Roller on 6/29/17.
//  Copyright © 2017 OffensivelyBad. All rights reserved.
//

import UIKit

class TSColorRateView: UIView {
    
    // Track elapsed time and rates
    fileprivate var timer = Timer()
    fileprivate var totalTime: Int = 0
    fileprivate var totalProcessed: Int = 0
    fileprivate var rateDuration: Int = 3600
    fileprivate var rate: Int = 1
    fileprivate var percentOfDuration: Double {
        return Double(self.totalTime) / Double(self.rateDuration)
    }
    fileprivate var goalRate: Double {
        return self.percentOfDuration * Double(self.rate)
    }
    fileprivate var percentToRate: Double {
        guard self.goalRate > 0 else { return 0 }
        return Double(self.totalProcessed) / self.goalRate
    }
    
    // Colors
    fileprivate var goalColors: [UIColor] = [.clear]
    fileprivate var colors: [UIColor] {
        return Array(goalColors.reversed())
    }
    fileprivate var colorIndex: Int = 0
    fileprivate var gradientLayer = CAGradientLayer()
    
    fileprivate var logging = false
    
}


//MARK: - Public functions
extension TSColorRateView {
    
    /**
     This sets up the starting background color
     */
    func setup() {
        guard self.colors.count > 0 else { return }
        self.backgroundColor = self.colors[0]
    }
    
    /**
     This sets the rate
     - Parameter rate: An Int that represents how many times the process must be completed in an hour
     */
    public func setRate(_ rate: Int) {
        self.rate = rate
    }
    
    /**
     This sets the colors that will be animated through
     - Parameter colors: The colors that will be animated through, in order of index position, starting at 0
     */
    public func setColors(_ colors: [UIColor]) {
        self.goalColors = colors
    }
    
    /**
     This will start the color animation
     */
    public func start() {
        setupTimer()
    }
    
    /**
     This will stop the color animation
     */
    public func pause() {
        self.timer.invalidate()
    }
    
    /**
     This will reset the animation to the start color
     */
    public func reset() {
        self.timer.invalidate()
        self.resetToFirstColor()
        self.totalProcessed = 0
        self.totalTime = 0
    }
    
    /**
     This increments the totalProcessed property
     - Parameter processedNumber: The number of processes completed which will be added onto the totalProcessed
     */
    public func increment(processesCompleted: Int) {
        self.totalProcessed += processesCompleted
    }
    
    /**
     This sets a constant gradient.  There is no gradient by default
     - Parameter color: The color for the gradient that will not change
     - Parameter position: The center point of the animating color in the gradient, ex. x: 0.5, y: 1 will have the animating color center at the bottom of the screen, y: 0 will be at the top
     - Parameter location: The position of the start of the animating color
     */
    public func setGradient(color: UIColor, position: CGPoint, locations: [NSNumber]) {
        self.gradientLayer = CAGradientLayer()
        self.gradientLayer.frame = self.bounds
        self.gradientLayer.colors = [color.cgColor, UIColor.clear.cgColor]
        self.gradientLayer.startPoint = CGPoint(x: 1 - position.x, y: 1 - position.y)
        self.gradientLayer.endPoint = position
        self.gradientLayer.locations = locations
        self.layer.addSublayer(self.gradientLayer)
    }
    
    /**
     This will log every 10 seconds averages, total time, and total processes completed
     - Parameter turnOn: true turns on logging and false turns it off
     */
    public func turnOnLogging(_ turnOn: Bool) {
        self.logging = turnOn
    }
    
}


//MARK: - Private functions
extension TSColorRateView {
    
    fileprivate func setupTimer() {
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TSColorRateView.incrementTime), userInfo: nil, repeats: true)
        self.timer.fire()
    }
    
    @objc fileprivate func incrementTime() {
        self.totalTime += 1
        animateBackgroundColor()
        
        if self.logging && self.totalTime % 10 == 0 {
            print("**TSColorRateView - Total Seconds: \(self.totalTime)", terminator: " || ")
            print("Total Processed: \(self.totalProcessed)", terminator: " || ")
            print("Goal Rate per Hour: \(self.rate)", terminator: " || ")
            print("Goal for \(self.totalTime) seconds: \(self.goalRate.rounded())", terminator: " || ")
            print("Percent to Process Goal: \((self.percentToRate * 100).rounded())%", terminator: " || ")
            guard self.totalTime > 60 else { return }
            print("Average processes per Hour: \(self.totalProcessed / (self.totalTime / 60))", terminator: "\n")
        }
        
    }
    
    fileprivate func animateBackgroundColor() {
        
        let color = getColorForAnimation()
        
        UIView.animate(withDuration: 1) {
            self.backgroundColor = color
        }
        
    }
    
    fileprivate func getColorForAnimation() -> UIColor {
        guard self.totalTime > 0 && self.totalProcessed > 0 && self.colors.count > 1 else { return self.colors.first ?? UIColor.clear }
        
        let percentToRate = self.percentToRate * 100
        
        if percentToRate >= 100 || percentToRate <= 0 {
            let color = percentToRate >= 100 ? self.colors.last : self.colors.first
            return color ?? UIColor.clear
        }
        else {
            
            let percentPerColor: Int = Int(100 / Double(self.colors.count - 1))
            var startPercentRange = 0
            var endPercentRange: Int = percentPerColor
            var endColorIndex = 1
            
            for i in 1...self.colors.count - 1 {
                if startPercentRange...endPercentRange ~= Int(percentToRate) {
                    endColorIndex = i
                    break
                }
                else {
                    startPercentRange += percentPerColor
                    endPercentRange += percentPerColor
                }
            }
            
            let colorOne = self.colors[endColorIndex - 1]
            let colorTwo = self.colors[endColorIndex]
            let percentBetweenColors = (percentToRate - Double(percentPerColor * (endColorIndex - 1))) / Double(percentPerColor)
            
            return getColorBetweenColors(colorOne: colorOne, colorTwo: colorTwo, percent: CGFloat(percentBetweenColors))
        }
    }
    
    fileprivate func getColorBetweenColors(colorOne: UIColor, colorTwo: UIColor, percent: CGFloat) -> UIColor {
        let ciColorOne = CIColor(color: colorOne)
        let ciColorTwo = CIColor(color: colorTwo)
        
        let red = Float((1.0 - percent) * ciColorOne.red + percent * ciColorTwo.red)
        let green = Float((1.0 - percent) * ciColorOne.green + percent * ciColorTwo.green)
        let blue = Float((1.0 - percent) * ciColorOne.blue + percent * ciColorTwo.blue)
        
        let color = UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: 1)
        
        return color
    }
    
    fileprivate func resetToFirstColor() {
        guard self.colors.count > 0 else { return }
        
        UIView.animate(withDuration: 1.0) {
            self.backgroundColor = self.colors.first
        }
    }
    
}



