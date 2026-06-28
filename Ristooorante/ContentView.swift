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
    @State private var filtraVicinanze = false
    @State private var ristoranteSelezionato: Ristorante? = nil
    @AppStorage("raggioVicinanze") var raggioVicinanze: Double = 5.0
    @State private var mostraImpostazioni = false
    @State private var cercaLocalita = ""
    @State private var fabAperto = false
    @State private var regioneVisibile: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 44.4056, longitude: 8.9463),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var mostraLista = false

    var ristorantiVisibili: [Ristorante] {
        viewModel.ristoranti.filter { ristorante in
            guard let lat = ristorante.lat, let lng = ristorante.lng else { return false }
            let deltaLat = regioneVisibile.span.latitudeDelta / 2
            let deltaLng = regioneVisibile.span.longitudeDelta / 2
            return abs(lat - regioneVisibile.center.latitude) <= deltaLat &&
                   abs(lng - regioneVisibile.center.longitude) <= deltaLng
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $position) {
                UserAnnotation()
                ForEach(viewModel.ristoranti) { ristorante in
                    if let lat = ristorante.lat, let lng = ristorante.lng {
                        Annotation(ristorante.nome, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)) {
                            PinRistorante(haNMenu: ristorante.url_menu != nil)
                                .onTapGesture {
                                    ristoranteSelezionato = ristorante
                                }
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .onMapCameraChange { context in
                regioneVisibile = context.region
            }

            VStack {
                HStack {
                    // Bottone lista ristoranti visibili
                                        Button {
                                            mostraLista = true
                                            fabAperto = false
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: "mappin.circle.fill")
                                                if !ristorantiVisibili.isEmpty {
                                                    Text("\(ristorantiVisibili.count)")
                                                        .fontWeight(.semibold)
                                                }
                                            }
                                            .foregroundStyle(Color("Bordeaux"))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(.white)
                                            .clipShape(Capsule())
                                            .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                                        }
                                        .padding(.leading, 20)
                                        .padding(.top, 16)

                    Spacer()
                }

                CercaLocalitaView(position: $position, cercaLocalita: $cercaLocalita)

                Spacer()
            }

            // FAB
            VStack(spacing: 12) {
                if fabAperto {
                    fabBottone(icona: "gearshape.fill", indice: 3) {
                        mostraImpostazioni = true
                        fabAperto = false
                    }
                    fabBottone(icona: "mappin.and.ellipse", indice: 2) {
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
                        fabAperto = false
                    }
                    fabBottone(icona: "map.fill", indice: 1) {
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
                        fabAperto = false
                    }
                    fabBottone(icona: "location.fill", indice: 0) {
                        position = .region(MKCoordinateRegion(
                            center: locationManager.posizione?.coordinate ?? CLLocationCoordinate2D(latitude: 44.4056, longitude: 8.9463),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))
                        fabAperto = false
                    }
                }

                // Bottone principale FAB
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        fabAperto.toggle()
                    }
                } label: {
                    Image(systemName: fabAperto ? "xmark" : "ellipsis")
                        .foregroundStyle(Color("Bordeaux"))
                        .font(.system(size: 24, weight: .semibold))
                        .frame(width: 52, height: 52)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $mostraImpostazioni) {
            ImpostazioniView()
        }
        .sheet(item: $ristoranteSelezionato) { ristorante in
            SchedaRistoranteView(ristorante: ristorante, posizione: locationManager.posizione)
        }
        .sheet(isPresented: $mostraLista) {
            ListaRistorantiView(ristoranti: ristorantiVisibili, posizione: locationManager.posizione)
                .presentationDetents([.medium, .large])
        }
        .task {
            await viewModel.caricaRistoranti()
        }
    }

    @ViewBuilder
    func fabBottone(icona: String, indice: Int, azione: @escaping () -> Void) -> some View {
        Button(action: azione) {
            Image(systemName: icona)
                .foregroundStyle(Color("Bordeaux"))
                .font(.system(size: 24, weight: .semibold))
                .frame(width: 52, height: 52)
                .background(.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
        }
        .transition(.asymmetric(
            insertion: .scale(scale: 0.5)
                .combined(with: .offset(y: CGFloat(indice + 1) * 20))
                .combined(with: .opacity),
            removal: .scale(scale: 0.5)
                .combined(with: .offset(y: CGFloat(indice + 1) * 20))
                .combined(with: .opacity)
        ))
        .animation(.spring(response: 0.35, dampingFraction: 0.7).delay(Double(indice) * 0.05), value: fabAperto)
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
