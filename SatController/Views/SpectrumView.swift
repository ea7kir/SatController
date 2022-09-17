//  -------------------------------------------------------------------
//  File: SpectrumView.swift
//
//  This file is part of the SatController 'Suite'. It's purpose is
//  to remotely control and monitor a QO-100 DATV station over a LAN.
//
//  Copyright (C) 2021 Michael Naylor EA7KIR http://michaelnaylor.es
//
//  The 'Suite' is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  The 'Suite' is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General License for more details.
//
//  You should have received a copy of the GNU General License
//  along with  SatServer.  If not, see <https://www.gnu.org/licenses/>.
//  -------------------------------------------------------------------

import SwiftUI

struct SpectrumView: View {
    @ObservedObject var model: SpectrumModel
    
    var body: some View {
            HStack {
                VStack {
                    GraticuleSideLegend(align: .topTrailing)
                }
                VStack {
                    HStack {
                        GraticuleTopLegend()
                    }
                    .frame(width: 1000, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    ZStack {
                        GraticuleLines()
                        FilledPolygonGraph(dataPoints: model.spectrum.spectrumValue)
                            .fill(LinearGradient(
                                gradient: Gradient(
                                    stops: [.init(color: .red, location: 0.0),
                                            .init(color: .red, location: model.spectrum.beaconValue - 0.05),
                                            .init(color: .orange, location: model.spectrum.beaconValue),
                                            .init(color: .green, location: model.spectrum.beaconValue + 0.05),
                                        .init(color: .green, location: 1.0)
                                    ]),
                                startPoint: .top, endPoint: .bottom))
                    }
                }
                .frame(width: 918) //, height: 300)
                VStack {
                    GraticuleSideLegend(align: .leading)
                }
            }
            .frame(width: 996, height: 300) // 374
    }
}

private struct GraticuleTopLegend: View {
    
    var body: some View {
        // I can't get these to position correctly if not like this
        HStack {
            Text("10491.50").padding(.leading, 118) // Beacon
            Text("10493").padding(.leading, 96)     // 2
            Text("10494").padding(.leading, 55.5)   // 6
            Text("10495").padding(.leading, 55.5)   // 10
        }
        HStack {
            Text("10496").padding(.leading, 55.5)   // 14
            Text("10497").padding(.leading, 55.5)   // 18
            Text("10498").padding(.leading, 55.5)   // 22
            Text("10499").padding(.leading, 55.5)   // 26
        }
        Spacer()
    }
}

private struct GraticuleSideLegend: View {
    let align: Alignment
    
    var body: some View {
        VStack {
            Text("15dB").padding(.top, 17)
            Text("10dB").padding(.top, 59)
            Text("5dB").padding(.top, 59)
            Spacer()
        }
    }
}

private struct GraticuleLines: View {
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let incY = geometry.size.height / 16
                var Y = Double(0)
                for _ in 1...17 {
                    path.move(to: CGPoint(x: 0, y: Y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: Y))
                    Y += incY
                }
            }
            .stroke(style: StrokeStyle( lineWidth: 1, dash: [5]))
            .foregroundColor(Color.gray)
        }
    }
}

private struct FilledPolygonGraph: Shape {
    // inspired by https://www.youtube.com/watch?v=fNLxMUxFXvg
    // normalized data points between 0 and 1
    let dataPoints: [Double]
    
    func path(in rect: CGRect) -> Path {
        
        func point(at ix: Int) -> CGPoint {
            let point = dataPoints[ix]
            let x = rect.width * Double(ix) / Double(dataPoints.count - 1)
            let y = (1 - point) * rect.height
            return CGPoint(x: x, y: y)
        }
        
        return Path { p in
            guard dataPoints.count > 1 else { return }
            let start = dataPoints[0]
            p.move(to: CGPoint(x: 0, y: (1 - start) * rect.height))
            
            for idx in dataPoints.indices {
                p.addLine(to: point(at: idx))
            }
            
            // finally, close the the path
            p.addLine(to: CGPoint(x: rect.width, y: 1 * rect.height))
            p.addLine(to: CGPoint(x: 0, y: 1 * rect.height))
            p.addLine(to: CGPoint(x: 0, y: (1 - start) * rect.height))
        }
    }
}
