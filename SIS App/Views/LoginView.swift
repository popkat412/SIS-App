//
//  LoginView.swift
//  SIS App
//
//  Created by Wang Yunze on 1/12/20.
//

import SwiftUI
import SwiftUIX

struct LoginView: View {
    @EnvironmentObject var userAuthManager: UserAuthManager

    @State private var email: String = ""
    @State private var password: String = ""

    @State private var showingActivityIndicator = false

    @State private var alertItem: AlertItem?

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .center) {
                ScrollView(showsIndicators: false) {
                    VStack {
                        VStack {
                            Text("Login/Sign up")
                                .font(.system(size: 30))

                            Spacer().frame(height: 10)

                            Text("Please use your school email")
                        }

                        EmailView(email: $email)
                        PasswordView(password: $password)

                        Spacer()
                            .frame(height: 50)

                        VStack {
                            LoginButton(showingActivityIndicator: $showingActivityIndicator, email: email, password: password, onError: onError)

                            SignupButton(showingActivityIndicator: $showingActivityIndicator, alertItem: $alertItem, email: email, password: password, onError: onError)

                            ForgetPasswordButton(showingAcitivtyIndicator: $showingActivityIndicator, onError: onError)
                        }
                    }
                    .frame(minHeight: proxy.size.height)
                }
                if showingActivityIndicator {
                    MyActivityIndicator()
                        .frame(width: Constants.activityIndicatorSize, height: Constants.activityIndicatorSize)
                }
            }
            .padding()
            .alert(item: $alertItem, content: alertItemBuilder)
            .onDisappear {
                showingActivityIndicator = false
            }
            .onReceive(NotificationCenter.default.publisher(for: .AuthStateDidChange), perform: { _ in
                print("🔥 auth state did change")
            })
        }
    }

    private func onError(_ error: Error) {
        print("🔥 error: \(error)")
        showingActivityIndicator = false
        alertItem = MyErrorInfo(error).toAlertItem()
    }

    private static func validateInputs(email: String, password: String) -> Error? {
        guard !email.isEmpty else { return "Email cannot be empty" }
        guard email.hasSuffix(Constants.riEmailSuffix) else { return "Please use your RI email" }

        guard password.count >= 8 else { return "Password must be more than 8 characters" }
        guard password.matches(regex: "[A-Z]") else { return "Password must have at least 1 upper case letter" }
        guard password.matches(regex: "[a-z]") else { return "Password must have at least 1 lower case letter" }
        guard password.matches(regex: "[0-9]") else { return "Password must have at least 1 number" }
        guard password.matches(regex: "[!@#$%^&*()]") else { return "Password must have at least one symbol: !@#$%^&*()" }

        return nil
    }

    private struct EmailView: View {
        @Binding var email: String

        var body: some View {
            VStack {
                HStack {
                    Text("Email: ")
                    Spacer()
                }

                TextField("Email", text: $email)
                    .textFieldStyle(MyTextFieldStyle())
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
        }
    }

    private struct PasswordView: View {
        @Binding var password: String

        var body: some View {
            VStack {
                HStack {
                    Text("Password: ")
                    Spacer()
                }

                SecureField("Password", text: $password)
                    .autocapitalization(.none)
                    .textFieldStyle(MyTextFieldStyle())
            }
        }
    }

    private struct LoginButton: View {
        @EnvironmentObject var userAuthManager: UserAuthManager
        @Binding var showingActivityIndicator: Bool
        let email, password: String
        let onError: OnErrorCallback

        var body: some View {
            Button(action: {
                print("🔥 sign in button pressed")

                userAuthManager.signIn(email: email, password: password, onError: onError)
                showingActivityIndicator = true
            }) {
                Text("Login")
            }
            .buttonStyle(GradientButtonStyle(gradient: Constants.greenGradient))
        }
    }

    private struct SignupButton: View {
        @EnvironmentObject var userAuthManager: UserAuthManager
        @Binding var showingActivityIndicator: Bool
        @Binding var alertItem: AlertItem?

        let email, password: String
        let onError: OnErrorCallback

        var body: some View {
            Button(action: {
                print("🔥 sign up button pressed")

                if let error = validateInputs(email: email, password: password) {
                    onError(error)
                    return
                }

                showTextFieldAlert(
                    TextAlert(
                        title: "Confirm password",
                        placeholder: "Password",
                        isPassword: true
                    ) { retypedPassword in
                        guard let retypedPassword = retypedPassword else { return }
                        if retypedPassword == password {
                            showingActivityIndicator = true
                            userAuthManager.signUp(
                                email: email,
                                password: password,
                                onSentEmailVerfication: {
                                    print("🔥 sent email verification!")
                                    showingActivityIndicator = false
                                    alertItem = AlertItem(
                                        title: "Please verify your account",
                                        message: "A message has been sent to \(userAuthManager.userEmail). Click on the link to verify your account"
                                    )
                                },
                                onError: onError
                            )
                        } else {
                            alertItem = MyErrorInfo("The two passwords given do not match, try again.").toAlertItem()
                        }
                    }
                )
            }) {
                Text("Sign up")
            }
            .buttonStyle(GradientButtonStyle(gradient: Constants.blueGradient))
        }
    }

    private struct ForgetPasswordButton: View {
        @EnvironmentObject var userAuthManager: UserAuthManager
        @Binding var showingAcitivtyIndicator: Bool
        @State private var resetPasswordEmail: String? = nil

        let onError: OnErrorCallback

        var body: some View {
            Button {
                showTextFieldAlert(
                    TextAlert(
                        title: "Enter the email address of your account",
                        message: "An email will be sent with a link to reset your password",
                        placeholder: "Email"
                    ) { email in
                        guard let email = email else { return }

                        showingAcitivtyIndicator = true
                        userAuthManager.resetPassword(email: email) { error in
                            if let error = error {
                                onError(error)
                                return
                            }

                            DispatchQueue.main.async {
                                print("🔥 reset password email sent")
                                showingAcitivtyIndicator = false
                                resetPasswordEmail = email
                            }
                        }
                    })
            } label: {
                Text("Forgot password?")
            }
            .alert(item: $resetPasswordEmail) { email in
                Alert(
                    title: Text("An email has been sent to \(email)"),
                    message: Text("Click on the link in the email to reset your password"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserAuthManager())
    }
}
