//
//  CheckWifi.swift
//  EZNotes-2
//
//  Created by Aidan White on 11/25/24.
//
import SwiftUI
import Network
import Combine

class NetworkMonitor: ObservableObject {
    private var monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    @Published var isConnectedToWiFi: Bool = false
        @Published var isConnectedToCellular: Bool = false

        init() {
            monitor.pathUpdateHandler = { [weak self] path in
                DispatchQueue.main.async {
                    if path.status == .satisfied {
                        self?.isConnectedToWiFi = path.usesInterfaceType(.wifi)
                        self?.isConnectedToCellular = path.usesInterfaceType(.cellular)
                    } else {
                        self?.isConnectedToWiFi = false
                        self?.isConnectedToCellular = false
                    }
                }
            }
            monitor.start(queue: queue)
        }
}
