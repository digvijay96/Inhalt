//
//  FetchedResultsTableViewController.swift
//  Inhalt
//
//  Created by digvijay.s on 15/09/17.
//  Copyright © 2017 digvijay.s. All rights reserved.
//

import UIKit
import CoreData

class FetchedResultsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        print("Updates started")
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.endUpdates()
    }

}
