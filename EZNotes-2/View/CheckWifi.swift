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
    @Published public var needsNoWifiBanner: Bool = false
    
    private var monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    @Published var isConnectedToWiFi: Bool = false
    @Published var isConnectedToCellular: Bool = false
    
    init() { }
    deinit { self.monitor.cancel() }
    
    /* MARK: We start monitoring after the view has loaded, not before. The view also loads as we start to monitor, making the overall loading a bit easier. */
    final public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self?.isConnectedToWiFi = path.usesInterfaceType(.wifi)
                    self?.isConnectedToCellular = path.usesInterfaceType(.cellular)
                } else {
                    self?.isConnectedToWiFi = false
                    self?.isConnectedToCellular = false
                    self?.needsNoWifiBanner = true
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    final public func manualRetryCheckConnection() {
        if self.monitor.currentPath.status == .satisfied {
            self.isConnectedToWiFi = self.monitor.currentPath.usesInterfaceType(.wifi)
            self.isConnectedToCellular = self.monitor.currentPath.usesInterfaceType(.cellular)
        }
    }
}
