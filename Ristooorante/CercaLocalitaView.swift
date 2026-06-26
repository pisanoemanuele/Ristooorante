//
//  CercaLocalitaView.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import SwiftUI
import MapKit
import Combine

struct CercaLocalitaView: View {
    @Binding var position: MapCameraPosition
    @Binding var cercaLocalita: String
    @FocusState private var cercaAttiva: Bool
    @State private var suggerimenti: [MKLocalSearchCompletion] = []
    @StateObject private var completer = LocalSearchCompleter()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Cerca città", text: $cercaLocalita)
                    .foregroundStyle(Color("Bordeaux"))
                    .submitLabel(.search)
                    .focused($cercaAttiva)
                    .onChange(of: cercaLocalita) { _, nuovo in
                        completer.cerca(nuovo)
                    }
                    .onSubmit {
                        cercaCitta(cercaLocalita)
                    }
                if !cercaLocalita.isEmpty {
                    Button {
                        cercaLocalita = ""
                        suggerimenti = []
                        cercaAttiva = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 60)
                            .padding(.top, 60)

            if !completer.risultati.isEmpty && cercaAttiva {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(completer.risultati, id: \.self) { risultato in
                        Button {
                            cercaLocalita = risultato.title
                            cercaCitta(risultato.title + " " + risultato.subtitle)
                            suggerimenti = []
                            cercaAttiva = false
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(risultato.title)
                                    .foregroundStyle(Color("Bordeaux"))
                                    .font(.subheadline.bold())
                                if !risultato.subtitle.isEmpty {
                                    Text(risultato.subtitle)
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        Divider()
                    }
                }
                .background(.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
    }

    func cercaCitta(_ testo: String) {
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

class LocalSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    private let completer = MKLocalSearchCompleter()
    @Published var risultati: [MKLocalSearchCompletion] = []

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    func cerca(_ testo: String) {
        completer.queryFragment = testo
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        risultati = Array(completer.results.prefix(5))
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        risultati = []
    }
}
