//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by Javon Davis on 18/06/2017.
//  Copyright © 2017 Javon Davis. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {
    
    var memes = [Meme]()
    
    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView() // Remove blank rows
    }

    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        
        self.tableView.reloadData()
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentMemeTableViewCell", for: indexPath)

        let meme = memes[indexPath.row]
        cell.textLabel?.text = "\(meme.topText!)...\(meme.bottomText!)"
        cell.imageView?.image = meme.memedImage

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetailFor(memeIndex: indexPath.row)
    }
    
    
    // MARK: - TableView Editing
    
    func confirmDelete(indexPath: IndexPath) {
        let meme = memes[indexPath.row]
        let alertController = UIAlertController(title: "Careful!", message: "Do you really want to delete Meme: \(meme.topText!)...\(meme.bottomText!)?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive, handler: { alert in
            self.tableView.beginUpdates()
            
            // Remove from memes array
            self.memes.remove(at: indexPath.row)
            
            // remove from table UI
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Sync up with AppDelegate
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.memes = self.memes
            
            self.tableView.endUpdates()
            
            
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmDelete(indexPath: indexPath)
        }
    }

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let memeToMove = memes[fromIndexPath.row]
        memes.remove(at: fromIndexPath.row)
        memes.insert(memeToMove, at: to.row)
        
        // sync up with app delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes = memes
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    // MARK: - IBActions

    @IBAction func startReordering(_ sender: Any) {
        self.isEditing = !self.isEditing // Click the button to both start and stop reordering the memes in the table
    }

}
