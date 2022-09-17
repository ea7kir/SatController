//  -------------------------------------------------------------------
//  File: SatServerView.swift
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

struct ServerView: View {
    @EnvironmentObject private var root: RootModel
    @State private var showingRestartAlert = false
    @State private var showingRebootAlert = false
    @State private var showingShutdownAlert = false
    
    private let ROWHEIGHT = Double(22)
    
    var body: some View {
        VStack {
            Group {
                Text("SatServer Status").frame(height:10, alignment: .top)
                BigGreenText(text: root.connectedToSatServer ? "ON LINE" : "OFF LINE")
                TinyGreenText(text: "\("host"):\(String("port"))")
            }
            Group {
                HStack {
                    Text("Temperature")
                    Spacer()
                    OrangeText(text: root.ss.temperature)
                }
                HStack {
                    Text("Fan Speed")
                    Spacer()
                    OrangeText(text: root.ss.fanSpeed)
                }
            }
            Group {
                HStack {
                    Text("Last Boot").padding(.top, 5)
                    Spacer()
                    OrangeText(text: root.ss.lastBoot)
                }
                HStack {
                    Text("Up Time")
                    Spacer()
                    OrangeText(text: root.ss.upTime)
                }
            }
            Group {
                Text("Power Supplies").padding(2)
                HStack {
                    Text("5 volt")
                    Spacer()
                    OrangeText(text: root.ss.supply5v)
                }
                HStack {
                    Text("12 volt")
                    Spacer()
                    NormalButton(action: { root.request(action: .Toggle12v) }) {
                        Text(root.ss.psu12vIsOn ? "ON" : "OFF")
                    }
                    OrangeText(text: root.ss.supply12v)
                }
                HStack {
                    Text("28 volt")
                    Spacer()
                    NormalButton(action: { root.request(action: .Toggle28v) }) {
                        Text(root.ss.psu28vIsOn ? "ON" : "OFF")
                    }
                    OrangeText(text: root.ss.supply28v)
                }
            }
            Group {
                Text("Enclosure").padding(2)
                HStack {
                    Text("Humidity/Temperature")
                    Spacer()
                    OrangeText(text: root.ss.encClimate)
                }
                HStack {
                    Text("Fan Speeds (Intake/Extract)")
                    Spacer()
                    OrangeText(text: root.ss.encFanSpeeds)
                }
                .frame(height: ROWHEIGHT)
            }
            Group {
                Text("System").padding(2)
                HStack {
                    NormalButton(action: { showingRebootAlert = !root.rebooting }) {
                        Text("REBOOT")
                    }.alert(isPresented: $showingRebootAlert) {
                        Alert(
                            title: Text("THIS WILL REBOOT EVERYTHING"),
                            message: Text("in an orderly fashion"),
                            primaryButton: .destructive(Text("Continue")) {
                                showingRebootAlert = false
                                root.rebooting = true
                                root.reboot()
                                root.rebooting = false
                            },
                            secondaryButton: .cancel() {
                                showingRebootAlert = false
                            }
                        )
                    }
                    NormalButton(action: { showingShutdownAlert = !root.shuttingDown }) {
                        Text("SHUTDOWN")
                    }.alert(isPresented: $showingShutdownAlert) {
                        Alert(
                            title: Text("THIS WILL SWITCH OFF EVERYTHING"),
                            message: Text("following an orderly shutdown"),
                            primaryButton: .destructive(Text("Continue")) {
                                showingShutdownAlert = false
                                root.shuttingDown = true
                                root.shutdown()
                                root.shuttingDown = false
                            },
                            secondaryButton: .cancel() {
                                showingShutdownAlert = false
                            }
                        )
                    }
                }
            }
            
        }
    }
}
