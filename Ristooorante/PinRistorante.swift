//
//  PinRistorante.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import SwiftUI

struct PinRistorante: View {
    var haNMenu: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Circle()
                    .fill(Color("Bordeaux"))
                    .frame(width: 36, height: 36)

                Image(systemName: "fork.knife")
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .semibold))
            }

            if haNMenu {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 11, height: 11)
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 1.5)
                    )
                    .offset(x: 2, y: -2)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PinRistorante(haNMenu: false)
        PinRistorante(haNMenu: true)
    }
}
