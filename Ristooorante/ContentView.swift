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
    @State private var filtraVicinanze = false
    @State private var ristoranteSelezionato: Ristorante? = nil
    @AppStorage("raggioVicinanze") var raggioVicinanze: Double = 5.0
    @State private var mostraImpostazioni = false
    @State private var cercaLocalita = ""
    

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                UserAnnotation()
                ForEach(viewModel.ristoranti) { ristorante in
                    if let lat = ristorante.lat, let lng = ristorante.lng {
                        Annotation(ristorante.nome, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)) {
                                                    PinRistorante()
                                                        .onTapGesture {
                                                            ristoranteSelezionato = ristorante
                                                        }
                                                }
                    }
                }
            }
            .ignoresSafeArea()

            VStack {
                CercaLocalitaView(position: $position, cercaLocalita: $cercaLocalita)

                Spacer()

                HStack {
                    Button {
                                    mostraImpostazioni = true
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                        .foregroundStyle(.white)
                                        .padding(12)
                                        .background(Color("Bordeaux"))
                                        .clipShape(Circle())
                                }

                    Button {
                                    filtraVicinanze.toggle()
                                    if filtraVicinanze, let pos = locationManager.posizione {
                                        position = .region(MKCoordinateRegion(
                                            center: pos.coordinate,
                                            span: MKCoordinateSpan(
                                                latitudeDelta: raggioVicinanze / 55,
                                                longitudeDelta: raggioVicinanze / 55
                                            )
                                        ))
                                    }
                                } label: {
                                    Label("Nelle vicinanze", systemImage: "fork.knife")
                                        .font(.headline)
                                        .foregroundStyle(filtraVicinanze ? Color("Bordeaux") : .white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(filtraVicinanze ? .white : Color("Bordeaux"))
                                        .clipShape(Capsule())
                                }

                    Spacer()

                    // DEBUG: bottone "mostra tutti i ristoranti"
                                        // Per disattivare: commenta il blocco Button qui sotto (da "Button {" fino a ".clipShape(Circle())")
                                        // Per riattivare: togli il commento
                    Button {
                                                                Task {
                                                                    await viewModel.caricaTutti()
                                                                    let coords = viewModel.ristoranti.compactMap { r -> CLLocationCoordinate2D? in
                                                                        guard let lat = r.lat, let lng = r.lng else { return nil }
                                                                        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
                                                                    }
                                                                    guard !coords.isEmpty else { return }
                                                                    let minLat = coords.map(\.latitude).min()!
                                                                    let maxLat = coords.map(\.latitude).max()!
                                                                    let minLng = coords.map(\.longitude).min()!
                                                                    let maxLng = coords.map(\.longitude).max()!
                                                                    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLng + maxLng) / 2)
                                                                    let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.4, longitudeDelta: (maxLng - minLng) * 1.4)
                                                                    position = .region(MKCoordinateRegion(center: center, span: span))
                                                                }
                                                            } label: {
                                            Image(systemName: "map.fill")
                                                .foregroundStyle(.white)
                                                .padding(12)
                                                .background(Color("Bordeaux"))
                                                .clipShape(Circle())
                                        }

                                        Button {
                                            position = .region(MKCoordinateRegion(
                            center: locationManager.posizione?.coordinate ?? CLLocationCoordinate2D(latitude: 44.4056, longitude: 8.9463),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))
                    } label: {
                        Image(systemName: "location.fill")
                                            .foregroundStyle(.white)
                                            .padding(12)
                                            .background(Color("Bordeaux"))
                                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $mostraImpostazioni) {
            ImpostazioniView()
        }
        .sheet(item: $ristoranteSelezionato) { ristorante in
            SchedaRistoranteView(ristorante: ristorante, posizione: locationManager.posizione)
        }
        
        .task {
            await viewModel.caricaRistoranti()
        }
    }

    func cercaLocalita(_ testo: String) {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(testo) { placemark, error in
                if let coordinate = placemark?.first?.location?.coordinate {
                    position = .region(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    ))
                }
            }
        }
}

#Preview {
    ContentView()
}
