//
//  TaskViewController.swift
//  NoteReminder
//
//  Created by 落合克彦 on 2021/06/28.
//

import UIKit
import RealmSwift
import Material
import SVProgressHUD

class TaskViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var taskTextView: UITextView!
    @IBOutlet weak var taskDatePicker: UIDatePicker!
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet var container: UIView!
    
    let realm = try! Realm()
    var task: Task!
//    var completionCheck = false
    
    @IBAction func check(_ sender: CheckBox) {
//        if sender.isChecked {
//            completionCheck = true
//        } else {
//            completionCheck = false
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTextView.delegate = self
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        prepareFABButton()
        
        if task != nil {
            taskTextView.text = task.contents
            taskDatePicker.date = task.noticeDatetime
            if task.done {
                checkBox.isChecked = true
            }
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardToolbar(textView: UITextView) {
        
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        toolbar.barStyle = UIBarStyle.default
        toolbar.bounds.size.height = 28
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let clear: UIBarButtonItem = UIBarButtonItem(title: "クリア", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.doneButtonClearAction))
        clear.tintColor = UIColor.red
        
        var items = [UIBarButtonItem]()
        
        items.append(clear)
        items.append(flexSpace)
        //        items.append(done)
        toolbar.items = items
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonClearAction() {
        taskTextView.text = ""
        taskTextView.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.keyboardToolbar(textView: textView)
        return true
    }
    
    @objc func regist(_ sender: Any) {
        if taskTextView.text == "" {
            SVProgressHUD.showError(withStatus: "内容を入力して下さい")
            SVProgressHUD.dismiss(withDelay: 1)
            return
        }
        try! realm.write {
            self.task.contents = self.taskTextView.text
            self.task.done = checkBox.isChecked
            self.task.noticeDatetime = self.taskDatePicker.date
            self.realm.add(self.task, update: .modified)
//            print(Realm.Configuration.defaultConfiguration.fileURL!)
        }
        SVProgressHUD.showInfo(withStatus: "登録しました。")
        SVProgressHUD.dismiss(withDelay: 1)
        taskTextView.text = ""
    }
}

extension TaskViewController {
    struct ButtonLayout {
        struct Fab {
            static let diameter: CGFloat = 48
            static let width: CGFloat = 100
            static let height: CGFloat = 44
            static let offsetX: CGFloat = 100
            static let offsetY: CGFloat = -200
        }
    }
    
    fileprivate func prepareFABButton() {
        let button = FABButton(image: Icon.cm.check, tintColor: .white)
        button.pulseColor = .white
        button.backgroundColor = Color.red.base
        
        button.addTarget(self, action: #selector(regist), for: .touchUpInside)
        
        view.layout(button)
            .width(ButtonLayout.Fab.diameter)
            .height(ButtonLayout.Fab.diameter)
            .center(offsetX: ButtonLayout.Fab.offsetX, offsetY: ButtonLayout.Fab.offsetY)
    }
    
}
