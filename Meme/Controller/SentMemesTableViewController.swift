//
//  SentMemesTableViewController.swift
//  MemeMe
//
//  Created by bhuvan on 05/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet weak var createMemeButton: UIBarButtonItem!
    
    // MARK: - Proeprties
    fileprivate var memes: [Meme] {
        return MemeStorage.shared.memes
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hides empty lines
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func createMemedImage(_ sender: Any) {
        let memeEditorVC =  storyboard?.instantiateViewController(identifier: "MemeEditorViewController") as! MemeEditorViewController
        navigationController?.pushViewController(memeEditorVC, animated: true)
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
    }
}

// MARK: - Table view data source
extension SentMemesTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomMemeTableViewCell", for: indexPath) as! CustomMemeTableViewCell
        let meme = memes[indexPath.row]
        cell.memeImageView?.image = meme.memedImage
        let finalText = meme.topText + " ... " + meme.bottomText
        cell.memeTextLabel.text = finalText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MemeStorage.shared.memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Table view delegate
extension SentMemesTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meme = memes[indexPath.row]
        let memeDetailVC = storyboard?.instantiateViewController(identifier: "MemeDetailViewController") as! MemeDetailViewController
        memeDetailVC.memedImage = meme.memedImage
        navigationController?.pushViewController(memeDetailVC, animated: true)
    }
    
}
