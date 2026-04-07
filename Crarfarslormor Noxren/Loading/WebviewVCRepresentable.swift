//
//  WebviewVCRepresentable.swift
//  Crarfarslormor Noxren
//
//  Created by Boranko Ydan on 06.04.2026.
//

import SwiftUI
import UIKit

struct WebviewVCRepresentable: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> WebviewVC {
        WebviewVC(url: url)
    }

    func updateUIViewController(_ uiViewController: WebviewVC, context: Context) {}
}
