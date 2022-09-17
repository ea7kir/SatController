//  -------------------------------------------------------------------
//  File: SatControllerApp.swift
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
import Yams

let logProgress = false
let logErrors = false

func logProgress(_ str: String) {
    if logProgress {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = format.string(from: date)
        print("\(timestamp) - \(str)")
    }
}

func logError(_ str: String) {
    if logErrors {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = format.string(from: date)
        print("\(timestamp) - ERROR: \(str)")
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

// TODO: implement this and pass things to SatServer
struct YAMLConfig: Codable {
    var warning = "edit at your peril"
    var SVR_Host = "satserver.local"
    var SVR_Port = 8001
//     var RCV_Port = 8002
//     var beacon = true
//     var duplex = false
//     var simplexBand = 2
//     var simplexChannel = 27
//     var duplexRXBand = 2
//     var duplexRXChannel = 10
//     var duplexTXBand = 2
//     var duplexTXChannel = 11
//     var provider = "EA7KIR"
//     var service = "Malaga"
//     var TS_Host = "office.local"
//     var TS_Port = 7777
}


func readYAML() -> YAMLConfig {
    var config = YAMLConfig()
    let filename = "/Users/mike/SatController.yaml"
//    let filename = "~/SatController.yaml" // TODO: this doesn't work

    do {
        // read configuration
//        let url = URL(fileURLWithPath: filename)
//        let yaml = try String(contentsOf: url)
        let yaml = try String(contentsOfFile: filename)
        let decoder = YAMLDecoder()
        config = try decoder.decode(YAMLConfig.self, from: yaml)
    } catch {
        // write default YAML configuration
        logError("SatControllerApp.\(#function) in App failed to read \(filename)")
        logProgress("SatControllerApp.\(#function) in App creating default configuration file")
        let defaultConfig = YAMLConfig()
        let encoder = YAMLEncoder()
        let encodedYAML = try! encoder.encode(defaultConfig)
        do {
            try encodedYAML.write(toFile: filename, atomically: true, encoding: .utf8)
        } catch {
            logError("SatControllerApp.\(#function) in App failed to create: \(filename)")
            fatalError()
        }
    }
    return config
}

@main
struct SatControllerApp: App {
    @StateObject private var root: RootModel

    init() {
        
        let config = readYAML()
        
        self._root = StateObject(wrappedValue: RootModel(config: config))
        
//        for runningApplication in NSWorkspace.shared.runningApplications {
//            let appName = runningApplication.localizedName
//            if appName == "SatController" {
//                print("SatControllerApp.\(#function) in MAIN ############# terminate #################")
//                runningApplication.terminate()
//            }
//        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(root)
                .preferredColorScheme(.dark)
                .frame(width: 1030)
                .padding()
            //            .onDisappear(perform: { vm.quitApplication() })
            
        }
        // TODO: Call RootModel.exitApplication() before Quit
                .commands {
                    CommandGroup(replacing: .appTermination, addition:  {
                        Button(action: {
//                            quitApplication()
                            self.root.exitApplication()
                        }) {
                            Text("Quit SatController")
                        }.keyboardShortcut("Q")
                    })
                }
        
        //        Settings {
        //            SettingsView()
        //        }
    }
    
//    func quitApplication() {
//        logProgress("SatControllerApp.\(#function) quitApplication was called")
//        
//        self.root.exitApplication()
//        
//        for runningApplication in NSWorkspace.shared.runningApplications {
//            let appName = runningApplication.localizedName
//            if appName == "SatController" {
//                runningApplication.terminate()
//            }
//        }
//    }
    
    
}
