import Foundation

var configPath: String!;
#if os(macOS)
configPath = "/Users/yuxiang/Documents/Developer/Web/baixiaotu.cc/baixiaotu.json"
#else
configPath = "/root/swift/baixiaotu.json"
#endif

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
Config.loadConfig(path: configPath)
HTTPManager.startServer()

