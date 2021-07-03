//
//  HomeViewController.swift
//  NoteReminder
//
//  Created by 落合克彦 on 2021/06/26.
//

import UIKit
import RealmSwift
import Material
import SVProgressHUD

class HomeViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var analysisTableView: UITableView!
    
    var analysisArray: [String] = []
    let realm = try! Realm()
    var note: Note!
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.delegate = self
        analysisTableView.delegate = self
        analysisTableView.dataSource = self
        analysisTableView.isHidden = true
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        analysisFlatButton()
        registFlatButton()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return analysisArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnalysisCell", for: indexPath)
        
        cell.textLabel?.text = analysisArray[indexPath.row]
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "Task",sender: nil)
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let taskViewController:TaskViewController = segue.destination as! TaskViewController

        let task = Task()
        let allTasks = realm.objects(Task.self)
        if allTasks.count != 0 {
            task.id = allTasks.max(ofProperty: "id")! + 1
        }
        task.contents = analysisArray[index]
        taskViewController.task = task
    }
    
    @objc func analysis(_ sender: Any) {
        analysisArray = []
        let text:String = self.noteTextView.text
//        let linguisticTagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "ja"), options: 0)
//        linguisticTagger.string = text
//        linguisticTagger.enumerateTags(in: NSRange(location: 0, length: text.count),
//                                       scheme: NSLinguisticTagScheme.tokenType,
//                                       options: [.omitWhitespace]) {
//            tag, tokenRange, sentenceRange, stop in
//            let subString = (text as NSString).substring(with: tokenRange)
//            print("\(subString) : \(String(describing: tag))")
//            analysisArray.append(subString)
//        }
        
        analysisArray = text.lines
        analysisTableView.reloadData()
        analysisTableView.isHidden = false
    }
        
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noteTextView.text = ""
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
    
    @objc func doneButtonDoneAction() {
        if noteTextView.text == "" {
            SVProgressHUD.showError(withStatus: "内容を入力して下さい")
            SVProgressHUD.dismiss(withDelay: 1)
            return
        }
//        SVProgressHUD.show()
        noteTextView.resignFirstResponder()
        //        noteTextView.becomeFirstResponder()
        note = Note()
        let allTasks = realm.objects(Note.self)
        if allTasks.count != 0 {
            note.id = allTasks.max(ofProperty: "id")! + 1
        }
        try! realm.write {
            self.note.title = "title"
            self.note.contents = noteTextView.text
            self.note.date = Date()
            self.realm.add(self.note, update: .modified)
            //            print(Realm.Configuration.defaultConfiguration.fileURL!)
        }
//        SVProgressHUD.dismiss()
        SVProgressHUD.showInfo(withStatus: "登録しました。")
        SVProgressHUD.dismiss(withDelay: 1)
        noteTextView.text = ""
    }
    
    @objc func doneButtonClearAction() {
        noteTextView.text = ""
        noteTextView.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.keyboardToolbar(textView: textView)
        return true
    }
 
}

extension HomeViewController {
    struct ButtonLayout {
//        struct Raised {
//            static let width: CGFloat = 100
//            static let height: CGFloat = 44
//            static let offsetX: CGFloat = 100
//            static let offsetY: CGFloat = -200
//        }
        struct Flat {
            static let width: CGFloat = 100
            static let height: CGFloat = 44
            static let offsetX: CGFloat = 100
            static let offsetY: CGFloat = -250
        }
        struct Fab {
            static let diameter: CGFloat = 48
            static let width: CGFloat = 100
            static let height: CGFloat = 44
            static let offsetX: CGFloat = 100
            static let offsetY: CGFloat = -200
        }
    }
    
//    fileprivate func prepareRaisedButton() {
//        let button = RaisedButton(title: "分析", titleColor: .white)
//        button.pulseColor = .white
//        button.backgroundColor = Color.blue.base
//
//        button.addTarget(self, action: #selector(analysis), for: .touchUpInside)
//
//        view.layout(button)
//            .width(ButtonLayout.Raised.width)
//            .height(ButtonLayout.Raised.height)
//            .center(offsetX: ButtonLayout.Raised.offsetX, offsetY: ButtonLayout.Raised.offsetY)
//    }
    
    fileprivate func registFlatButton() {
  
        let button = FABButton(image: Icon.cm.check, tintColor: .white)
        button.pulseColor = .white
        button.backgroundColor = Color.red.base
        button.addTarget(self, action: #selector(doneButtonDoneAction), for: .touchUpInside)
        
        view.layout(button)
//            .width(ButtonLayout.Flat.width)
//            .height(ButtonLayout.Flat.height)
            .width(ButtonLayout.Fab.diameter)
            .height(ButtonLayout.Fab.diameter)
            .center(offsetX: ButtonLayout.Flat.offsetX, offsetY: ButtonLayout.Flat.offsetY)
    }
    
    fileprivate func analysisFlatButton() {
        let button = FlatButton(title: "分析")
        button.fontSize = 24
        button.pulseColor = .cyan
        button.titleColor = .white
        button.backgroundColor = Color.blue.base
        button.addTarget(self, action: #selector(analysis), for: .touchUpInside)
        
        view.layout(button)
            .width(ButtonLayout.Flat.width)
            .height(ButtonLayout.Flat.height)
            .center(offsetX: ButtonLayout.Flat.offsetX, offsetY: ButtonLayout.Flat.offsetY + 100)
    }
}

extension String {

    var lines: [String] {
        var lines = [String]()
        self.enumerateLines { (line, stop) -> () in
            lines.append(line)
        }
        return lines
    }

}
