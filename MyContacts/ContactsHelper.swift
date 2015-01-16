//
//  ContactsHelper.swift
//  MyContacts
//
//  Created by Wei  Wang on 14/12/20.
//  Copyright (c) 2014年 Wei  Wang. All rights reserved.
//

import Foundation
import AddressBook
import AddressBookUI

class ContactsHelper {

    struct Person {
        var id: ABRecordID = (-1)
        var name: String = ""
        var phone: String = ""
        var email: String = ""
        var checked: Bool = false
    }

    init() {
    
    }

    func getMyContacts() -> [Person] {
        var error:Unmanaged<CFErrorRef>?
        var addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        
        let authStatus = ABAddressBookGetAuthorizationStatus()
        
        if authStatus == ABAuthorizationStatus.Denied || authStatus == ABAuthorizationStatus.NotDetermined {
            // Ask for permission
            var sema = dispatch_semaphore_create(0)
            ABAddressBookRequestAccessWithCompletion(addressBook, { (success, error) in
                if success {
                    ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
                    dispatch_semaphore_signal(sema)
                }
            })
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER)
            
        }
        return extractMyContracts(ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray)
    }
    
    func extractMyContracts(contacts: NSArray) -> [Person] {

        //var retContacts:Array = [[String:String]]()
        var retContacts = [Person]()
        
        for record in contacts {
            var person = Person()
            var fname = ABRecordCopyValue(record, kABPersonFirstNameProperty)?.takeRetainedValue() as? NSString
            var lname = ABRecordCopyValue(record, kABPersonLastNameProperty)?.takeRetainedValue() as? NSString

            // TODO: Compose the full name according to locale: call getCompositeName()
            person.name = (lname == nil ? "" : lname as String) + (fname == nil ? "" : fname as String)
            // Get one of the phone attributes
            for (key, value) in getMultiProperty(record, kABPersonPhoneProperty, "Phone") ?? ["":""] {
                if (value != "") {
                    person.phone = value
                    break
                }
            }
            // Get one of the email attributes
            for (_, value) in getMultiProperty(record, kABPersonEmailProperty, "Email") ?? ["":""] {
                if (value != "") {
                    person.email = value
                    break
                }
            }
            // Refine it before returning (for debugging purpose)
            if person.name.isEmpty {
                //person.name = "-"
            }
            if person.phone.isEmpty {
                person.phone = "~"
            }
            person.id = ABRecordGetRecordID(record)
            retContacts.append(person)
        }

        // Sort it
        retContacts.sort { (p1:Person, p2:Person) in
            if p1.name < p2.name {
                return true
            }
            return p1.email < p2.email
        }

        return retContacts
    }
    
    // Internal helper method.
    func getMultiProperty(record:ABRecordRef, _ property:ABPropertyID, _ suffix:String) -> [String:String]? {
        var values:ABMultiValueRef? = ABRecordCopyValue(record, property)?.takeRetainedValue()
        if values != nil {
            var propertyDict:Dictionary = [String:String]()
            for i in 0 ..< ABMultiValueGetCount(values) {
                // Convert to String as the returning value is a NSSting type
                var label = ABMultiValueCopyLabelAtIndex(values, i)?.takeRetainedValue() as? String
                // Convert to NSString (which is an object) as the returning value is AnyObject
                var value = ABMultiValueCopyValueAtIndex(values, i)?.takeRetainedValue() as? NSString
                switch property {
                case kABPersonAddressProperty:
                    var TODO = 1
                case kABPersonSocialProfileProperty:
                    var TODO = 2
                default:
                    var debug = 3
                    //propertyDict[label] = value.takeRetainedValue() as? String ?? ""
                    propertyDict["\(label)\(suffix)"] = value
                }
            }
            return propertyDict
        } else {
            return nil
        }
    }
    
    func getCompositeName(recordID: ABRecordID) -> String {
        var error:Unmanaged<CFErrorRef>?
        var addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        let record: ABRecord! = ABAddressBookGetPersonWithRecordID(addressBook, recordID)?.takeRetainedValue()
        ABPersonGetCompositeNameFormatForRecord(record)
        // TBD
        return ""
    }

    // Show the formatted information string for a specific person
    // e.g. [name] hasFaceTime: Y/N hasPicture: Y/N
    func getDetailedInfo(recordID: ABRecordID) -> String {
        var error:Unmanaged<CFErrorRef>?
        var addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, &error).takeUnretainedValue()
        let record: ABRecord! = ABAddressBookGetPersonWithRecordID(addressBook, recordID)?.takeUnretainedValue()
        let hasPicture: String = ABPersonHasImageData(record) ? "Y" : "N"
        var hasURL: String = "N"
        // Get the URL attributes
        for (_, value) in getMultiProperty(record, kABPersonURLProperty, "URL") ?? ["":""] {
            if (value != "") {
                hasURL = "Y"
                break
            }
        }
        return "hasHomepage:\(hasURL) hasPicture:\(hasPicture)"
    }

    // Delete an entry/record
    func deleteAddressBookEntry(recordID: ABRecordID) -> Bool {
        var error:Unmanaged<CFErrorRef>?
        var addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, &error).takeUnretainedValue()
        let record: ABRecord! = ABAddressBookGetPersonWithRecordID(addressBook, recordID)?.takeUnretainedValue()
        var result = ABAddressBookRemoveRecord(addressBook, record, &error)
        if error != nil {
            println("Failed to delete address book entry: \(recordID)")
            return false
        }
        // Don't forget to save the address book to persistent the state.
        result = ABAddressBookSave(addressBook, &error)
        if error != nil {
            println("Failed to save address book: \(recordID)")
            return false
        }
        return result
    }
}
