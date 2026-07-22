//
//  Background.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct Background: View {
    let imageName: String

    var body: some View {
        RemoteAssetImage(imageName: imageName)
            .scaledToFill()
            .ignoresSafeArea()
    }
}
