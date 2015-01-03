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
        var id:ABRecordID = (-1)
        var name:String = ""
        var phone:String = ""
        var email:String = ""
        var checked:Bool = false
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
        //return [["":""]]
        return extractMyContracts(ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray)
    }
    
    func extractMyContracts(contacts:NSArray) -> [Person] {

        // Internal method.
        func getMultiProperty(record:ABRecordRef, property:ABPropertyID, suffix:String) -> [String:String]? {
            var values:ABMultiValueRef? = ABRecordCopyValue(record, property)?.takeRetainedValue()
            if values != nil {
                var propertyDict:Dictionary = [String:String]()
                for i in 0 ..< ABMultiValueGetCount(values) {
                    //var label = ABMultiValueCopyLabelAtIndex(values, i)?.takeRetainedValue() as? NSString
                    var label = ABMultiValueCopyLabelAtIndex(values, i)?.takeRetainedValue() as? String

                    var value = ABMultiValueCopyValueAtIndex(values, i)?.takeRetainedValue() as? NSString
                    switch property {
                    case kABPersonAddressProperty:
                        var TODO = 1
                    case kABPersonSocialProfileProperty:
                        var TODO = 2
                    default:
                        var a = 3
                        //propertyDict[label] = value.takeRetainedValue() as? String ?? ""
                        propertyDict["\(label)\(suffix)"] = value
                    }
                }
                return propertyDict
            } else {
                return nil
            }
        }

        //var retContacts:Array = [[String:String]]()
        var retContacts = [Person]()
        
        for record in contacts {
            var person = Person()
            var fname = ABRecordCopyValue(record, kABPersonFirstNameProperty)?.takeRetainedValue() as? NSString
            var lname = ABRecordCopyValue(record, kABPersonLastNameProperty).takeRetainedValue() as? NSString
            person.name = (lname == nil ? "" : lname as String) + (fname == nil ? "" : fname as String)
            for (key, value) in getMultiProperty(record, kABPersonPhoneProperty, "Phone") ?? ["":""] {
                if (value != "") {
                    person.phone = value
                    break
                }
            }
            for (_, value) in getMultiProperty(record, kABPersonEmailProperty, "Email") ?? ["":""] {
                if (value != "") {
                    person.email = value
                    break
                }
            }
            // refine it
            if person.name.isEmpty {
                //person.name = "-"
            }
            if person.phone.isEmpty {
                person.phone = "~"
            }
            person.id = ABRecordGetRecordID(record)
            retContacts.append(person)
        }
        return retContacts
    }
    
    func getCompositeName(recordID:ABRecordID) -> String {
        var error:Unmanaged<CFErrorRef>?
        var addressBook: ABAddressBookRef = ABAddressBookCreateWithOptions(nil, &error).takeRetainedValue()
        let record: ABRecord! = ABAddressBookGetPersonWithRecordID(addressBook, recordID)?.takeRetainedValue()
        ABPersonGetCompositeNameFormatForRecord(record)
        return ""
    }
    
}
