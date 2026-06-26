//
//  VicininzeView.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import SwiftUI
import CoreLocation

struct VicininzeView: View {
    let ristoranti: [Ristorante]
    let posizione: CLLocation?
    let raggio: Double
    @Environment(\.dismiss) private var dismiss

    var ristorantiOrdinati: [Ristorante] {
            guard let posizione else { return ristoranti }
            return ristoranti
                .filter {
                    let loc = CLLocation(latitude: $0.lat ?? 0, longitude: $0.lng ?? 0)
                    return posizione.distance(from: loc) <= raggio * 1000
                }
                .sorted {
                    let a = CLLocation(latitude: $0.lat ?? 0, longitude: $0.lng ?? 0)
                    let b = CLLocation(latitude: $1.lat ?? 0, longitude: $1.lng ?? 0)
                    return posizione.distance(from: a) < posizione.distance(from: b)
                }
        }

    func distanza(_ ristorante: Ristorante) -> String {
        guard let posizione,
              let lat = ristorante.lat,
              let lng = ristorante.lng else { return "" }
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
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("Bordeaux"))
                            .frame(width: 44, height: 44)
                        Image(systemName: "fork.knife")
                            .foregroundStyle(.white)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    VStack(alignment: .leading) {
                        Text(ristorante.nome)
                            .font(.headline)
                        Text(ristorante.indirizzo ?? "")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(distanza(ristorante))
                        .font(.caption)
                        .foregroundStyle(Color("Bordeaux"))
                }
            }
            .navigationTitle("Nelle vicinanze")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Chiudi") {
                        dismiss()
                    }
                    .foregroundStyle(Color("Bordeaux"))
                }
            }
        }
    }
}
