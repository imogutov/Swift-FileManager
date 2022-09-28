import Foundation
import KeychainAccess

struct PasswordManager {
    
    private let key = ""
    private let keychain = Keychain()
    
    var isSet: Bool {
        if let _ = keychain[key] {
            return true
        }
        return false
    }
    
    func save(_ password: String, completion: (Bool, Error?) -> Void) {
        do {
            try keychain.set(password, key: key)
            completion(true, nil)
        }
        catch let error {
            completion(false, error)
        }
    }
    
    func isValid(_ password: String) -> Bool {
        guard let token = keychain[key] else {
            return false
        }
        return password == token
    }
    
    func remove() {
        do {
            try keychain.remove(key)
        } catch let error {
            print("error: \(error)")
        }
    }
}
