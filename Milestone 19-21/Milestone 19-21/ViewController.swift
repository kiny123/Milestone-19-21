//
//  ViewController.swift
//  Milestone 19-21
//
//  Created by nikita on 08.03.2023.
//

import UIKit

final class ViewController: UITableViewController, DetailDelegate {
    func editor(_ editor: DetailViewController, didUpdate notes: [Note]) {
        self.notes = notes
    }
    
    var notes = [Note]()
    var filNotes = [Note]()
    
    var spacerButton: UIBarButtonItem!
    var notesCountButton: UIBarButtonItem!
    var newNoteButton: UIBarButtonItem!
    var deleteAllButton: UIBarButtonItem!
    var buttonDelete: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Your notes"
        
        newNoteButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNote))
        
        toolbarItems = [newNoteButton]
        navigationController?.isToolbarHidden = false

        tableView.allowsMultipleSelectionDuringEditing = true
        
        reloadDataFromSaveAndLoadUtils()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            sortNotes()
            updateData()
        }
    
    func reloadDataFromSaveAndLoadUtils() {
             DispatchQueue.global().async { [weak self] in
                 self?.notes = SaveAndLoadUtils.load()
                 self?.sortNotes()

                 DispatchQueue.main.async {
                     self?.updateData()
                 }
             }
         }
   
    
    func updateData() {
             tableView.reloadData()
         }
    
    func sortNotes() {
        notes.sort(by: { $0.text!.count >= $1.text!.count })
         }

    
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if let cell = cell as? NoteCell {
                    let note = notes[indexPath.row]
            let split = note.text!.split(separator: "\n", maxSplits: 2, omittingEmptySubsequences: true)
            
            cell.titleLabel.text = note.text
                }
                return cell
    }
    
   
    func toDetailViewController(noteIndex: Int) {
             if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
                 vc.setParameters(notes: notes, noteIndex: noteIndex)
                 vc.delegate = self
                 navigationController?.pushViewController(vc, animated: true)
             }
         }
    
    @objc func createNote() {
            notes.append(Note(text: ""))
            DispatchQueue.global().async { [weak self] in
                if let notes = self?.notes {
                    SaveAndLoadUtils.save(notes: notes)

                    DispatchQueue.main.async {
                        self?.toDetailViewController(noteIndex: notes.count - 1)
                    }
                }
            }
        }
   
    func getTitleText(split: [Substring]) -> String {
        

             return "No Header"
         }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                notes.remove(at: indexPath.row)

                DispatchQueue.global().async { [weak self] in
                    if let notes = self?.notes {
                        SaveAndLoadUtils.save(notes: notes)
                    }

                    DispatchQueue.main.async {
                        self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if tableView.isEditing {
                toolbarItems = [spacerButton, buttonDelete]
            }
            else {
                toDetailViewController(noteIndex: indexPath.row)
            }
        }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
             if tableView.isEditing {
                 if tableView.indexPathsForSelectedRows == nil || tableView.indexPathsForSelectedRows!.isEmpty {
                     toolbarItems = [spacerButton]
                 }
             }
         }
    
    func deleteNotes(rows: [IndexPath]) {
            for path in rows {
                notes.remove(at: path.row)
            }

            DispatchQueue.global().async { [weak self] in
                if let notes = self?.notes {
                    SaveAndLoadUtils.save(notes: notes)
                }

                DispatchQueue.main.async {
                    self?.updateData()
                }
            }
        }
}

