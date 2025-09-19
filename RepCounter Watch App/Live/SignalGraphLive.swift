//
//  SignalGraph 2.swift
//  DataCollection
//
//  Created by Muhammad Dwiva Arya Erlangga on 18/09/25.
//

import SwiftUI

struct SignalGraphLive: View {
    var data: [Double]
    var peaks: [Int]
    var globalIndex: Int
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            let minY = data.min() ?? 0
            let maxY = data.max() ?? 1
            let range = max(maxY - minY, 0.001)
            let stepX = width / CGFloat(max(data.count - 1, 1))
            
            ZStack {
                // 📈 Main line
                Path { path in
                    for (i, value) in data.enumerated() {
                        let x = CGFloat(i) * stepX
                        let y = height - CGFloat((value - minY) / range) * height
                        
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2)

                ForEach(peaks, id: \.self) { peakIndex in
                    let startIndex = max(0, globalIndex - data.count)
                    let relativeIndex = peakIndex - startIndex
                    
                    if relativeIndex >= 0 && relativeIndex < data.count {
                        let x = CGFloat(relativeIndex) * stepX
                        let y = height - CGFloat((data[relativeIndex] - minY) / range) * height
                        
                        Circle()
                            .fill(Color.red)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                    }
                }
            }
        }
    }
}

