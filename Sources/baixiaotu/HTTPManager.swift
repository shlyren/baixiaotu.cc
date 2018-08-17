//
//  HTTPManager.swift
//  baixiaotu
//
//  Created by 任玉祥 on 2018/8/8.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

class HTTPManager {
    //MARK: 开启服务
    
    fileprivate let server = HTTPServer.init()
    
    static func startServer() {
        HTTPManager.init().startServerWithNew()
    }
}


private extension HTTPManager {
    func startServerWithNew() {
//        server.documentRoot = "webroot"      //根目录
        server.serverPort = 1201
        server.serverAddress = "127.0.0.1"
        
        //路由添加进服务
        server.addRoutes(makeHttpRoutes())
        
        
        do {
            print("启动HTTP服务器")
            try server.start()
        } catch PerfectError.networkError(let err, let msg) {
            print("网络出现错误：\(err) \(msg)")
        } catch {
            print("网络未知错误")
        }
    }
    
    //MARK: 注册路由
    func makeHttpRoutes() -> Routes {
        var routes = Routes.init()//创建路由器
        
        // this api for baixiaotu.cc website
        routes.add(uri: "/api/**") { (request, response) in
            
            response.setHeader(.contentType, value: "application/json") //响应头
            let body = self.getBodyString(request: request)
            response.setBody(string: body)
            response.completed()
        }
        
        //添加http请求监听
        routes.add(uris: ["/**"]) { (request, response) in
            
     #if os(macOS)
            print(request.path)
            // for web server on Mac
            let rootPath = "/Users/yuxiang/Documents/Developer/Web/baixiaotu.cc/baixiaotu/Sources/html";
            let handler = StaticFileHandler(documentRoot: rootPath, allowResponseFilters: true)
            handler.handleRequest(request: request, response: response)
            
//            response.completed(status: HTTPResponseStatus.ok)
     #else
            // for api server on Linux.
            // on Linux the website is work by nginx.
            response.setHeader(.contentType, value: "application/json") //响应头
            let body = self.getBodyString(request: request)
            response.setBody(string: body)
            response.completed()
     #endif
            
        }
        return routes
    }
}


extension HTTPManager {
    /// 获取body
    func getBodyString(request: HTTPRequest) -> String {
        print(request.path)
        switch request.path.lastFilePathComponent {
        case "television":
            return getTelevision(request:request);
        case "link_invalid":
            return linkInvalid(request:request)
        default:
            return ResponseBody(status: -1,
                                message: "请求失败",
                                data: "The path '\(request.path)' was not found")
        }
    }
    
    
    private func linkInvalid(request: HTTPRequest) -> String {
        let type = request.param("type")
        let name = request.param("name");
        let baidu_link = request.param("baidu_link");
        let message = request.param("message");
        let mysql = SQLManager();
        let result = mysql.insertLinkInvalid(type: type, name: name, panLink: baidu_link, message: message)
        
        return ResponseBody(status: result.0, message: result.1, data: nil);
    }
    
    private func getTelevision(request: HTTPRequest) -> String {
        let type = request.param("type");
        let web = request.param("from") == "web"
        let mysql = SQLManager();
        let result = mysql.queryTelevision(type: type, fromWeb: web)
        if web == true {
            return EcodingString(data: result ?? [])
        }else {
            return ResponseBody(status: 1, message: nil, data: result);
        }
        
    }
    
    
    //MARK: - 格式化消息体
    private func ResponseBody(status: Int, message: String?, data: Any?) -> String {
        
        var result = Dictionary<String, Any>()
        result.updateValue(status, forKey: "status")
        result.updateValue(message ?? NSNull(), forKey: "message")
        result.updateValue(data as Any, forKey: "result")
        return EcodingString(data: result)
    }
    
    private func EcodingString(data: Any) -> String {
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            return "{\"message\":\"jsonDataEncodeError: line\(#line-1)\",\"status\":\"-1\"}"
        }
        
        guard let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else {
            return "{\"message\":\"jsonStringEncodeError: line\(#line-1)\",\"status\":\"-1\"}"
        }
        
        return jsonString
    }
}

extension HTTPRequest {
    func param(_ name: String) -> String {
        guard let value = param(name: name, defaultValue: "") else { return "" }
        return value
    }
}
