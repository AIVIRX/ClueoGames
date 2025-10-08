//
//  SettingsView.swift
//  CluoGames
//
//  Created by Assistant on 10/01/25.
//

import SwiftUI
import StoreKit
import RevenueCatUI
#if os(iOS)
import MessageUI
#endif

#if os(iOS)
struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var result: Result<MFMailComposeResult, Error>?

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentationMode: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentationMode: Binding<PresentationMode>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentationMode = presentationMode
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                $presentationMode.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["support@aivirx.com"])
        vc.setSubject("DockUI")
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {}
}
#endif

struct SettingsView: View {
    @StateObject private var purchases = PurchasesService.shared
    @State private var showPaywall = false
#if os(iOS)
    @State private var result: Result<MFMailComposeResult, Error>? = nil
#endif
    @State private var isShowingMailView = false
    @AppStorage("appearanceMode") private var appearanceMode: String = "auto"

    var body: some View {
        NavigationStack {
            List {
                // Subscription status
                Section("Subscription") {
                    HStack {
                        Image(systemName: purchases.hasPremium ? "checkmark.seal.fill" : "xmark.seal.fill")
                            .foregroundColor(purchases.hasPremium ? .green : .red)
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(purchases.hasPremium ? "Clueo Games+" : "Clueo Games+")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        Button(purchases.hasPremium ? "Manage" : "Subscribe") {
                            showPaywall = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Appearance Section
                Section("Appearance") {
                    Picker("Color Scheme", selection: $appearanceMode) {
                        Text("Auto").tag("auto")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.menu)
                }
                
                // Other Apps Section
                Section("More Apps") {
                    Button {
                        if let url = URL(string: "https://apps.apple.com/us/app/dock-ui-snippets-for-swiftui/id6496860953") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image("dockui")
                                .resizable()
                                .frame(width: 30, height:30)
                                .cornerRadius(5)
                            Text("Dock UI: Snippets for SwiftUI")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button {
                        if let url = URL(string: "https://apps.apple.com/us/app/dock-ui-snippets-for-swiftui/id6496860953") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image("stockscalc")
                                .resizable()
                                .frame(width: 30, height:30)
                                .cornerRadius(5)
                            Text("Stock Profit Calculator 2025")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Support Section
                Section("Support") {
                    Button(action: {
                        isShowingMailView.toggle()
                    }) {
                        HStack {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 24)
                                Text("Send Feedback")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
#if os(iOS)
                    .disabled(!MFMailComposeViewController.canSendMail())
#endif
                }
                
                // Legal Section
                Section("Legal") {
                    Button {
                        if let url = URL(string: "https://www.aivirx.com/clueogames/privacy-policy") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.purple)
                                .frame(width: 24)
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Button {
                        if let url = URL(string: "https://www.aivirx.com/clueogames/terms-of-service") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Version Section
                Section {
                    HStack {
                        Spacer()
                        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "5.0.0")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            CustomPaywallView()
        }
        .onAppear {
            // Refresh subscription status when settings view appears
            Task {
                await purchases.loadCustomerInfo()
            }
        }
    }
}
