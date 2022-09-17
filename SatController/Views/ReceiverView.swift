//  -------------------------------------------------------------------
//  File: ReveiverView.swift
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

struct ReceiverView: View {
    @EnvironmentObject private var root: RootModel
    
    private let ROWHEIGHT = Double(22)
    
    var body: some View {
        VStack {
            Group {
                Text("BATC-MiniTiouner Receiver").frame(height:10, alignment: .top)
                BigGreenText(text: root.rx.freq)
                TinyGreenText(text: root.rx.bandChanDisplay)
            }
            Group {
                HStack {
                    Text("Temperature")
                    Spacer()
                    OrangeText(text: root.rx.temperature)
                }
                HStack {
                    Text("Fan Speed")
                    Spacer()
                    OrangeText(text: root.rx.fanSpeed)
                }
                HStack {
                    Text("Symbol Rate")
                    Spacer()
                    NormalButton(action: { root.request(action: .RxScan) }) {
                        Text("scan")
                            .foregroundColor(root.rx.isScan ? .green : .gray)
                    }
                    NormalButton(action: { root.request(action: .RxSetSR, param: "-") }) {
                        Text("-")
                    }
                    NormalButton(action: { root.request(action: .RxSetSR, param: "+") }) {
                        Text("+")
                        
                    }
                    OrangeText(text: root.rx.sr)
                        .frame(width: 70, alignment: .trailing)
                }
            }
            Group {
                HStack {
                    Text("Mode")
                    Spacer()
                    OrangeText(text: root.rx.mode)
                }
                .frame(height: ROWHEIGHT)
                HStack {
                    Text("Constellation")
                    Spacer()
                    OrangeText(text: root.rx.constellation)
                }
                .frame(height: ROWHEIGHT)
                HStack {
                    Text("FEC")
                    Spacer()
                    OrangeText(text: root.rx.fec)
                }
                .frame(height: ROWHEIGHT)
                HStack {
                    Text("Codecs")
                    Spacer()
                    OrangeText(text: root.rx.codecs)
                }
                .frame(height: ROWHEIGHT)
                HStack {
                    Text("dB MER")
                    Spacer()
                    OrangeText(text: root.rx.mer)
                }
                .frame(height: ROWHEIGHT)
                HStack {
                    Text("dB Margin")
                    Spacer()
                    OrangeText(text: root.rx.margin)
                }
                .frame(height: ROWHEIGHT)
                HStack {
                    Text("dBm Power")
                    Spacer()
                    OrangeText(text: root.rx.power)
                }
                .frame(height: ROWHEIGHT)
                HStack {
                    Text("Provider")
                    Spacer()
                    OrangeText(text: root.rx.provider)
                }
                .frame(height: ROWHEIGHT)
                HStack {
                    Text("Service")
                    Spacer()
                    OrangeText(text: root.rx.service)
                }
                .frame(height: ROWHEIGHT)
            }
            Group {
                HStack {
                    NormalButton(action: { root.request(action: .RxCalibrate) }) { Text("Cal") }
                    Spacer()
                    OrangeText(text: "\(root.rx.tunedFreq) / \(root.rx.tunedSr)")
                    Spacer()
                    OrangeText(text: root.rx.tunedError)
                }
                .frame(height: ROWHEIGHT)
            }
        }
    }
}
