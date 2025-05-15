//
//  ToastView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays a customizable toast message to the user.

import SwiftUI

struct ToastView: View {
    var style: ToastStyle
    var message: String
    var width: CGFloat = .infinity
    var onCancelTapped: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: style.iconName)
                .foregroundStyle(style.themeColor)
                .padding(.trailing, 20)
                .font(.customTitle2)
            Text(message)
            Spacer()
            Button {
                onCancelTapped()
            } label: {
                Image(systemName: "xmark")
                    .font(.customTitle2)
                    .foregroundStyle(style.themeColor)

            }
        }
        .padding()
        .frame(maxWidth: width)
        .background(
            ZStack {
                Color.white
                style.themeColor.opacity(0.2)
            }
        )
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style.themeColor, lineWidth: 1)
        )
        .padding(.horizontal, 10)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var dismissTask: Task<Void, Never>?
    var onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .overlay(toastOverlay)
            .onChange(of: toast) {
                handleToastChange(onDismiss: onDismiss)
            }
    }

    private var toastOverlay: some View {
        Group {
            if let toast {
                VStack(spacing: 0) {
                    if toast.position != .top {
                        Spacer()
                    }
                    ToastView(
                        style: toast.style,
                        message: toast.message,
                        width: toast.width,
                        onCancelTapped: dismissToast
                    )
                    .padding(.vertical)
                    .transition(.move(edge: .top))
                    if toast.position != .bottom {
                        Spacer()
                    }
                }
                .animation(.spring(), value: toast)
            }
        }
    }

    private func handleToastChange(onDismiss: (() -> Void)?) {
        guard let toast else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(toast.duration))
            if let onDismiss {
                onDismiss()
            }
            dismissToast()
        }
        dismissTask = nil
    }

    private func dismissToast() {
        withAnimation {
            toast = nil
        }
    }
}

extension View {
    func addToast(toast: Binding<Toast?>, onDismiss: (() -> Void)? = nil) -> some View {
        self.modifier(ToastModifier(toast: toast, onDismiss: onDismiss))
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ToastView(style: .success, message: "Your account has been successfully created.", onCancelTapped: {})
    ToastView(style: .error, message: "Your account has been successfully created.", onCancelTapped: {})
    ToastView(style: .info, message: "Your account has been successfully created.", onCancelTapped: {})
    ToastView(style: .warning, message: "Your account has been successfully created.", onCancelTapped: {})
}

#Preview {
    @Previewable @State var toast: Toast?
    VStack {
        Text("Hello")
    }
    .addToast(toast: $toast)
    .onAppear {
        toast = Toast(style: .info, message: "Welcome!")
    }
}
#endif
