//
//  Config.swift
//  baixiaotu
//
//  Created by 任玉祥 on 2018/8/17.
//

import Foundation

public struct Config {
    
    public struct MYSQL {
        public static var host = ""
        public static var user = ""
        public static var password = ""
        
    }
    
    public struct SMTP {
        public static var url = ""
        public static var user = ""
        public static var password = ""
    }
    
    /**
     配置信息, configPath 为配置文件路径, json格式为:
     {
         "mysql": {
             "host":"",
             "user":"",
             "password":"",
         },
         "smtp": {
             "url":"",
             "user":"",
             "password":"",
         }
     }
     */
    static func loadConfig(path: String) {
        
        let url = URL.init(fileURLWithPath: path)

        guard let data = try? Data.init(contentsOf: url, options: Data.ReadingOptions.mappedIfSafe) else {
            return
        }
        let obj = try? JSONSerialization.jsonObject(with: data, options: [])
        let config = obj as? [String: [String: String]]
        
        let sql = config?["mysql"]
        MYSQL.host = sql?["host"] ?? ""
        MYSQL.user = sql?["user"] ?? ""
        MYSQL.password = sql?["password"] ?? ""
        
        let smtp = config?["smtp"]
        SMTP.url = smtp?["url"] ?? ""
        SMTP.user = smtp?["user"] ?? ""
        SMTP.password = smtp?["password"] ?? ""
    }
    
    
}
