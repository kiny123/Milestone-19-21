//
//  DetailViewController.swift
//  Milestone 19-21
//
//  Created by nikita on 08.03.2023.
//

import UIKit


protocol DetailDelegate {
    func editor(_ editor: DetailViewController, didUpdate notes: [Note])
}

class DetailViewController: UIViewController {
    var notes: [Note]!
    var noteIndex: Int!
    var delegate: DetailDelegate?
    var currentNote: String?
    var selectedNote: String?
    var isOriginal: String?
    
    var buttonShare: UIBarButtonItem!
    var buttonDone: UIBarButtonItem!
    var buttonDelete: UIBarButtonItem!
    
    

    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard isParametersSet() else {
                     navigationController?.popViewController(animated: true)
                     return
                 }
        
        buttonDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
        buttonShare = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        navigationItem.rightBarButtonItems = [buttonShare]
        
        buttonDelete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let compose = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newTapped))
            toolbarItems = [buttonDelete, space, compose]
            navigationController?.isToolbarHidden = false

            textView.text = notes[noteIndex].text
        
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
             super.viewWillDisappear(animated)

             guard noteIndex != nil else { return }

             saveNote()
         }

    
    @objc func deleteTapped() {

             let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
             ac.popoverPresentationController?.barButtonItem = buttonDelete
             ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                 self?.deleteNote()
             }))
             ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
             present(ac, animated: true)
         }
    
    func deleteNote() {
             notes.remove(at: noteIndex)
             updateNotification(notes: notes)

             DispatchQueue.global().async { [weak self] in
                 if let notes = self?.notes {
                     SaveAndLoadUtils.save(notes: notes)
                 }

                 DispatchQueue.main.async {
                     self?.updateGuiAfterDeletion()
                 }
             }
         }
    
    func updateNotification(notes: [Note]) {
             if let delegate = delegate {
                 delegate.editor(self, didUpdate: notes)
             }
         }
    
    func updateGuiAfterDeletion() {

             if noteIndex < notes.count {
                 textView.text = notes[noteIndex].text
                 return
             }

             if notes.count > 0 {
                 noteIndex = notes.count - 1
                 textView.text = notes[noteIndex].text
                 return
             }

             noteIndex = nil
             navigationController?.popViewController(animated: true)
         }
    
    func setParameters(notes: [Note], noteIndex: Int) {
             self.notes = notes
             self.noteIndex = noteIndex
         }
   
    func isParametersSet() -> Bool {
             return notes != nil && noteIndex != nil
         }
    
    @objc func doneTapped() {
            hideKeyboard()
        }
    
    func hideKeyboard() {
             textView.endEditing(true)
         }
    
    @objc func adjustForKeyboard(notification: Notification) {
             guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

             let keyboardScreenEndFrame = keyboardValue.cgRectValue
             let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

             if notification.name == UIResponder.keyboardWillHideNotification {
                 textView.contentInset = .zero
                navigationItem.rightBarButtonItems = [buttonShare]
                 saveNote()
             }
             else {
                 textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
                 navigationItem.rightBarButtonItems = [buttonDone, buttonShare]
             }

             textView.scrollIndicatorInsets = textView.contentInset

             let selectedRange = textView.selectedRange
             textView.scrollRangeToVisible(selectedRange)

         }
    
    @objc func shareTapped() {
             hideKeyboard()
             saveNote()

             let vc = UIActivityViewController(activityItems: [notes[noteIndex].text], applicationActivities: [])
             vc.popoverPresentationController?.barButtonItem = buttonShare
             present(vc, animated: true)
         }
    
    func saveNote(isNew: Bool = false) {
            if textView.text != isOriginal || isNew {
                notes[noteIndex].text = textView.text

                DispatchQueue.global().async { [weak self] in
                    if let notes = self?.notes {
                        SaveAndLoadUtils.save(notes: notes)
                    }
                }
            }
        }
    
    @objc func newTapped() {
          saveNote()

          notes.append(Note(text: ""))
          updateNotification(notes: notes)

          noteIndex = notes.count - 1
          textView.text = ""
          isOriginal = ""


          saveNote(isNew: true)
      }
    

}
