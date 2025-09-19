//
//  ContentView 2.swift
//  DataCollection
//
//  Created by Muhammad Dwiva Arya Erlangga on 18/09/25.
//

import SwiftUI
import Combine

struct ContentViewLive: View {
    @StateObject private var repCounter = RepCounterLive()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Reps: \(repCounter.repCount)")
                .font(.system(size: 36, weight: .bold))
                .padding(.top, 12)

            SignalGraphLive(
                data: repCounter.liveSmoothed,
                peaks: repCounter.peaks.filter { $0 > repCounter.globalIndex - Int(3 * 50) }, // show only recent peaks
                globalIndex: repCounter.globalIndex
            )
            .frame(height: 100)
            .background(Color.black.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                repCounter.isRunning ? repCounter.stop() : repCounter.start()
            }) {
                Text(repCounter.isRunning ? "Stop" : "Start")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(repCounter.isRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            .padding()
        }
        .onDisappear { repCounter.stop() }
    }
}

