//  -------------------------------------------------------------------
//  File: TransmitterView.swift
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

struct TransmiterView: View {
    @EnvironmentObject private var root: RootModel

    var body: some View {
        VStack {
            Group {
                Text("ADALM-Pluto Transmitter").frame(height:10, alignment: .top)
                BigGreenText(text: root.tx.frequency)
                TinyGreenText(text: root.tx.bandChanDisplay)
            }
            Group {
                HStack {
                    Text("Temperatures (pluto/zynq)")
                    Spacer()
                    OrangeText(text: root.tx.plutoTemperatures)
                }
                HStack {
                    Text("Fan Speed")
                    Spacer()
                    OrangeText(text: root.tx.fanSpeed)
                }
            }
            Group {
                HStack {
                    Text("Symbol Rate")
                    Spacer()
                    NormalButton(action: { root.request(action: .TxSetSR, param: "-") }) { Text("-") }
                    NormalButton(action: { root.request(action: .TxSetSR, param: "+") }) { Text("+") }
                    OrangeText(text: root.tx.sr)
                        .frame(width: 70, alignment: .trailing)
                }
                HStack {
                    Text("Mode")
                    Spacer()
                    NormalButton(action: { root.request(action: .TxSetMode, param: "-") }) { Text("-") }
                    NormalButton(action: { root.request(action: .TxSetMode, param: "+") }) { Text("+") }
                    OrangeText(text: root.tx.mode)
                        .frame(width: 70, alignment: .trailing)
                }
                HStack {
                    Text("Constellation")
                    Spacer()
                    NormalButton(action: { root.request(action: .TxSetConstellation, param: "-") }) { Text("-") }
                    NormalButton(action: { root.request(action: .TxSetConstellation, param: "+") }) { Text("+") }
                    OrangeText(text: root.tx.constellation)
                        .frame(width: 70, alignment: .trailing)
                }
                HStack {
                    Text("FEC")
                    Spacer()
                    NormalButton(action: { root.request(action: .TxSetFEC, param: "-") }) { Text("-") }
                    NormalButton(action: { root.request(action: .TxSetFEC, param: "+") }) { Text("+") }
                    OrangeText(text: root.tx.fec)
                        .frame(width: 70, alignment: .trailing)
                }
                HStack {
                    Text("Codecs")
                    Spacer()
                    NormalButton(action: { root.request(action: .TxSetCodecs, param: "-") }) { Text("-") }
                    NormalButton(action: { root.request(action: .TxSetCodecs, param: "+") }) { Text("+") }
                    OrangeText(text: root.tx.codecs)
                        .frame(width: 70, alignment: .trailing)
                }
                HStack {
                    Text("Drive")
                    Spacer()
                    NormalButton(action: { root.request(action: .TxDrive, param: "-") }) { Text("-") }
                    NormalButton(action: { root.request(action: .TxDrive, param: "+") }) { Text("+") }
                    OrangeText(text: root.tx.drive)
                        .frame(width: 70, alignment: .trailing)
                }
            }
            Group {
                HStack {
                    Button { root.request(action: .TxTogglePtt)
                    } label: {
                        Text("TRANSMIT") // .foregroundColor(root.tx.ptt ? .red : .none)
                            .frame(width: 150)
                    }
                    .background(root.tx.ptt ? Color.red : Color.clear)
                }
                .padding([.top, .bottom], 8)
            }
            Group {
                Text("PA Driver")
                    .foregroundColor(root.tx.driveIsOn ? .red : .none)
                HStack {
                    Text("Temperature")
                    Spacer()
                    OrangeText(text: root.tx.driveTemperature)
                }
                HStack {
                    Text("Fan Speed")
                    Spacer()
                    OrangeText(text: root.tx.driveFanSpeed)
                }
            }
            Group {
                Text("Final PA")
                    .foregroundColor(root.tx.paIsOn ? .red : .none)
                HStack {
                    Text("Temperature")
                    Spacer()
                    OrangeText(text: root.tx.paTemperature)
                }
                HStack {
                    Text("Fan Speeds (Intake/Extract)")
                    Spacer()
                    OrangeText(text: root.tx.paFanSpeeds)
                }
            }
        }
    }
}

