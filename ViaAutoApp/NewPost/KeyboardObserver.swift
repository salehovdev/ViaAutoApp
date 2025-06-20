//
//  KeyboardObserver.swift
//  ViaAutoApp
//
//  Created by Fuad Salehov on 25.06.25.
//

import Foundation
import SwiftUI
import Combine

struct KeyboardObserver: ViewModifier {
    @Binding var isKeyboardVisible: Bool

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                isKeyboardVisible = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                isKeyboardVisible = false
            }
    }
}

extension View {
    func observeKeyboard(_ isKeyboardVisible: Binding<Bool>) -> some View {
        self.modifier(KeyboardObserver(isKeyboardVisible: isKeyboardVisible))
    }
    
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
}
