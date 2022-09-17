//  -------------------------------------------------------------------
//  File: RootView.swift
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

// the only application View

struct RootView: View {
    @EnvironmentObject private var root: RootModel

    var body: some View {
        VStack { // OUTER CONTAINER
            HStack { // ROW 1
                CallSignView()
                    .padding()
                    .frame(width: 200)
                    .border(.gray, width: 1)
                StatusView()
                    .padding()
                    .border(.gray, width: 1)
            }
            HStack { // ROW 2
                VStack {
                    SpectrumView(model: root.spectrumModel)
                    ButtonView()
                }
                .padding()
                .border(.gray, width: 1)
            }
            HStack { // ROW 3
                ServerView()
                    .padding()
                    .frame(width: 338, height: 470, alignment: .top)
                    .border(.gray, width: 1)
                ReceiverView()
                    .padding()
                    .frame(width: 338, height: 470, alignment: .top)
                    .border(.gray, width: 1)
                TransmiterView()
                    .padding()
                    .frame(width: 338, height: 470, alignment: .top)
                    .border(.gray, width: 1)
            }
        }
        .preferredColorScheme(.dark)
        .frame(width: 1030)
        .disabled(!root.connectedToSatServer)
        .onAppear(perform: { root.connect() } )
        .onDisappear(perform: { root.exitApplication() } )
    }
}
