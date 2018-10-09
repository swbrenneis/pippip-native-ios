//
//  Keychain.swift
//  pippip-native-ios
//
//  Created by Steve Brenneis on 10/7/18.
//  Copyright © 2018 seComm. All rights reserved.
//

import UIKit

enum PassphraseProtectionTypes {
    case passcodeSetThisDeviceOnly
    case unlockedThisDeviceOnly
    case unlocked
    case afterFirstUnlockThisDeviceOnly
    case afterFirstUnlock
    case alwaysThisDeviceOnly
    case always
}

class CreateVarsNotSet: Error {
    var localizedDescription: String = "Passphrase create variables not set"
}

class KeychainError: Error {
    var localizedDescription: String
    init(status: OSStatus) {
        localizedDescription = "Keychain error \(status)"
    }
    init(error: String) {
        localizedDescription = error
    }
}

class Keychain: NSObject {

    var service: String
    var authPrompt: String?
    var protection: PassphraseProtectionTypes?
    var createFlag: SecAccessControlCreateFlags?
    var canceled = false
    
    init(service: String) {

        self.service = service
        
        super.init()
    
    }
    
    func accessibility(protection: PassphraseProtectionTypes, createFlag: SecAccessControlCreateFlags) -> Keychain {
        
        self.protection = protection
        self.createFlag = createFlag
        return self

    }

    func authenticationPrompt(_ authPrompt: String) -> Keychain {
        
        self.authPrompt = authPrompt
        return self

    }

    func get(key: String) throws -> String {

        canceled = false
        var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: true]
        if let prompt = authPrompt {
            query[kSecUseOperationPrompt as String] = prompt
        }
        var data: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &data)
        if status == errSecUserCanceled {
            canceled = true
        }
        guard status != errSecItemNotFound else { throw KeychainError(error: "Passphrase not found") }
        guard status == errSecSuccess else { throw KeychainError(status: status) }
        guard let passphraseData = data as? Data else { throw KeychainError(error: "Invalid data returned from keychain") }
        guard let passphrase = String(data: passphraseData, encoding: .utf8)
            else { throw KeychainError(error: "Invalid data returned from keychain") }
        return passphrase

    }
    
    func remove(key: String) throws {
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key]
        let status = SecItemDelete(query as CFDictionary)
        guard status != errSecItemNotFound else { return }
        guard status == errSecSuccess else { throw KeychainError(status: status) }

    }

    func set(passphrase: String, key: String) throws {

        guard let p = self.protection else { throw CreateVarsNotSet() }
        guard let cf = self.createFlag else { throw CreateVarsNotSet() }

        var pString: CFTypeRef
        switch p {
        case .passcodeSetThisDeviceOnly:
            pString = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            break
        case .unlockedThisDeviceOnly:
            pString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            break
        case .unlocked:
            pString = kSecAttrAccessibleWhenUnlocked
            break
        case .afterFirstUnlockThisDeviceOnly:
            pString = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            break
        case .afterFirstUnlock:
            pString = kSecAttrAccessibleAfterFirstUnlock
            break
        case .alwaysThisDeviceOnly:
            pString = kSecAttrAccessibleAlwaysThisDeviceOnly
            break
        case .always:
            pString = kSecAttrAccessibleAlways
            break
        }
        
        let access = SecAccessControlCreateWithFlags(nil, pString, cf, nil)   // Default allocator, ignore errors
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecAttrAccessControl as String: access as Any,
                                    kSecValueData as String: passphrase.data(using: .utf8, allowLossyConversion: false) as Any]
        let result = SecItemAdd(query as CFDictionary, nil)
        guard result != errSecParam else { throw KeychainError(error: "Invalid parameter") }
        guard result != errSecDuplicateItem else { return }     // Hmm.
        guard result == errSecSuccess else { throw KeychainError(status: result) }

    }

}
