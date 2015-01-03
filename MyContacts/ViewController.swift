//
//  ViewController.swift
//  MyContacts
//
//  Created by Wei  Wang on 14/12/20.
//  Copyright (c) 2014年 Wei  Wang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var contacts: [ContactsHelper.Person] = []
    enum CLICK_ACTION {
        case SHOW_DETAILS
        case DO_CHECK
    }
    let clickAction = CLICK_ACTION.SHOW_DETAILS
    let LOG_TAG: String = "ViewController"

    var logger: LogHelper = LogHelper()
    var contactsHelper = ContactsHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        contacts = contactsHelper.getMyContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        var person = self.contacts[indexPath.row]
        cell.textLabel?.text = person.name == "" ? person.email : person.name
        cell.detailTextLabel?.text = person.phone
        return cell
    }

    // Show detailed information when a person item is clicked.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch clickAction {
        case CLICK_ACTION.SHOW_DETAILS:
            showDetails(tableView, indexPath)
        case CLICK_ACTION.DO_CHECK:
            doCheck(tableView, indexPath)
        default:
            println("Unknown action to clicking")
        }
    }

    func showDetails(tableView: UITableView, _ indexPath: NSIndexPath) {
        var person = self.contacts[indexPath.row]
        var detailedInfo = "[\(person.name)] " + contactsHelper.getDetailedInfo(person.id)
        var alert = UIAlertController(title: "Detailed Information", message: detailedInfo, preferredStyle: UIAlertControllerStyle.Alert)
        let option = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction!) in ()})
        alert.addAction(option)
        self.presentViewController(alert, animated: true, completion: {})
    }

    func doCheck(tableView: UITableView, _ indexPath: NSIndexPath) {
        var person = self.contacts[indexPath.row]
        //self.contacts[indexPath.row].checked = !self.contacts[indexPath.row].checked
        person.checked = !person.checked
        logger.log(LOG_TAG, person.name + " \(person.checked)")
    }
}

