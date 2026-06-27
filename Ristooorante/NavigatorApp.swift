//
//  NavigatorApp.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import Foundation
import UIKit
import CoreLocation

enum NavigatorApp: String, CaseIterable, Identifiable {
    case appleMaps
    case googleMaps
    case waze
    case tomtomGo
    case sygic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .appleMaps: return "Apple Maps"
        case .googleMaps: return "Google Maps"
        case .waze: return "Waze"
        case .tomtomGo: return "TomTom GO"
        case .sygic: return "Sygic"
        }
    }

    var icon: String {
        switch self {
        case .appleMaps: return "map.fill"
        case .googleMaps: return "globe"
        case .waze: return "location.north.line.fill"
        case .tomtomGo: return "location.fill.viewfinder"
        case .sygic: return "location.fill"
        }
    }

    private var urlScheme: String? {
        switch self {
        case .appleMaps: return nil
        case .googleMaps: return "comgooglemaps://"
        case .waze: return "waze://"
        case .tomtomGo: return "tomtomgo://"
        case .sygic: return "com.sygic.aura://"
        }
    }

    var isInstalled: Bool {
        guard let scheme = urlScheme, let url = URL(string: scheme) else {
            return true
        }
        return UIApplication.shared.canOpenURL(url)
    }

    func navigationURL(to coordinate: CLLocationCoordinate2D) -> URL? {
        let lat = coordinate.latitude
        let lon = coordinate.longitude
        switch self {
        case .appleMaps:
            return URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)&dirflg=d")
        case .googleMaps:
            return URL(string: "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=driving")
        case .waze:
            return URL(string: "waze://?ll=\(lat),\(lon)&navigate=yes")
        case .tomtomGo:
            return URL(string: "tomtomgo://x-callback-url/navigate?destination=\(lat),\(lon)")
        case .sygic:
            return URL(string: "com.sygic.aura://coordinate|\(lon)|\(lat)|drive")
        }
    }

    static var availableOptions: [NavigatorApp] {
        allCases.filter { $0.isInstalled }
    }

    static let storageKey = "preferredNavigatorApp"

    static func openNavigation(preferred: NavigatorApp, to coordinate: CLLocationCoordinate2D) {
        func openAppleMapsFallback() {
            if let url = NavigatorApp.appleMaps.navigationURL(to: coordinate) {
                UIApplication.shared.open(url)
            }
        }
        guard let url = preferred.navigationURL(to: coordinate) else {
            openAppleMapsFallback()
            return
        }
        UIApplication.shared.open(url) { success in
            if !success { openAppleMapsFallback() }
        }
    }
}
