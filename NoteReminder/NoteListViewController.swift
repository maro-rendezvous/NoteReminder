//
//  NoteListViewController.swift
//  NoteReminder
//
//  Created by 落合克彦 on 2021/06/26.
//

import UIKit
import RealmSwift
import Material

class NoteListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    let realm = try! Realm()
    var noteArray = try! Realm().objects(Note.self).sorted(byKeyPath: "date", ascending: true)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = #colorLiteral(red: 0.9491872191, green: 1, blue: 0.7424128652, alpha: 0.8470588235)
        prepareFABButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)

        // Cellに値を設定する.
        let note = noteArray[indexPath.row]
        cell.textLabel?.text = note.contents

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: note.date)
        cell.detailTextLabel?.text = dateString

        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.tabBarController?.selectedIndex = 0;
//    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.noteArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    @objc func moveNote() {
        let UINavigationController = tabBarController?.viewControllers?[0];
        tabBarController?.selectedViewController = UINavigationController;
    }
    
}

extension NoteListViewController {
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
        let button = FABButton(image: Icon.cm.add, tintColor: .white)
        button.pulseColor = .white
        button.backgroundColor = Color.red.base
        
        button.addTarget(self, action: #selector(moveNote), for: .touchUpInside)
        
        view.layout(button)
            .width(ButtonLayout.Fab.diameter)
            .height(ButtonLayout.Fab.diameter)
            .center(offsetX: ButtonLayout.Fab.offsetX, offsetY: ButtonLayout.Fab.offsetY)
    }
}
