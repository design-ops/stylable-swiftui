import Foundation
import SwiftUI
import Lottie

public struct StylableAnimatedView: View {
    public static let defaultSeparator = "_"
    
    private let identifier: StylistIdentifier
    private let factory: (StylistIdentifier, Theme?) -> AnimatedView?
    
    @EnvironmentObject private var stylist: Stylist
    @Environment(\.currentStylableGroup) var currentStylableGroup
    
    public init(_ identifier: StylistIdentifier,
                separator: String = defaultSeparator,
                bundle: Bundle = .main,
                repeats: Bool = true) {
        self.identifier = identifier
        self.factory = { identifier, theme in AnimatedView(identifier,
                                                           separator: separator,
                                                           bundle: bundle,
                                                           theme: theme,
                                                           repeats: repeats)
        }
    }
    
    public var body: some View {
        self.factory(StylistIdentifier(token: self.identifier.token,
                                       path: self.identifier.path.within(self.currentStylableGroup)),
                     self.stylist.currentTheme)
    }
}

extension AnimatedView {
    init?(_ identifier: StylistIdentifier,
          separator: String = StylableAnimatedView.defaultSeparator,
          bundle: Bundle = .main,
          theme: Theme? = nil,
          repeats: Bool) {
        let animation = identifier.animatedFile(separator: separator,
                                                theme: theme,
                                                bundle: bundle)
        
        guard let animation = animation else {
            Logger.default.log("No animation found for \(identifier)", level: .error)
            return nil
        }
        
        self = AnimatedView(animation: animation, repeats: repeats)
    }
}

extension StylistIdentifier {
    func animatedFile(separator: String = StylableAnimatedView.defaultSeparator,
                      theme: Theme? = nil,
                      bundle: Bundle = .main) -> Lottie.Animation? {
        self.potentialImageNames(separator: separator, theme: theme)
            .lazy
            .compactMap { Lottie.Animation.named($0, bundle: bundle) }
            .first
    }
}
