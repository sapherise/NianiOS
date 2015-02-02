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
        case .Authorized:
            return self.createAddressBook()
        case .NotDetermined:
            var ok = false
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted:Bool, err:CFError!) in
                dispatch_async(dispatch_get_main_queue()) {
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
        case .Restricted:
            self.adbk = nil
            return false
        case .Denied:
            self.adbk = nil
            return false
        }
    }
    
    func getContactNames() -> [String] {
        var list = [String]()
        let people = ABAddressBookCopyArrayOfAllPeople(adbk).takeRetainedValue() as NSArray
        for person in people {
            let phone: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty)?.takeRetainedValue() as ABMultiValueRef? ?? ""
            let firstName: String = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as String? ?? ""
            let lastName: String = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as String? ?? ""
            var phoneNumber: NSString? = ABMultiValueCopyValueAtIndex(phone, 0)?.takeRetainedValue() as? NSString
            if phoneNumber != nil {
                phoneNumber = phoneNumber?.stringByReplacingOccurrencesOfString("-", withString: "")
                phoneNumber = phoneNumber?.stringByReplacingOccurrencesOfString(" ", withString: "")
                phoneNumber = phoneNumber?.stringByReplacingOccurrencesOfString("*", withString: "")
                phoneNumber = phoneNumber?.stringByReplacingOccurrencesOfString("+86", withString: "")
                phoneNumber = phoneNumber?.stringByReplacingOccurrencesOfString("+", withString: "")
                list.append(phoneNumber!)
            }
        }
        return list
    }
}