//
//  KeychainPasswordItem.swift
//  BiometricAuth
//
//  Created by Raul Samuel Quispe Mamani on 11/17/20.
//

import UIKit

struct KeychainConfiguration {
  static let accessGroup: String? = nil
}
struct KeychainPasswordItem {
    // MARK: Types
    
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    // MARK: Properties
    
    let service: String
    
    private(set) var account: String
    
    let accessGroup: String?
    
    // MARK: Intialization
    
    init(service: String, account: String, accessGroup: String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
    
    // MARK: Keychain access
    
    func readPassword() throws -> String  {
        /*
            Build a query to find the item that matches the service, account and
            access group.
        */
        
//        let query = KeychainPasswordItem.readKeychainQueryBiometric(withService: service, account: account, accessGroup: accessGroup)
//        var queryResult:AnyObject?
//
//        let status: OSStatus = withUnsafeMutablePointer(to: &queryResult) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
//
//        if status == 0 {
//            var dictQuery = NSDictionary()
//            dictQuery = queryResult! as! NSDictionary
//            let passwordData = dictQuery[kSecValueData as String] as! Data
//            let password = String(data: passwordData, encoding: .utf8)
//            return password!
//        }else{
//            throw KeychainError.unexpectedPasswordData
//        }
                       

        var query = KeychainPasswordItem.readKeychainQueryBiometric(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        // Parse the password string from the query result.
        guard let existingItem = queryResult as? NSDictionary,
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }

        return password
    }
    
    func savePassword(_ password: String) throws {
        // Encode the password into an Data object.
        let encodedPassword = password.data(using: String.Encoding.utf8)!
        
        do {
            // Check for an existing item in the keychain.
            try _ = readPassword()

            // Update the existing item with the new password.
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
        catch KeychainError.noPassword {
            /*
                No password was found in the keychain. Create a dictionary to save
                as a new keychain item.
            */
            var newItem = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    mutating func renameAccount(_ newAccountName: String) throws {
        // Try to update an existing item with the new account name.
        var attributesToUpdate = [String : AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?
        
        let query = KeychainPasswordItem.keychainQuery(withService: service, account: self.account, accessGroup: accessGroup)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
        
        self.account = newAccountName
    }
    
    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = KeychainPasswordItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    static func passwordItems(forService service: String, accessGroup: String? = nil) throws -> [KeychainPasswordItem] {
        // Build a query for all items that match the service and access group.
        var query = KeychainPasswordItem.keychainQuery(withService: service, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse
        
        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }

        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String : AnyObject]] else { throw KeychainError.unexpectedItemData }
        
        // Create a `KeychainPasswordItem` for each dictionary in the query result.
        var passwordItems = [KeychainPasswordItem]()
        for result in resultData {
            guard let account  = result[kSecAttrAccount as String] as? String else { throw KeychainError.unexpectedItemData }
            
            let passwordItem = KeychainPasswordItem(service: service, account: account, accessGroup: accessGroup)
            passwordItems.append(passwordItem)
        }
        
        return passwordItems
    }

    // MARK: Convenience
    
    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String : Any] {
        
        var query: [String: Any] = [String : Any]()

        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrLabel as String] = service as CFString
        query[kSecAttrAccount as String] = account! as CFString
        query[kSecValueData as String] = "test_strong_password".data(using: .utf8)! as CFData
        query[kSecAttrService as String] = service as Any?

              if let account = account {
                  query[kSecAttrAccount as String] = account as Any?
              }

              if let accessGroup = accessGroup {
                  query[kSecAttrAccessGroup as String] = accessGroup as Any?
              }
        query[kSecAttrAccessControl as String] = KeychainPasswordItem.getBioSecAccessControl()
          
        return query
    }
    static func getBioSecAccessControl() -> SecAccessControl {
        var access: SecAccessControl?
        var error: Unmanaged<CFError>?
        
        if #available(iOS 11.3, *) {
            access = SecAccessControlCreateWithFlags(nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .biometryCurrentSet,
                &error)
        } else if #available(iOS 9.0, *)  {
            access = SecAccessControlCreateWithFlags(nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .touchIDCurrentSet,
                &error)
        }
        precondition(access != nil, "SecAccessControlCreateWithFlags failed")
        return access!
    }
    // MARK: Read Query
    private static func readKeychainQueryBiometric(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String : Any] {

        let accessControl = KeychainPasswordItem.getBioSecAccessControl()

        var query: [String: Any] = [:]

//        query[kSecClass as String] = kSecClassGenericPassword
//        query[kSecAttrLabel as String] = service as CFString
//        query[kSecAttrAccount as String] =  account! as CFString
//        query[kSecValueData as String] = "test_strong_password".data(using: .utf8)! as CFData
//        query[kSecAttrAccessControl as String] = accessControl
        
         query = [kSecClass as String: kSecClassGenericPassword,
              kSecAttrLabel as String: service,
              kSecAttrAccessControl as String: accessControl,
              kSecAttrAccount as String: account!,
              kSecUseOperationPrompt as String: "Grant access to Pacifico",
              kSecReturnData as String: kCFBooleanTrue,
              kSecMatchLimit as String: kSecMatchLimitOne,
              kSecReturnAttributes as String: kCFBooleanTrue,
              kSecValueData as String: "test_strong_password".data(using: .utf8)! as CFData
              ]
        return query
    }
}
