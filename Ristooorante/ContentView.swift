//
//  ContentView.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = RistoranteViewModel()
    @StateObject private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 44.4056, longitude: 8.9463), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))))
    @State private var mostraVicinanze = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                UserAnnotation()
                ForEach(viewModel.ristoranti) { ristorante in
                    if let lat = ristorante.lat, let lng = ristorante.lng {
                        Annotation(ristorante.nome, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)) {
                            PinRistorante()
                        }
                    }
                }
            }
            .ignoresSafeArea()

            Button {
                mostraVicinanze = true
            } label: {
                Label("Nelle vicinanze", systemImage: "fork.knife")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $mostraVicinanze) {
            VicininzeView(ristoranti: viewModel.ristoranti)
        }
        .task {
            await viewModel.caricaRistoranti()
        }
    }
}

#Preview {
    ContentView()
}
