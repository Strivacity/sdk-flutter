import Flutter
import UIKit
import AuthenticationServices

public class StrivacityFlutterIosPlugin: NSObject, FlutterPlugin {
  private var pendingResult: FlutterResult?
  private var authenticationAnchor: ASPresentationAnchor?

  private func base64UrlDecode(_ base64Url: String) -> Data? {
    var base64 = base64Url
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")

    let paddingLength = (4 - (base64.count % 4)) % 4
    base64 += String(repeating: "=", count: paddingLength)

    return Data(base64Encoded: base64)
  }

  private func base64UrlEncode(_ data: Data) -> String {
    return data.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "strivacity_flutter/passkey", binaryMessenger: registrar.messenger())
    let instance = StrivacityFlutterIosPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "authenticate":
      guard let assertionOptions = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Assertion options are required", details: nil))
        return
      }
      if #available(iOS 15.0, *) {
        handleAuthenticate(assertionOptions: assertionOptions, result: result)
      } else {
        result(FlutterError(code: "UNSUPPORTED", message: "Passkey authentication requires iOS 15.0 or newer", details: nil))
      }

    case "enroll":
      guard let enrollOptions = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Enroll options are required", details: nil))
        return
      }
      if #available(iOS 15.0, *) {
        handleEnroll(enrollOptions: enrollOptions, result: result)
      } else {
        result(FlutterError(code: "UNSUPPORTED", message: "Passkey enrollment requires iOS 15.0 or newer", details: nil))
      }

    case "isAvailable":
      if #available(iOS 15.0, *) {
        result(true)
      } else {
        result(false)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  @available(iOS 15.0, *)
  private func handleAuthenticate(assertionOptions: [String: Any], result: @escaping FlutterResult) {
    guard let challenge = assertionOptions["challenge"] as? String else {
      result(FlutterError(code: "INVALID_CHALLENGE", message: "Challenge is missing", details: nil))
      return
    }

    guard let challengeData = base64UrlDecode(challenge) else {
      result(FlutterError(code: "INVALID_CHALLENGE", message: "Challenge is not valid base64url", details: nil))
      return
    }

    let rpId = assertionOptions["rpId"] as? String ?? ""
    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
    let platformKeyRequest = platformProvider.createCredentialAssertionRequest(challenge: challengeData)

    if let allowCredentials = assertionOptions["allowCredentials"] as? [[String: Any]] {
      var descriptors: [ASAuthorizationPlatformPublicKeyCredentialDescriptor] = []
      for credential in allowCredentials {
        if let idString = credential["id"] as? String,
           let idData = Data(base64Encoded: idString) {
          let descriptor = ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: idData)
          descriptors.append(descriptor)
        }
      }
      if !descriptors.isEmpty {
        platformKeyRequest.allowedCredentials = descriptors
      }
    }

    if let userVerification = assertionOptions["userVerification"] as? String {
      switch userVerification {
      case "required":
        platformKeyRequest.userVerificationPreference = .required
      case "preferred":
        platformKeyRequest.userVerificationPreference = .preferred
      case "discouraged":
        platformKeyRequest.userVerificationPreference = .discouraged
      default:
        platformKeyRequest.userVerificationPreference = .preferred
      }
    }

    let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
    authController.delegate = self
    authController.presentationContextProvider = self

    pendingResult = result
    authController.performRequests()
  }

  @available(iOS 15.0, *)
  private func handleEnroll(enrollOptions: [String: Any], result: @escaping FlutterResult) {
    guard let challenge = enrollOptions["challenge"] as? String else {
      result(FlutterError(code: "INVALID_CHALLENGE", message: "Challenge is missing", details: nil))
      return
    }

    guard let challengeData = base64UrlDecode(challenge) else {
      result(FlutterError(code: "INVALID_CHALLENGE", message: "Challenge is not valid base64url", details: nil))
      return
    }

    guard let rp = enrollOptions["rp"] as? [String: Any],
          let rpId = rp["id"] as? String,
          let rpName = rp["name"] as? String else {
      result(FlutterError(code: "INVALID_RP", message: "Invalid relying party", details: nil))
      return
    }

    guard let user = enrollOptions["user"] as? [String: Any],
          let userIdString = user["id"] as? String,
          let userName = user["name"] as? String,
          let userDisplayName = user["displayName"] as? String else {
      result(FlutterError(code: "INVALID_USER", message: "Invalid user information", details: nil))
      return
    }

    guard let userId = base64UrlDecode(userIdString) else {
      result(FlutterError(code: "INVALID_USER_ID", message: "User ID is not valid base64url", details: nil))
      return
    }

    let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
    let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(
      challenge: challengeData,
      name: userName,
      userID: userId
    )

    if let userVerification = enrollOptions["authenticatorSelection"] as? [String: Any],
       let uvPref = userVerification["userVerification"] as? String {
      switch uvPref {
      case "required":
        platformKeyRequest.userVerificationPreference = .required
      case "preferred":
        platformKeyRequest.userVerificationPreference = .preferred
      case "discouraged":
        platformKeyRequest.userVerificationPreference = .discouraged
      default:
        platformKeyRequest.userVerificationPreference = .preferred
      }
    }

    let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
    authController.delegate = self
    authController.presentationContextProvider = self

    pendingResult = result
    authController.performRequests()
  }
}

