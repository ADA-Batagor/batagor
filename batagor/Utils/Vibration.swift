//
//  Vibration.swift
//  batagor
//
//  Created by Tude Maha on 24/10/2025.
//

import UIKit

func vibrateLight() {
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
}

