//
//  OrariView.swift
//  Ristooorante
//

import SwiftUI

struct OrariView: View {
    let orari: [String: OrariGiorno]
    @State private var espanso = false

    let ordinamento = ["Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato", "Domenica"]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    espanso.toggle()
                }
            } label: {
                HStack {
                    Label("Orari", systemImage: "clock")
                        .foregroundStyle(Color("Bordeaux"))
                    Spacer()
                    Image(systemName: espanso ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)

            if espanso {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(ordinamento, id: \.self) { giorno in
                        if let info = orari[giorno] {
                            HStack(alignment: .top) {
                                Text(giorno)
                                                                    .frame(width: 90, alignment: .leading)
                                                                    .font(.subheadline.bold())
                                                                    .foregroundStyle(Color("Bordeaux"))
                                if info.chiuso == true {
                                    Text("Chiuso")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                } else {
                                    VStack(alignment: .leading, spacing: 2) {
                                                            if let pranzo = info.pranzo {
                                                                HStack {
                                                                    Text("Pranzo")
                                                                        .frame(width: 50, alignment: .leading)
                                                                        .foregroundStyle(.secondary)
                                                                    Text("\(pranzo.apertura)–\(pranzo.chiusura)")
                                                                        .foregroundStyle(.primary)
                                                                }
                                                                .font(.subheadline)
                                                            }
                                                            if let cena = info.cena {
                                                                HStack {
                                                                    Text("Cena")
                                                                        .frame(width: 50, alignment: .leading)
                                                                        .foregroundStyle(.secondary)
                                                                    Text("\(cena.apertura)–\(cena.chiusura)")
                                                                        .foregroundStyle(.primary)
                                                                }
                                                                .font(.subheadline)
                                                            }
                                                        }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
    }
}
