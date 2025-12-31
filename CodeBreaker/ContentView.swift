//
//  ContentView.swift
//  CodeBreaker
//
//  Created by 李嘉明 on 2025/12/26.
//

import SwiftUI
import Combine
import CoreMotion

final class MotionManager: ObservableObject {
    private let manager = CMMotionManager()

    @Published var tiltX: CGFloat = 0
    @Published var tiltY: CGFloat = 0

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1 / 60

        manager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion else { return }
            self.tiltX = CGFloat(motion.attitude.roll)
            self.tiltY = CGFloat(motion.attitude.pitch)
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}

struct ContentView: View {
    @StateObject private var motion = MotionManager()
    var body: some View {
        ZStack {
            // Base dark-to-light depth gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Primary ambient light (large soft glow)
            RadialGradient(
                colors: [
                    Color.white.opacity(0.18),
                    Color.clear
                ],
                center: UnitPoint(
                    x: 0.2 + motion.tiltX * 0.15,
                    y: 0.2 + motion.tiltY * 0.15
                ),
                startRadius: 50,
                endRadius: 500
            )
            .ignoresSafeArea()

            // Secondary ambient light (cool tone)
            RadialGradient(
                colors: [
                    Color.blue.opacity(0.25),
                    Color.clear
                ],
                center: UnitPoint(
                    x: 0.8 + motion.tiltX * 0.1,
                    y: 0.8 + motion.tiltY * 0.1
                ),
                startRadius: 100,
                endRadius: 600
            )
            .ignoresSafeArea()

            VStack {
                pegs(colors: [.red, .green, .green, .yellow])
                pegs(colors: [.red, .blue, .green, .red])
                pegs(colors: [.red, .yellow, .green, .blue])
            }
            .padding()
        }
        .onAppear {
            motion.start()
        }
        .onDisappear {
            motion.stop()
        }
    }
    
    func pegs(colors: Array<Color>) -> some View {
        HStack {
            MatchMarkers(matches: [.exact, .inexact, .nomatch, .exact]).padding(10)
            ForEach(colors.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 0)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(colors[index].opacity(0.00001))
                    .glassEffect(
                        .regular
                            .tint(colors[index].opacity(0.9))
                        .interactive(),
                        in: .rect(cornerRadius: 20))
            }
        }
    }
}

#Preview {
    ContentView()
}
