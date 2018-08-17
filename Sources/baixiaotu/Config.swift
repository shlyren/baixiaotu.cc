//
//  Config.swift
//  baixiaotu
//
//  Created by 任玉祥 on 2018/8/17.
//

import Foundation

public struct Config {
    

    public struct MYSQL {
        
        public static var host: String {
            get {
                return SQLConfig["host"] ?? ""
            }
            set {
                SQLConfig["host"] = newValue
            }
        }
        public static var user: String {
            get {
                return SQLConfig["user"] ?? ""
            }
            set {
                SQLConfig["user"] = newValue
            }
            
        }
        public static var password: String {
            get {
                return SQLConfig["password"] ?? ""
            }
            set {
                SQLConfig["password"] = newValue
            }
            
        }
    }
    
    public struct SMTP {
        
        public static var url: String {
            get {
                return SMTPConfig["url"] ?? ""
            }
            set {
                SMTPConfig["url"] = newValue
            }
        }
        public static var user: String {
            get {
                return SMTPConfig["user"] ?? ""
            }
            set {
                SMTPConfig["user"] = newValue
            }
            
        }
        public static var password: String {
            get {
                return SMTPConfig["password"] ?? ""
            }
            set {
                SMTPConfig["password"] = newValue
            }
            
        }
    }
    
    
    private static var SQLConfig = [String: String]()
    private static var SMTPConfig = [String: String]()
    
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
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return
        }

        guard let config = obj as? [String: [String: String]]  else {
            return
        }

        SQLConfig = config["mysql"]!
        SMTPConfig = config["smtp"]!

    }
    
    
}
