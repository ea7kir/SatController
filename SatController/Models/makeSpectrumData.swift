//  -------------------------------------------------------------------
//  File: makeSpectrumData.swift
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

enum SpectrumType {
    case line, triangle, channels, beacon
}

func makeSpectrumData(type: SpectrumType) -> SpectrumAPI {
    var spectrum = SpectrumAPI()
    switch type {
    case .line:             // draw a thin line shape
            spectrum.spectrumValue = [0.1,0.1]
    case .triangle:         // draw a simple triangle shape
            spectrum.spectrumValue = [0, 1, 0]
    case .channels:         // draw 28 channel markers
            spectrum.spectrumValue = chanels()
    case .beacon:
            spectrum.spectrumValue = beacon()
    }
    spectrum.beaconValue = 0.5
    return spectrum
}

fileprivate func chanels() -> [Double] {
    // first Int16 represents 10490.500 MHz
    // last Int16 represents 10499.475 MHz
    // spectrum with = 10499.475 - 10490.500 = 8.975 Mhz
    // width between channels = 0.25 MHz
    var array = [Double](repeating: 0.001, count: 918)
    let set: Set = [
        103, //  0 10491.50 Beacon
        230, //  1 10492.75
        256, //  2 10493.00
        281, //  3 10493.25
        307, //  4 10493.50
        332, //  5 10493.75
        358, //  6 10494.00
        383, //  7 10494.25
        409, //  8 10494.50
        434, //  9 10494.75
        460, // 10 10495.00
        485, // 11 10495.25
        511, // 12 10495.50
        536, // 13 10495.75
        562, // 14 10496.00
        588, // 15 10496.25
        613, // 16 10496.50
        639, // 17 10496.75
        664, // 18 10497.00
        690, // 19 10497.25
        715, // 20 10497.50
        741, // 21 10497.75
        767, // 22 10490.00
        792, // 23 10498.25
        818, // 24 10498.50
        843, // 25 10498.75
        869, // 26 10499.00
        894  // 27 10499.25
    ]
        for i in set {
            array[i] = 1
        }
    return array
}

fileprivate func beacon() -> [Double] {
    var array = [Double](repeating: 0, count: 918)
    
    for i in 84...123 {
        array[i] = 1
    }
    return array
}

