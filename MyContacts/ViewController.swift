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
    
    // Define an identifier for cell re-using. In Android we also try to reuse list items however I don't remember we have a counterpart for this...
    let reusedCellIdentifier = "myContactsCell"

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

    // System asking for a specific item. Similar to Adapter.getItem() in Android.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Note: We should try to reuse the exsiting cells, instead of creating new cell each time.
        var cell = tableView.dequeueReusableCellWithIdentifier(reusedCellIdentifier, forIndexPath: indexPath) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reusedCellIdentifier)
        }
        var person = self.contacts[indexPath.row]
        cell!.textLabel?.text = person.name == "" ? person.email : person.name
        cell!.detailTextLabel?.text = person.phone
        return cell!
    }

    // Returning true to enbale editing mode.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            // Delete it from data source
            contacts.removeAtIndex(indexPath.row)
            // Delete the cell from TableView (In Android this could be done automatically when Adapter is changed.)
            // Note that the first param is an NSArray object.
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        } else if editingStyle == UITableViewCellEditingStyle.Insert {
            // We don't handle Inserting.
        }
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

