//
//  RepCounter.swift
//  DataCollection
//
//  Created by Muhammad Dwiva Arya Erlangga on 18/09/25.
//

import SwiftUI
import CoreMotion
import Combine

class RepCounter: ObservableObject {
    private let motionManager = CMMotionManager()
    private let fs: Double = 50.0
    private let alpha = 0.1
    
    @Published var rawData: [(time: TimeInterval, x: Double, y: Double, z: Double)] = []
    @Published var accBuffer: [Double] = []
    @Published var finalData: [Double] = []
    @Published var peaks: [Int] = []
    @Published var repCount = 0
    @Published var isRunning = false
    
    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        isRunning = true
        rawData.removeAll()
        accBuffer.removeAll()
        finalData.removeAll()
        peaks.removeAll()
        repCount = 0
        
        let startTime = Date()
        motionManager.deviceMotionUpdateInterval = 1.0 / fs
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion = motion else { return }
            
            let x = motion.userAcceleration.x
            let y = motion.userAcceleration.y
            let z = motion.userAcceleration.z
            
            let timestamp = Date().timeIntervalSince(startTime)
            self.rawData.append((time: timestamp, x: x, y: y, z: z))
            

            let magnitude = sqrt(x*x + y*y + z*z)
            self.accBuffer.append(magnitude)
            if self.accBuffer.count > Int(self.fs * 2) {
                self.accBuffer.removeFirst()
            }
        }
    }
    
    func stop() {
        guard isRunning else { return }
        isRunning = false
        motionManager.stopDeviceMotionUpdates()
        processData()
    }
    
    private func processData() {
        guard !rawData.isEmpty else { return }
        
        let magnitudes = rawData.map { sqrt($0.x * $0.x + $0.y * $0.y + $0.z * $0.z) }
    
        var smoothed: [Double] = []
        var lastValue = 0.0
        for value in magnitudes {
            let smooth = alpha * value + (1 - alpha) * lastValue
            smoothed.append(smooth)
            lastValue = smooth
        }
        
        finalData = smoothed
        peaks = detectPeaks(in: smoothed)
        repCount = peaks.count
    }
    
//    private func detectPeaks(in data: [Double]) -> [Int] {
//        guard data.count > 5 else { return [] }
//        var foundPeaks: [Int] = []
//        var lastPeakIndex = -999
//        
//        for i in 2..<data.count-2 {
//            let window = data[(i-2)...(i+2)]
//            if data[i] == window.max(), data[i] > 0.3 {
//                if i - lastPeakIndex > Int(0.6 * fs) {
//                    foundPeaks.append(i)
//                    lastPeakIndex = i
//                }
//            }
//        }
//        return foundPeaks
//    }
    private func detectPeaks(in data: [Double]) -> [Int] {
        guard data.count > 5 else { return [] }
        var foundPeaks: [Int] = []
        var lastPeakIndex = -999
        let baseline = data.prefix(10).reduce(0, +) / Double(min(10, data.count))
        let resetThreshold = baseline + 0.1
        var waitingForReset = false
        
        for i in 2..<data.count-2 {
            let window = data[(i-2)...(i+2)]
            if data[i] == window.max(), data[i] > 0.3 {
                
                if !waitingForReset, i - lastPeakIndex > Int(0.6 * fs) {
                    foundPeaks.append(i)
                    lastPeakIndex = i
                    waitingForReset = true
                }
            }
            if waitingForReset, data[i] < resetThreshold {
                waitingForReset = false
            }
        }
        return foundPeaks
    }

    private func detectReps(in data: [Double]) -> [Int] {
        guard data.count > 5 else { return [] }
        var reps: [Int] = []
        var aboveThreshold = false
        var lastCrossIndex = -999
        let threshold = 0.35

        for i in 1..<data.count {
            let current = data[i]
            let prev = data[i - 1]

            if !aboveThreshold && current > threshold && prev <= threshold {
                aboveThreshold = true
                lastCrossIndex = i
            }
            if aboveThreshold && current < threshold && prev >= threshold {
                if i - lastCrossIndex > Int(0.5 * fs) {
                    reps.append(i)
                }
                aboveThreshold = false
            }
        }
        return reps
    }

}
