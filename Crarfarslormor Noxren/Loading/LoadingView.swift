//
//  LoadingView.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 06.04.2026.
//

import SwiftUI

/// Shown at cold start while device parameters are collected and the remote gate request runs.
struct LoadingView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.25)
                    .tint(Color.appAccent)
                Text("Loading…")
                    .font(.headline)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .appScreenBackground()
    }
}

