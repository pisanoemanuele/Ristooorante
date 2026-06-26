//
//  PinRistorante.swift
//  Ristooorante
//
//  Created by Emanuele Pisano on 26/06/2026.
//

import SwiftUI

struct PinRistorante: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color("Bordeaux"))
                .frame(width: 36, height: 36)
            
            Image(systemName: "fork.knife")
                .foregroundStyle(.white)
                .font(.system(size: 14, weight: .semibold))
        }
    }
}

#Preview {
    PinRistorante()
}
