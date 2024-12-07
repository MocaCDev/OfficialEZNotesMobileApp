//
//  CommonViews.swift
//  EZNotes-2
//
//  Created by Aidan White on 12/6/24.
//
import SwiftUI

/* MARK: This file holds common views used predominantly throughout the project. It enables a more feasible experience with writing code. */

struct EZNotesColoredDivider: View {
    var body: some View {
        VStack { }.frame(maxWidth: .infinity, maxHeight: 0.5).background(MeshGradient(width: 3, height: 3, points: [
            .init(0, 0), .init(0.3, 0), .init(1, 0),
            .init(0.0, 0.3), .init(0.3, 0.5), .init(1, 0.5),
            .init(0, 1), .init(0.5, 1), .init(1, 1)
        ], colors: [
            .indigo, .indigo, Color.EZNotesBlue,
            Color.EZNotesBlue, Color.EZNotesBlue, .purple,
            .indigo, Color.EZNotesGreen, Color.EZNotesBlue
        ]))
    }
}
