//
//  ViewController.swift
//  MyContacts
//
//  Created by Wei  Wang on 14/12/20.
//  Copyright (c) 2014年 Wei  Wang. All rights reserved.
//

import UIKit
import AddressBook

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let LOG_TAG: String = "ViewController"
    let logger: LogHelper = LogHelper()
    var contacts: [ContactsHelper.Person] = []
    // For debugging purpose.
    enum CLICK_ACTION {
        case SHOW_DETAILS //Click to show detailed info in a popup dialog.
        case MUTIPLE_SELECT //Click to mark the cell item (so that we can perform multi-select).
        case SINGLE_DELETE
    }
    let clickAction = CLICK_ACTION.SHOW_DETAILS

    // Left nav button tags
    let selectTag = 100
    let doneTag = 200
    let editTag = 300

    // Views and controls
    var leftButtonItem: UIBarButtonItem?
    var rightButtonItem: UIBarButtonItem?
    var tableView: UITableView?

    // Selected items
    var selectedItems = Dictionary<Int, ABRecordID>()

    let contactsHelper = ContactsHelper()

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    // Define an identifier for cell re-using. In Android we also try to reuse list items however I don't remember we have a counterpart for this...
    let reusedCellIdentifier: String = "myContactsCell"

    // UIViewController method.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.contacts = contactsHelper.getMyContacts()
        for i in 0...10 {
            println("[\(i)] [\(self.contacts[i].id)] [Name=\(self.contacts[i].name)]")
        }

        // UINavigationBar
        buildNavigationButtons()

        // This option is also selected in the storyboard. Usually it is better to configure a table view in a xib/storyboard, but we're redundantly configuring this in code to demonstrate how to do that.
        self.tableView?.allowsMultipleSelection = true
    }

    func buildNavigationButtons() {
        // Left button
        var barButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "leftButtonItemClicked")
        barButtonItem.tag = editTag
        //self.navigationItem.leftBarButtonItem = barButtonItem
        self.leftButtonItem = barButtonItem

        // Right button
        self.rightButtonItem = UIBarButtonItem(title: "Delete", style: UIBarButtonItemStyle.Plain, target: self, action: "rightButtonItemClicked")
        self.rightButtonItem?.enabled = false

        // Combine them togethter
        var navigationItem = navigationBar.popNavigationItemAnimated(false)
        navigationItem?.title = "Contacts"
        navigationItem?.leftBarButtonItem = self.leftButtonItem
        navigationItem?.rightBarButtonItem = self.rightButtonItem
        navigationBar.pushNavigationItem(navigationItem!, animated: true)
    }

    func leftButtonItemClicked() {
        var button = self.leftButtonItem
        if button?.tag == editTag {
            button?.title = "Done"
            button?.tag = doneTag
            //self.rightButtonItem?.enabled = true
            self.tableView?.setEditing(true, animated: false)
        } else if button?.tag == doneTag {
            button?.title = "Edit"
            button?.tag = editTag
            self.tableView?.setEditing(false, animated: false)
            self.rightButtonItem?.enabled = false
            // reset data source.
            selectedItems.removeAll(keepCapacity: false)
        }
    }

    func rightButtonItemClicked() {
        var selectedRows = self.tableView?.indexPathsForSelectedRows() as [NSIndexPath]
        doDelete(selectedRows, false)
        self.rightButtonItem?.enabled = false
    }

    // UIViewController method.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // UITableViewDataSource protocol.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Is there a better to retain the UITableView handle? (We need it in [leftBarButtonItemClicked])
        self.tableView = tableView
        return contacts.count;
    }

    // UITableViewDataSource protocol.
    // System asking for a specific item. Similar to Adapter.getItem() in Android.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Note: We should try to reuse the exsiting cells, instead of creating new cell each time.
        // There is another (better?) method to use after iOS6.
        //let cell = tableView.dequeueReusableCellWithIdentifier("myContactsCell", forIndexPath: indexPath) as UITableViewCell
        
        var cell = tableView.dequeueReusableCellWithIdentifier(reusedCellIdentifier) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reusedCellIdentifier)
        }
        var person = self.contacts[indexPath.row]
        cell?.textLabel!.text = person.name == "" ? person.email : person.name
        cell?.detailTextLabel!.text = person.phone
        return cell!
    }

    // Note that the following declaration will generate compile error:
    // ... does not conform to protocol 'UITableViewDataSource'.
    // func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {

    // UITableViewDataSource protocol.
    // Returning true to enbale editing mode.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }

    // UITableViewDataSource protocol.
    // This is the default behavior when user wipes the cell item to reveal the (one) button - "delete" be default.
    // If editActionsForRowAtIndexPath() is implemented, this will not be called. The handler callbacks in
    // editActionsForRowAtIndexPath() will be invoked instead.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            doDelete([indexPath], false)
        } else if editingStyle == UITableViewCellEditingStyle.Insert {
            // We don't handle Inserting.
        }
    }

    // UITableViewDelegate protocol.
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return (UITableViewCellEditingStyle.Delete)
    }

    // UITableViewDelegate protocol.
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        var moreAction: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "More", handler: {
            (tableViewRowAction:UITableViewRowAction!, index:NSIndexPath!) in
                println("More action clicked")
        })
        moreAction.backgroundColor = UIColor.grayColor()

        var deleteAction: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: {
            (tableViewRowAction:UITableViewRowAction!, index:NSIndexPath!) in
                println("Delete action clicked")
                self.doDelete([index], false)
        })
        deleteAction.backgroundColor = UIColor.redColor()

        return [moreAction, deleteAction]
    }

    // UITableViewDelegate protocol.
    // Show detailed information when a person item is clicked.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var button = self.leftButtonItem
        if button?.tag == editTag {
            showDetails(tableView, indexPath)
        } else if button?.tag == doneTag {
            // item selected
            var person = self.contacts[indexPath.row]
            selectedItems[indexPath.row] = person.id
            self.rightButtonItem?.enabled = true
        }
    }

    // UITableViewDelegate protocol.
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var person = self.contacts[indexPath.row]
        selectedItems.removeValueForKey(indexPath.row)
        self.rightButtonItem?.enabled = selectedItems.count > 0
    }

    // Delete a specific entry from address book. When @debug is true, we only remove it in the memory.
    func doDelete(indexPaths: [NSIndexPath], _ debug: Bool) {
        var i = 0
        for item in indexPaths {
            // Note that we have a changing index after item removed each time.
            let newIndex = item.row - i
            let person = self.contacts[newIndex]
            if !debug && !self.contactsHelper.deleteAddressBookEntry(person.id) {
                continue
            }

            println("Deleted: [\(item.row)] [\(person.id)] [Name=\(person.name)]");

            // Delete it from data source
            self.contacts.removeAtIndex(newIndex)
            i++
        }

        // Delete the cell from TableView (In Android this could be done automatically when Adapter is changed.)
        // Note that the first param is an NSArray object.
        self.tableView?.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
    }

    func showDetails(tableView: UITableView, _ indexPath: NSIndexPath) {
        var person = self.contacts[indexPath.row]
        // TODO: Show more information here as you wish.
        var detailedInfo = "[\(person.name)] " + contactsHelper.getDetailedInfo(person.id)
        var alert = UIAlertController(title: "Detailed Information", message: detailedInfo, preferredStyle: UIAlertControllerStyle.Alert)
        let option = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction!) in ()})
        alert.addAction(option)
        self.presentViewController(alert, animated: true, completion: {})
    }

    func doCheck(tableView: UITableView, _ indexPath: NSIndexPath) {
    }
}

