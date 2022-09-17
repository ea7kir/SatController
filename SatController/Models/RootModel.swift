//  -------------------------------------------------------------------
//  File: RootModel.swift
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

import Foundation

// TODO: 1) @Publish ss,bb,rx,tx,status, to the Views.  Best to start with the spectrum...
// TODO: 2) rethink where all the servera and client should reside


@MainActor
final class RootModel: ObservableObject {
    
    @Published var status: String = ""
    @Published var restarting: Bool = false
    @Published var rebooting: Bool = false
    @Published var shuttingDown: Bool = false
//    @Published var spectrum = SpectrumAPI()
    
    @Published var connectedToSatServer: Bool = false
//    @Published var connectedToGoonhilly: Bool = false
    
    @Published var bb = BbStatusAPI()
    @Published var ss = SsStatusAPI()
    @Published var rx = RxStatusAPI()
    @Published var tx = TxStatusAPI()
    
    let spectrumModel = SpectrumModel()
    private var spectrumServerOnline: Bool = false
    
//    let buttonsModel = ButtonsModel()
    
//    private var spectrumStream: WSS_Client?
    private var satServerClient: NIO_TCP_Client?
    private let SVR_Host: String
    private var SVR_Port: Int
    
    init(config: YAMLConfig) {
        self.SVR_Host = config.SVR_Host
        self.SVR_Port = config.SVR_Port
    }
    
    func satServerOnline() -> Bool {
        return satServerClient?.isConnected != nil
    }
    
    func connect() { // called from RootView.onAppwar
        status = "Connecting to SatServer..."
        do {
            satServerClient = try NIO_TCP_Client.connect(host: SVR_Host, port: SVR_Port) {
                self.satServerCallback(data: $0)
            }
            connectedToSatServer = true
            status = "Connected to \(SVR_Host):\(SVR_Port)"
        } catch {
            status = "Unable to connect to \(SVR_Host):\(SVR_Port)"
        }
        
        if satServerOnline() {
            status = "Connecting tp Goonhilly"
            spectrumModel.connect()
//            spectrumStream = WSS_Client(url: "wss://eshail.batc.org.uk/wb/fft/fft_ea7kirsatcontroller")
            spectrumServerOnline = true
            if spectrumServerOnline {
//                connectedToGoonhilly = true
                status = "Connected to SatSever and Goonhilly"
//                spectrumStreamBegin()
            }
        }
        
    }
    
    func satServerCallback(data: Data) {
        Task {
            do {
                let latest = try JSONDecoder().decode(ServerStatusAPI.self, from: data)
                
//                buttonsModel.setButtons(incoming: latest.bb)
                
                DispatchQueue.main.async { [unowned self] in
                    bb = latest.bb
                    ss = latest.ss
                    rx = latest.rx
                    tx = latest.tx
                }
            } catch {
                logError("RootModel.\(#function) in RootModel failed to decode") //:\n\(error)")
            }
        }
    }
    
    func disconnect() {
        status = "Disconnecting..."
        if satServerOnline() {
            logProgress("RootModel.\(#function) in RootModel")
            satServerClient?.disconnect()
            connectedToSatServer = false
        }
//        if spectrumServerOnline {
//            spectrumModel.disconnect()
//            spectrumServerOnline = false
//            connectedToGoonhilly = false
//        }
        if spectrumModel.connected {
            spectrumModel.disconnect()
        }
        status = "Disconnected"
    }
    
//    func spectrumStreamBegin() {
//        Task {
//            var tmpSpectrum = SpectrumAPI()
//            for try await message in spectrumStream! {
//                switch message {
//                case .data(let data):
//                    if data.count == 1844 {
//                        for i in stride(from: 0, to: 1836, by: 2) {
//                            var uint16 = UInt16(data[i]) + UInt16(data[i+1]) << 8
//                            // chop off 1/8 noise
//                            if uint16 < 8192 {
//                                uint16 = 8192
//                            }
//                            let double = Double(uint16 - UInt16(8192)) / Double(52000)
//                            tmpSpectrum.spectrumValue[i / 2] = double
//                        }
//                        tmpSpectrum.beaconValue = 0
//                        for i in 73...133 { // beacon center is 103
//                            tmpSpectrum.beaconValue += tmpSpectrum.spectrumValue[i]
//                        }
//                        // invert y axis
//                        tmpSpectrum.beaconValue = 1.0 - tmpSpectrum.beaconValue / 61
//                        DispatchQueue.main.async { [unowned self] in
//                            spectrum = tmpSpectrum
//                        }
//                    } else {
//                        logError("RootModel.\(#function) in RootModel data != 1844")
//                    }
//                case .string(let string):
//                    logError("RootModel.\(#function) in RootModel dreceived string \(string)")
//                default:
//                    logError("RootModel.\(#function) in RootModel dunknown message type")
//                }
//            }
//        }
//    }
    
    func reboot() {
        Task {
            status = "Rebooting SatServer..."
            request(action: .Reboot)
            try await Task.sleep(seconds: 2.0)
            disconnect()
            try await Task.sleep(seconds: 3.0)
//            self.spectrum = SpectrumAPI()
//            exit(0)
            connect()
        }
    }
    
    func shutdown() {
        logProgress("RootModel.\(#function) in RootModel sending .SHUTDOWN...")
        Task {
            status = "Shutting down SatServer..."
            request(action: .Shutdown)
            try await Task.sleep(seconds: 2.0)
            disconnect()
            status = "Quiting SatController..."
//            self.spectrum = SpectrumAPI()
            try await Task.sleep(seconds: 1.0)
            exit(0)
        }
    }
    
    func exitApplication() { // called from RootView.onDisappear AND APP.QUIT button
        print("RootModel.\(#function) in RootModel sending .STANDBY...")
        sleep(1)
//        Task {
            request(action: .Standby)
            print("RootModel.\(#function) in RootModel step 1")
//            Task { try await Task.sleep(seconds: 1.0) }
        sleep(1)
            disconnect()
            print("RootModel.\(#function) in RootModel step 2")
//            Task {try await Task.sleep(seconds: 1.0) }
        sleep(1)
            print("RootModel.\(#function) in RootModel step 3")
            exit(0)
//        }
    }
    
    func request(action: ServerCommandType, param: String = "") {
        let request = ServerCommandAPI(action: action, param: param)
        status = "Sending: \(request.action) \(request.param)"
        do {
            let data =  try JSONEncoder().encode(request)
            satServerClient?.send(data)
        } catch {
            logError("RootModel.\(#function) in RootModel failed to send:\n\(error)")
        }
    }
    
}
