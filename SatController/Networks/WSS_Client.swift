//  -------------------------------------------------------------------
//  File: WebSocketStream.swift
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

class WSS_Client: AsyncSequence {
    
    // from https://obscuredpixels.com/awaiting-websockets-in-swiftui
    
    typealias Element = URLSessionWebSocketTask.Message
    typealias AsyncIterator = AsyncThrowingStream<URLSessionWebSocketTask.Message, Error>.Iterator
    
    private var stream: AsyncThrowingStream<Element, Error>?
    private var continuation: AsyncThrowingStream<Element, Error>.Continuation?
    private let socket: URLSessionWebSocketTask
    
    init(url: String) {
        let session: URLSession = URLSession(configuration: .ephemeral)
        socket = session.webSocketTask(with: URL(string: url)!)
        stream = AsyncThrowingStream { continuation in
            self.continuation = continuation
            self.continuation?.onTermination = { @Sendable [socket] _ in
                socket.cancel()
                logProgress("WSS_Client.\(#function) : cancel was called")
            }
        }
    }
    
    // TODO: disconnect() is my addition
    func disconnect() {
        logProgress("WSS_Client.\(#function) : called")
        continuation?.finish(throwing: nil)
        socket.cancel(with: .normalClosure, reason: nil)
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        guard let stream = stream else {
            logError("WSS_Client.(#function) : WebSocketStreamstream was not initialized")
            fatalError("WebSocketStreamstream was not initialized")
        }
        socket.resume()
        listenForMessages()
        return stream.makeAsyncIterator()
    }
    
    private func listenForMessages() {
        socket.receive { [unowned self] result in
            switch result {
                case .success(let message):
                    continuation?.yield(message)
                    listenForMessages()
                case .failure(let error):
                    continuation?.finish(throwing: error)
            }
        }
    }
    
    // TODO: send() has not been tested
    func send(data: Data) async {
        let message = URLSessionWebSocketTask.Message.data(data)
        do {
            try await socket.send(message)
        } catch {
            logError("WSS_Client.\(#function) : failed to send Data")
        }
    }
    
    // TODO: send() is not required, so has not been tested
    func send(str: String) async {
        let message = URLSessionWebSocketTask.Message.string(str)
        do {
            try await socket.send(message)
        } catch {
            logError("WSS_Client\(#function) : falied to send String")
        }
    }
}
