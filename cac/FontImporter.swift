import UIKit

func importAllSystemFonts() {
    let familyNames = UIFont.familyNames
    for familyName in familyNames {
        let fontNames = UIFont.fontNames(forFamilyName: familyName)
        for fontName in fontNames {
            print("Importing font: \(fontName)")
            UIFont.registerFontFromURL(fontName: fontName)
        }
    }
}

extension UIFont {
    static func registerFontFromURL(fontName: String) {
        if let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf") {
            guard let fontDataProvider = CGDataProvider(url: fontURL as CFURL) else { return }
            guard let font = CGFont(fontDataProvider) else { return }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                if let error = error?.takeUnretainedValue() {
                    let errorDescription = CFErrorCopyDescription(error)
                    print("Failed to import font: \(errorDescription ?? "" as CFString)")
                }
            }
        }
    }
}
