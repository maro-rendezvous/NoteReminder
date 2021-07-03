//
//  Note.swift
//  NoteReminder
//
//  Created by 落合克彦 on 2021/06/27.
//

import RealmSwift

class Note: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0

    // タイトル
    @objc dynamic var title = ""

    // メモ
    @objc dynamic var contents = ""

    // メモ日時
    @objc dynamic var date = Date()
    
    // 登録日時
    @objc dynamic var createDate = Date()
    
    // 更新日時
    @objc dynamic var updateDate = Date()

    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