@available(iOS 15.0, *)
extension StrivacityFlutterIosPlugin: ASAuthorizationControllerDelegate {
  public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let result = pendingResult else { return }

    if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
      let response: [String: Any] = [
        "id": base64UrlEncode(credential.credentialID),
        "rawId": base64UrlEncode(credential.credentialID),
        "type": "public-key",
        "response": [
          "clientDataJSON": base64UrlEncode(credential.rawClientDataJSON),
          "authenticatorData": base64UrlEncode(credential.rawAuthenticatorData),
          "signature": base64UrlEncode(credential.signature),
          "userHandle": base64UrlEncode(credential.userID)
        ]
      ]
      result(response)
    } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
      let response: [String: Any] = [
        "id": base64UrlEncode(credential.credentialID),
        "rawId": base64UrlEncode(credential.credentialID),
        "type": "public-key",
        "response": [
          "clientDataJSON": base64UrlEncode(credential.rawClientDataJSON),
          "attestationObject": credential.rawAttestationObject.map { base64UrlEncode($0) } ?? ""
        ]
      ]
      result(response)
    } else {
      result(FlutterError(code: "UNKNOWN_CREDENTIAL", message: "Unknown credential type", details: nil))
    }

    pendingResult = nil
  }

  public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    guard let result = pendingResult else { return }

    let authError = error as NSError
    let errorCode: String
    let errorMessage: String

    switch authError.code {
    case ASAuthorizationError.canceled.rawValue:
      errorCode = "CANCELED"
      errorMessage = "User canceled the operation"
    case ASAuthorizationError.failed.rawValue:
      errorCode = "FAILED"
      errorMessage = "Authentication failed"
    case ASAuthorizationError.invalidResponse.rawValue:
      errorCode = "INVALID_RESPONSE"
      errorMessage = "Invalid response"
    case ASAuthorizationError.notHandled.rawValue:
      errorCode = "NOT_HANDLED"
      errorMessage = "Request not handled"
    case ASAuthorizationError.unknown.rawValue:
      errorCode = "UNKNOWN"
      errorMessage = "Unknown error"
    default:
      errorCode = "ERROR"
      errorMessage = error.localizedDescription
    }

    result(FlutterError(code: errorCode, message: errorMessage, details: authError.userInfo))
    pendingResult = nil
  }
}

@available(iOS 15.0, *)
extension StrivacityFlutterIosPlugin: ASAuthorizationControllerPresentationContextProviding {
  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
  }
}
