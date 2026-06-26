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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(ristoranti) { ristorante in
                VStack(alignment: .leading) {
                    Text(ristorante.nome)
                        .font(.headline)
                    Text(ristorante.indirizzo ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
