import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0

    // 内容
    @objc dynamic var contents = ""

    // 完了状態
    @objc dynamic var done = false
    
    // 通知日時
    @objc dynamic var noticeDatetime = Date()
    
    // 登録日時
    @objc dynamic var createDate = Date()
    
    // 更新日時
    @objc dynamic var updateDate = Date()

    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
