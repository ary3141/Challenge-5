//
//  SignalGraph.swift
//  DataCollection
//
//  Created by Muhammad Dwiva Arya Erlangga on 18/09/25.
//

import SwiftUI

struct SignalGraph: View {
    let data: [Double]
    let minY: Double
    let maxY: Double
    let peaks: [Int]
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                guard data.count > 1 else { return }
                
                let range = maxY - minY
                var path = Path()
                
                for (i, value) in data.enumerated() {
                    let x = CGFloat(i) / CGFloat(data.count - 1) * size.width
                    let clippedValue = min(max(value, minY), maxY)
                    let y = size.height - (CGFloat(clippedValue - minY) / CGFloat(range) * size.height)
                    
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                
                context.stroke(path, with: .color(.blue), lineWidth: 2)
                
                for peakIndex in peaks {
                    guard peakIndex < data.count else { continue }
                    let value = min(max(data[peakIndex], minY), maxY)
                    let x = CGFloat(peakIndex) / CGFloat(data.count - 1) * size.width
                    let y = size.height - (CGFloat(value - minY) / CGFloat(range) * size.height)
                    let circle = Path(ellipseIn: CGRect(x: x-2, y: y-2, width: 4, height: 4))
                    context.fill(circle, with: .color(.red))
                }
            }
        }
    }
}
