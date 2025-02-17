//
//  TermsAndConditionsAgreementView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct LegalAgreementTextWithWebLink: View {
    @ObservedObject var vm: LandingPageViewModel
    
    var authenticationProvider: AuthenticationProvider?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("By continuing, you agree to our ")
            HStack(spacing: 0) {
                termsAndConditionsText
                Text(" and ")
            }
            HStack(spacing: 0) {
                privatePolicyText
                Text(".")
            }
        }
        .sheet(isPresented: $vm.showWebView) {
            if let url = vm.webViewURL {
                WebView(
                    url: url,
                    onFinishedLoading: nil,
                    onError: vm.handleWebViewError
                )
            }
        }
        .webViewAlert(
            isPresented: $vm.showWebViewAlert,
            title: vm.alertTitle,
            message: vm.alertMessage,
            dismissAction: vm.dismissWebView
        )
    }
    
    private var termsAndConditionsText: some View {
        TappableLink(
            text: "Terms and Conditions",
            action: vm.loadTermsAndConditionsWebView
        )
    }
    
    private var privatePolicyText: some View {
        TappableLink(
            text: "Private Policy",
            action: vm.loadPrivacyPolicyWebView
        )
    }
}

#if DEBUG
#Preview {
    LegalAgreementTextWithWebLink(vm: LandingPageViewModel(authenticationManager: AuthenticationManager(), webViewService: WebViewService()))
}
#endif
