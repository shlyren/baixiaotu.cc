//
//  SQLManager.swift
//  baixiaotu
//
//  Created by 任玉祥 on 2018/8/9.
//

import Foundation
import PerfectMySQL

// 数据库认证信息, 可通过Config配置, 也可直接写死
fileprivate let host = Config.MYSQL.host
fileprivate let user = Config.MYSQL.user
fileprivate let pwd = Config.MYSQL.password

class SQLManager {
    
    fileprivate let mySql = MySQL()
    
    func connect() -> Bool {
        
        if mySql.connect(host: host, user: user, password: pwd) == false {
            if mySql.errorCode() != 2058 {
                print("数据库连接失败: \(mySql.errorCode())  " + mySql.errorMessage())
            }
            return false
        }
        
        guard mySql.selectDatabase(named: "db_baixiaotu") else {
            print("数据库选择失败。错误代码：\(mySql.errorCode()) message：\(mySql.errorMessage())")
            return false
        }
        
        return true
    }
    func closeConnect() {
//        mySql.close()    
    }
    
    // 失效链接反馈
    func insertLinkInvalid(type: String, name: String, panLink: String, mail: String,  message: String) -> (Int, String) {
        if name.count == 0 {
            return (-1, "名称不能为空")
        }
        guard connect() else {
            return (-1, "数据库连接失败")
        }
        let sql = "insert into t_television_link (name, baidu_link, type, mail, message) VALUES ('\(name)', '\(panLink)' ,'\(type)','\(mail)', '\(message)')"
        
        let success = mySql.query(statement: sql)
        
        let msg = success == true ? "操作成功" : mySql.errorMessage();
        let status = success == true ? 1 : -1;
        closeConnect()
        
        let mailManager = MailManager()
        mailManager.sendMail(type: type, name: name, baiduLink: panLink, mail: mail, content: message);
        
        
        return (status, msg);
    }
    
    
    
    /// 请求资源
    ///
    /// - Parameters:
    ///   - type: 资源类型 tv, cut, all
    ///   - fromWeb: 是否from web
    /// - Returns: result
    func queryTelevision(type: String?, fromWeb: Bool) -> Any? {
        
        if type == "cut" {
            if fromWeb == true { return getCUT() }
            return ["type": "影视剪辑","items": getCUT()]
        }
        
        if type == "all" {
            if fromWeb == true { return nil }
            return [
                ["type": "影视剪辑", "items": getCUT()],
                ["type": "影视剧", "items": getTV()]
            ]
        }
        
        if fromWeb == true { return getTV() }

        return ["type": "影视剧", "items": getTV()]
    }
    
    
    private func getTV() -> Any? {
        guard connect() else { return nil }
        
        if mySql.query(statement: "select * from t_television") == false {
            print(mySql.errorMessage())
            closeConnect()
            return nil
        }
        
        var items = [[String: Any]]()
        mySql.storeResults()?.forEachRow(callback: { (row) in
            var dict = [String: Any]();
            dict.updateValue(row[1] as Any, forKey: "name")
            dict.updateValue(row[3] as Any, forKey: "baidu_link")
            dict.updateValue(row[5] as Any, forKey: "baidu_pwd")
            dict.updateValue(row[6] as Any, forKey: "bili_av")
            dict.updateValue(row[7] as Any, forKey: "bili_link")
            dict.updateValue(row[8] as Any, forKey: "mark")
            dict.updateValue(row[9] as Any, forKey: "create_time")
            dict.updateValue(row[10] as Any, forKey: "update_time")
            
            items.append(dict)
        })
        
        
        closeConnect()
        return items;
    }
    
    private func getCUT() -> Any? {
        guard connect() else {
            return nil
        }
        if mySql.query(statement: "select * from t_television_cut") == false {
            print(mySql.errorMessage())
            closeConnect()
            return nil
        }
        
        var items = [[String: Any]]()
        mySql.storeResults()?.forEachRow(callback: { (row) in
            
            var dict = [String: Any]();
            dict.updateValue(row[1] as Any, forKey: "name")
            dict.updateValue(row[3] as Any, forKey: "baidu_link")
            dict.updateValue(row[5] as Any, forKey: "baidu_pwd")
            dict.updateValue(row[6] as Any, forKey: "bili_av")
            dict.updateValue(row[7] as Any, forKey: "bili_link")
            dict.updateValue(row[8] as Any, forKey: "mark")
            dict.updateValue(row[9] as Any, forKey: "create_time")
            dict.updateValue(row[10] as Any, forKey: "update_time")
            dict.updateValue(row[13] as Any, forKey: "bili_full")
            dict.updateValue(row[14] as Any, forKey: "bili_full_link")
            
            items.append(dict)
        })
        
        closeConnect()
        return items;
    }
    
}


