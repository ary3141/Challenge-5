//
//  ContentView.swift
//  DataCollection Watch App
//
//  Created by Muhammad Dwiva Arya Erlangga on 16/09/25.
//

import SwiftUI
import CoreMotion
import Combine

struct ContentView: View {
    @StateObject private var repCounter = RepCounter()
    
    var body: some View {
        VStack(spacing: 10) {
            Text(repCounter.isRunning ? "Recording..." : "Reps: \(repCounter.repCount)")
                .font(.title2)
                .bold()
                .foregroundColor(repCounter.isRunning ? .orange : .primary)
            
            if repCounter.isRunning {
                SignalGraph(data: repCounter.accBuffer, minY: -1.5, maxY: 1.5, peaks: [])
                    .frame(height: 80)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
            } else if !repCounter.finalData.isEmpty {
                SignalGraph(data: repCounter.finalData, minY: -1.5, maxY: 1.5, peaks: repCounter.peaks)
                    .frame(height: 80)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Button(action: {
                repCounter.isRunning ? repCounter.stop() : repCounter.start()
            }) {
                Text(repCounter.isRunning ? "Stop Tracking" : "Start Tracking")
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(repCounter.isRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
        .onDisappear {
            repCounter.stop()
        }
    }
}
