//
//  TaskListViewController.swift
//  NoteReminder
//
//  Created by 落合克彦 on 2021/06/28.
//

import UIKit
import RealmSwift
import Material

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var taskTableView: UITableView!
    
    let realm = try! Realm()
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "noticeDatetime", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        taskTableView.delegate = self
        taskTableView.dataSource = self
        
        taskTableView.backgroundColor = #colorLiteral(red: 0.8297499418, green: 0.9978639483, blue: 0.9452367425, alpha: 1)
        prepareFABButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.contents

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.noticeDatetime)
        cell.detailTextLabel?.text = dateString
        
        if task.done {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            cell.backgroundColor = UIColor.lightGray
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
            cell.backgroundColor = #colorLiteral(red: 0.7996098995, green: 1, blue: 0.9844576716, alpha: 0.8470588235)
        }
        
        return cell
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Task",sender: nil)
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let taskViewController:TaskViewController = segue.destination as! TaskViewController

        let indexPath = self.taskTableView.indexPathForSelectedRow
        if indexPath != nil {
            taskViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }

            taskViewController.task = task
        }
    }
    
    @objc func moveTask() {
        self.performSegue(withIdentifier: "Task", sender: nil)
    }
}

extension TaskListViewController {
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
        
        button.addTarget(self, action: #selector(moveTask), for: .touchUpInside)
        
        view.layout(button)
            .width(ButtonLayout.Fab.diameter)
            .height(ButtonLayout.Fab.diameter)
            .center(offsetX: ButtonLayout.Fab.offsetX, offsetY: ButtonLayout.Fab.offsetY)
    }
}

