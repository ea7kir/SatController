//  -------------------------------------------------------------------
//  File: ButtonView.swift
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

struct ButtonView: View {
    @EnvironmentObject var root: RootModel
    var body: some View {
        HStack {
            ShowMemoryButtons()
                .frame(width: 172, alignment: .trailing) // set where the ModeButtons begin
            ShowModeButtons()
                .frame(width: 64, alignment: .trailing) // sets the where the BandButtons begin
            VStack {
                ShowVeryNarrowBandButtons()
                    .padding(.leading, 12.7)
                ShowNarrowBandButtons()
                ShowWideBandButtons()
            }
        }
        .padding(.top, 5)
    }
}

fileprivate struct ShowMemoryButtons: View { // Band 0
    @EnvironmentObject var root: RootModel
    
    var body: some View {
        VStack {
            MemoryModeButton(action: { root.request(action: .SetBeacon) }) {
                Text("beacon")
                    .foregroundColor(root.bb.state == .Beacon ? .green : .primary)
            }
            MemoryModeButton(action: { root.request(action: .SetRecall) }) {
                Text("recall")
                    .foregroundColor(.primary)
            }
            MemoryModeButton(action: { root.request(action: .SetStore) }) {
                Text("store")
                    .foregroundColor(.primary)
            }
        }
    }
}

fileprivate struct ShowModeButtons: View {
    @EnvironmentObject var root: RootModel
    
    func modeName() -> String {
        switch root.bb.state {
            case .Simplex:
                return "simplex"
            case .DuplexRx, .DuplexTx:
                return "duplex"
            default:
                return " "
        }
    }
    
    func rxColor() -> Color {
        switch root.bb.state {
            case .Simplex, .DuplexRx:
                return .green
            default:
                return .primary
        }
    }
    
    func txColor() -> Color {
        switch root.bb.state {
            case .Simplex, .DuplexTx:
                return .green
            default:
                return .primary
        }
    }
    
    var body: some View {
        VStack {
            MemoryModeButton(action: { root.request(action: .SetRxSelect) }) {
                Text("Rx")
                    .foregroundColor(rxColor())
            }
            Text(modeName())
                .foregroundColor(.green)

            MemoryModeButton(action: { root.request(action: .SetTxSelect) }) {
                Text("Tx")
                    .foregroundColor(txColor())
            }
        }
    }
}

fileprivate struct ShowVeryNarrowBandButtons: View { // Band 1
    @EnvironmentObject var root: RootModel
    
    var body: some View {
        HStack {
            Group {
                VeryNarrowBandButton(channel: 1)
                VeryNarrowBandButton(channel: 2)
                VeryNarrowBandButton(channel: 3)
                VeryNarrowBandButton(channel: 4)
                VeryNarrowBandButton(channel: 5)
                VeryNarrowBandButton(channel: 6)
                VeryNarrowBandButton(channel: 7)
                VeryNarrowBandButton(channel: 8)
                VeryNarrowBandButton(channel: 9)
            }
            Group {
                VeryNarrowBandButton(channel: 10)
                VeryNarrowBandButton(channel: 11)
                VeryNarrowBandButton(channel: 12)
                VeryNarrowBandButton(channel: 13)
                VeryNarrowBandButton(channel: 14)
                VeryNarrowBandButton(channel: 15)
                VeryNarrowBandButton(channel: 16)
                VeryNarrowBandButton(channel: 17)
                VeryNarrowBandButton(channel: 18)
            }
            Group {
                VeryNarrowBandButton(channel: 19)
                VeryNarrowBandButton(channel: 20)
                VeryNarrowBandButton(channel: 21)
                VeryNarrowBandButton(channel: 22)
                VeryNarrowBandButton(channel: 23)
                VeryNarrowBandButton(channel: 24)
                VeryNarrowBandButton(channel: 25)
                VeryNarrowBandButton(channel: 26)
                VeryNarrowBandButton(channel: 27)
            }
            Spacer()
        }
    }
}

fileprivate struct ShowNarrowBandButtons: View { // Band 2
    @EnvironmentObject var root: RootModel
    
    var body: some View {
        HStack {
            Group {
                NarrowBandButton(channel: 1)
                NarrowBandButton(channel: 2)
                NarrowBandButton(channel: 3)
                NarrowBandButton(channel: 4)
                NarrowBandButton(channel: 5)
                NarrowBandButton(channel: 6)
                NarrowBandButton(channel: 7)
            }
            Group {
                NarrowBandButton(channel: 8)
                NarrowBandButton(channel: 9)
                NarrowBandButton(channel: 10)
                NarrowBandButton(channel: 11)
                NarrowBandButton(channel: 12)
                NarrowBandButton(channel: 13)
                NarrowBandButton(channel: 14)
            }
            Spacer()
        }
    }
}

fileprivate struct ShowWideBandButtons: View {
    @EnvironmentObject var root: RootModel
    
    var body: some View {
        HStack {
            WideBandButton(channel: 1)
            WideBandButton(channel: 2)
            WideBandButton(channel: 3)
            Spacer()
        }
    }
}

// MARK: Custom Buttons

fileprivate func colorSelected(band: Int, channel: Int, bb: BbStatusAPI) -> Color {
    if band == bb.rxBand && channel == bb.rxChannel && bb.state == .Simplex {
        return .orange
    }
    if band == bb.rxBand && channel == bb.rxChannel {
        return .green
    }
    if band == bb.txBand && channel == bb.txChannel {
        return .red
    }
    return .primary
}


fileprivate struct VeryNarrowBandButton: View {
    @EnvironmentObject var root: RootModel
    
    let band = 1
    let channel: Int
    let width = 17.57
    let hieght = 16.0
    
    init(channel: Int) {
        self.channel = channel
    }
    
    var body: some View {
        Button(action: { root.request(action: .SetVeryNarrow, param: String(channel)) } ) {
            Text(String(channel % 10))
                .frame(width: width - 9)
                .foregroundColor(colorSelected(band: band, channel: channel, bb: root.bb))
                .font(.system(.footnote, design: .default))
        }
        .frame(width: width, height: hieght)
    }
}

fileprivate struct NarrowBandButton: View {
    @EnvironmentObject var root: RootModel
    
    let band = 2
    let channel: Int
    let width = 43.2
    let hieght = 16.0
    
    init(channel: Int) {
        self.channel = channel
    }
    var body: some View {
        Button(action: { root.request(action: .SetNarrow, param: String(channel)) } ) {
            Text(String(channel))
                .frame(width: width - 9)
                .foregroundColor(colorSelected(band: band, channel: channel, bb: root.bb))
                .font(.system(.footnote, design: .default))
        }
        .frame(width: width, height: hieght)
    }
}

fileprivate struct WideBandButton: View {
    @EnvironmentObject var root: RootModel
    
    let band = 3
    let channel: Int
    let width = 145.6
    let hieght = 16.0
    
    init(channel: Int) {
        self.channel = channel
    }
    var body: some View {
        Button(action: { root.request(action: .SetWide, param: String(channel)) } ) {
            Text(String(channel))
                .frame(width: width - 9)
                .foregroundColor(colorSelected(band: band, channel: channel, bb: root.bb))
                .font(.system(.footnote, design: .default))
        }
        .frame(width: width, height: hieght)
    }
}

fileprivate struct MemoryModeButton<whateverYouWant: View>: View {
    let action: () -> Void
    let content: whateverYouWant
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> whateverYouWant) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
                .frame(width: 40)
                .font(.system(.footnote, design: .default))
                .frame(width: 40)
        }
        .frame(height: 16)
    }
}

