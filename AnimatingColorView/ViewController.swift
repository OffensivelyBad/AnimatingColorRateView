//
//  ViewController.swift
//  AnimatingColorView
//
//  Created by Shawn Roller on 6/29/17.
//  Copyright © 2017 OffensivelyBad. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var colorRateView = TSColorRateView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupColorRateView()
        
    }

    func setupColorRateView() {
        self.colorRateView = TSColorRateView(frame: self.view.frame)
        self.colorRateView.setColors([.green, .yellow, .orange, .red])
        self.colorRateView.setRate(80)
        self.colorRateView.turnOnLogging(true)
        self.colorRateView.setup()
        self.colorRateView.setGradient(color: UIColor.gray, position: CGPoint(x: 0.5,y: 1.2), locations: [0.75, 1])
        self.view.addSubview(self.colorRateView)
        
        let resetButton = UIButton(frame: CGRect(x: self.colorRateView.frame.midX - 25, y: self.colorRateView.frame.midY, width: 50, height: 50))
        resetButton.backgroundColor = .blue
        resetButton.setTitle("R", for: .normal)
        resetButton.addTarget(self, action: #selector(ViewController.resetColorView), for: .touchUpInside)
        self.view.addSubview(resetButton)
        
        let addButton = UIButton(frame: CGRect(x: self.colorRateView.frame.midX - 25, y: self.colorRateView.frame.midY + 50, width: 50, height: 50))
        addButton.backgroundColor = .black
        addButton.setTitle("+", for: .normal)
        addButton.addTarget(self, action: #selector(ViewController.addUnitProcessed), for: .touchUpInside)
        self.view.addSubview(addButton)
        
        let startButton = UIButton(frame: CGRect(x: self.colorRateView.frame.midX - 25, y: self.colorRateView.frame.midY + 100, width: 50, height: 50))
        startButton.backgroundColor = .gray
        startButton.setTitle("S", for: .normal)
        startButton.addTarget(self, action: #selector(ViewController.startAnimation), for: .touchUpInside)
        self.view.addSubview(startButton)
        
        let stopButton = UIButton(frame: CGRect(x: self.colorRateView.frame.midX - 25, y: self.colorRateView.frame.midY + 150, width: 50, height: 50))
        stopButton.backgroundColor = .cyan
        stopButton.setTitle("X", for: .normal)
        stopButton.addTarget(self, action: #selector(ViewController.stopAnimation), for: .touchUpInside)
        self.view.addSubview(stopButton)
        
    }
    
    func addUnitProcessed() {
        self.colorRateView.increment(processesCompleted: 1)
    }
    
    func resetColorView() {
        self.colorRateView.reset()
    }
    
    func startAnimation() {
        self.colorRateView.start()
    }

    func stopAnimation() {
        self.colorRateView.pause()
    }

}

