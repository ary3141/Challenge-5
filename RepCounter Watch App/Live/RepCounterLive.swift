//
//  RepCounter 2.swift
//  DataCollection
//
//  Created by Muhammad Dwiva Arya Erlangga on 18/09/25.
//


import SwiftUI
import CoreMotion
import Combine

class RepCounterLive: ObservableObject {
    private let motionManager = CMMotionManager()
    private let fs: Double = 50.0
    private let alpha = 0.1
    
    @Published var liveSmoothed: [Double] = []
    @Published var repCount = 0
    @Published var isRunning = false
    
    @Published var peaks: [Int] = []
    @Published var globalIndex: Int = 0

    private var aboveThreshold = false
    private var lastCrossIndex = -999
    
    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        isRunning = true
        liveSmoothed.removeAll()
        peaks.removeAll()
        repCount = 0
        aboveThreshold = false
        lastCrossIndex = -999
        globalIndex = 0
        
        motionManager.deviceMotionUpdateInterval = 1.0 / fs
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion = motion else { return }
            
            let x = motion.userAcceleration.x
            let y = motion.userAcceleration.y
            let z = motion.userAcceleration.z
            let magnitude = sqrt(x*x + y*y + z*z)
            
            let lastValue = self.liveSmoothed.last ?? 0.0
            let smooth = self.alpha * magnitude + (1 - self.alpha) * lastValue
            self.liveSmoothed.append(smooth)
            
            if self.liveSmoothed.count > Int(self.fs * 3) {
                self.liveSmoothed.removeFirst()
            }
            
            self.detectLiveReps()
            self.globalIndex += 1
        }
    }
    
    func stop() {
        isRunning = false
        motionManager.stopDeviceMotionUpdates()
    }



    private func detectLiveReps() {
        guard liveSmoothed.count > 2 else { return }
        let i = liveSmoothed.count - 1
        let current = liveSmoothed[i]
        let prev = liveSmoothed[i - 1]
        let threshold = 0.25
        
        if !aboveThreshold && current > threshold && prev <= threshold {
            aboveThreshold = true
            lastCrossIndex = globalIndex
        }
        
        if aboveThreshold && current < threshold && prev >= threshold {
            if globalIndex - lastCrossIndex > Int(0.2 * fs) {
                repCount += 1
                peaks.append(globalIndex) 
            }
            aboveThreshold = false
        }
    }
}
