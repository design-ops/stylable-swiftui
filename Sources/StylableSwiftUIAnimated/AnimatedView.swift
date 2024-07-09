import SwiftUI
import Lottie

struct AnimatedView: UIViewRepresentable {
    let animation: LottieAnimation
    let repeats: Bool

    func makeUIView(context: Context) -> UIView {
        let parent = UIView(frame: .zero)

        let animationView = LottieAnimationView(frame: .zero)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.animation = self.animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = self.repeats ? .loop : .playOnce
        animationView.play()

        parent.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: parent.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])

        return parent
    }

    func updateUIView(_ uiView: UIView, context: Context) { }
}
