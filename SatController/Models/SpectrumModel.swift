//  -------------------------------------------------------------------
//  File: SpectrumModel.swift
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

final class SpectrumModel : ObservableObject {
    
    @Published var spectrum = SpectrumAPI()
    
    private var tmpSpectrum = SpectrumAPI()
    private var spectrumStream: WSS_Client?

    var connected = false
    
    func connect() {
        spectrumStream = WSS_Client(url: "wss://eshail.batc.org.uk/wb/fft/fft_ea7kirsatcontroller")
        spectrumStreamBegin()
        connected = true
    }
    
    func disconnect() {
        spectrumStream!.disconnect()
        connected = false
    }
    
    private func spectrumStreamBegin() {
        Task {
            for try await message in spectrumStream! {
                switch message {
                case .data(let data):
                    if data.count == 1844 {
                        for i in stride(from: 0, to: 1836, by: 2) {
                            var uint16 = UInt16(data[i]) + UInt16(data[i+1]) << 8
                            // chop off 1/8 noise
                            if uint16 < 8192 {
                                uint16 = 8192
                            }
                            let double = Double(uint16 - UInt16(8192)) / Double(52000)
                            tmpSpectrum.spectrumValue[i / 2] = double
                        }
                        tmpSpectrum.beaconValue = 0
                        for i in 73...133 { // beacon center is 103
                            tmpSpectrum.beaconValue += tmpSpectrum.spectrumValue[i]
                        }
                        // invert y axis
                        tmpSpectrum.beaconValue = 1.0 - tmpSpectrum.beaconValue / 61
                        DispatchQueue.main.async { [unowned self] in
                            spectrum = tmpSpectrum
                        }
                    } else {
                        logError("RootModel.\(#function) in RootModel data != 1844")
                    }
                case .string(let string):
                    logError("RootModel.\(#function) in RootModel dreceived string \(string)")
                default:
                    logError("RootModel.\(#function) in RootModel dunknown message type")
                }
            }
        }
    }
}

