//
//  GameHeader.swift
//  Montam
//
//  Created by Tufan Cakir on 20.07.26.
//

import SwiftUI

struct GameHeader: View {

    var body: some View {
        PlayerStatusBar()
            .padding(.horizontal, 12)
            .padding(.top, 44)
            .padding(.bottom, 8)
            .background(AppScreenBackground())
    }

}
