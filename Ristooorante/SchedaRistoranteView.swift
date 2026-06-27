//
//  SchedaRistoranteView.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import SwiftUI
import MapKit

struct SchedaRistoranteView: View {
    let ristorante: Ristorante
    let posizione: CLLocation?
    @Environment(\.dismiss) private var dismiss
    @State private var mostraMenu = false
    @State private var mostraSito = false
    @State private var mostraPrenotazione = false
    @AppStorage(NavigatorApp.storageKey) var navigatorePreferito: String = NavigatorApp.appleMaps.rawValue

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = ristorante.lat, let lng = ristorante.lng else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }

    var distanza: String {
        guard let posizione, let lat = ristorante.lat, let lng = ristorante.lng else { return "" }
        let loc = CLLocation(latitude: lat, longitude: lng)
        let metri = posizione.distance(from: loc)
        if metri < 1000 {
            return String(format: "%.0f m da te", metri)
        } else {
            return String(format: "%.1f km da te", metri / 1000)
        }
    }

    var navigatore: NavigatorApp {
            NavigatorApp(rawValue: navigatorePreferito) ?? .appleMaps
        }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {

                    Text(ristorante.nome)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color("Bordeaux"))

                    if !distanza.isEmpty {
                        Label(distanza, systemImage: "location.fill")
                            .foregroundStyle(Color("Bordeaux"))
                            .font(.subheadline)
                    }

                    if let coordinate {
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))) {
                            Annotation(ristorante.nome, coordinate: coordinate) {
                                PinRistorante()
                            }
                        }
                        .frame(height: 200)
                        .disabled(true)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if let indirizzo = ristorante.indirizzo {
                        Label(indirizzo, systemImage: "mappin")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let coordinate {
                                            Button {
                                                NavigatorApp.openNavigation(preferred: navigatore, to: coordinate)
                                            } label: {
                                                Label("Naviga con \(navigatore.displayName)", systemImage: "arrow.triangle.turn.up.right.circle")
                                                    .foregroundStyle(Color("Bordeaux"))
                                            }
                                        }

                    Divider()

                    if let orari = ristorante.orari {
                        OrariView(orari: orari)
                        Divider()
                    }

                    if let telefono = ristorante.telefono {
                        Button {
                            if let url = URL(string: "tel:\(telefono)") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label(telefono, systemImage: "phone.fill")
                                .foregroundStyle(Color("Bordeaux"))
                        }
                    }

                    if let sito = ristorante.sito_web, let url = URL(string: sito) {
                        Button {
                            mostraSito = true
                        } label: {
                            Label("Sito web", systemImage: "globe")
                                .foregroundStyle(Color("Bordeaux"))
                        }
                        .sheet(isPresented: $mostraSito) {
                            MenuView(url: url, titolo: "Sito web")
                        }
                    }

                    Divider()

                    if let urlMenu = ristorante.url_menu, let url = URL(string: urlMenu) {
                        Button {
                            mostraMenu = true
                        } label: {
                            Label("Apri menu", systemImage: "menucard")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("Bordeaux").opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .sheet(isPresented: $mostraMenu) {
                            MenuView(url: url, titolo: "Menu")
                        }
                    }

                    Button {
                        mostraPrenotazione = true
                    } label: {
                        Label("Prenota", systemImage: "calendar.badge.plus")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("Bordeaux"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $mostraPrenotazione) {
            PrenotazioneView(ristorante: ristorante)
        }
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color("Bordeaux"))
                }
            }
        }
    }
}
