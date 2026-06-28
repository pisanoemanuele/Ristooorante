//
//  ListaRistorantiView.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import SwiftUI
import CoreLocation

struct ListaRistorantiView: View {
    let ristoranti: [Ristorante]
    let posizione: CLLocation?
    @Environment(\.dismiss) private var dismiss
    @State private var ristoranteSelezionato: Ristorante? = nil

    var ristorantiOrdinati: [Ristorante] {
        guard let posizione else { return ristoranti }
        return ristoranti.sorted {
            guard let lat1 = $0.lat, let lng1 = $0.lng,
                  let lat2 = $1.lat, let lng2 = $1.lng else { return false }
            let loc1 = CLLocation(latitude: lat1, longitude: lng1)
            let loc2 = CLLocation(latitude: lat2, longitude: lng2)
            return posizione.distance(from: loc1) < posizione.distance(from: loc2)
        }
    }

    func distanzaStringa(_ ristorante: Ristorante) -> String {
        guard let posizione, let lat = ristorante.lat, let lng = ristorante.lng else { return "" }
        let loc = CLLocation(latitude: lat, longitude: lng)
        let metri = posizione.distance(from: loc)
        if metri < 1000 {
            return String(format: "%.0f m", metri)
        } else {
            return String(format: "%.1f km", metri / 1000)
        }
    }

    var body: some View {
        NavigationStack {
            List(ristorantiOrdinati) { ristorante in
                Button {
                    ristoranteSelezionato = ristorante
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(.white)
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 36, height: 36)
                            .background(ristorante.url_menu != nil ? Color.orange : Color("Bordeaux"))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(ristorante.nome)
                                .font(.headline)
                                .foregroundStyle(Color("TestoAdattivo"))
                            if let indirizzo = ristorante.indirizzo {
                                                            Text(indirizzo)
                                                                .font(.caption)
                                                                .foregroundStyle(Color("Bordeaux"))
                                                        }
                        }

                        Spacer()

                        let dist = distanzaStringa(ristorante)
                        if !dist.isEmpty {
                            Text(dist)
                                .font(.caption)
                                .foregroundStyle(Color("Bordeaux"))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Ristoranti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Chiudi") { dismiss() }
                        .foregroundStyle(Color("Bordeaux"))
                }
            }
            .sheet(item: $ristoranteSelezionato) { ristorante in
                SchedaRistoranteView(ristorante: ristorante, posizione: posizione)
            }
        }
    }
}
