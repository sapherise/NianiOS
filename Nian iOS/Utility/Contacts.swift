//
//  AddressBookController.swift
//  GetContacts
//
//  Created by Varun S on 11/29/14.
//  Copyright (c) 2014 Zydus. All rights reserved.
//

import Foundation
import AddressBook
import AddressBookUI
import CoreTelephony

class ContactsHelper {
    
    var adbk : ABAddressBook!
    
    init() {}
    
    func createAddressBook() -> Bool {
        if self.adbk != nil {
            return true
        }
        var err : Unmanaged<CFError>? = nil
        let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if adbk == nil {
            self.adbk = nil
            return false
        }
        self.adbk = adbk
        return true
    }
    
    func determineStatus() -> Bool {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .authorized:
            return self.createAddressBook()
        case .notDetermined:
            var ok = false
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted:Bool, err:CFError!) in
                DispatchQueue.main.async {
                    if granted {
                        ok = self.createAddressBook()
                    }
                }
            }
            if ok == true {
                return true
            }
            self.adbk = nil
            return false
        case .restricted:
            self.adbk = nil
            return false
        case .denied:
            self.adbk = nil
            return false
        }
    }
    
    func getContactNames() -> [String] {
        var list = [String]()
        let people = ABAddressBookCopyArrayOfAllPeople(adbk).takeRetainedValue() as NSArray
        for person in people {
            let phone: ABMultiValue = ABRecordCopyValue(person as ABRecord!, kABPersonPhoneProperty)?.takeRetainedValue() as ABMultiValue? ?? "" as ABMultiValue
            var phoneNumber: NSString? = ABMultiValueCopyValueAtIndex(phone, 0)?.takeRetainedValue() as? NSString
            if phoneNumber != nil {
                phoneNumber = phoneNumber?.replacingOccurrences(of: "-", with: "") as NSString?
                phoneNumber = phoneNumber?.replacingOccurrences(of: " ", with: "") as NSString?
                phoneNumber = phoneNumber?.replacingOccurrences(of: "*", with: "") as NSString?
                phoneNumber = phoneNumber?.replacingOccurrences(of: "+86", with: "") as NSString?
                phoneNumber = phoneNumber?.replacingOccurrences(of: "+", with: "") as NSString?
                list.append(phoneNumber! as String)
            }
        }
        return list
    }
}
