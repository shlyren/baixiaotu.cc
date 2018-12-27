//
//  MailManager.swift
//  baixiaotu
//
//  Created by 任玉祥 on 2018/8/16.
//


import PerfectSMTP
// 邮件系统认证信息, 可通过Config配置, 也可直接写死
fileprivate let url = Config.SMTP.url // 邮件smtp地址
fileprivate let user = Config.SMTP.user // 邮箱地址
fileprivate let pwd = Config.SMTP.password // 密码

class MailManager {
    
    func sendMail(type: String, name: String, baiduLink: String, mail: String, content: String) {
        
        let client = SMTPClient.init(url: url, username: user, password: pwd, requiresTLSUpgrade: true)
        
        // 起草一封邮件，首先用登录信息初始化邮件
        let email = EMail.init(client: client)
        
        // 设置标题
        email.subject = name

        // 设置寄件人信息
        email.from = Recipient(name: "白小兔", address: "baixiaotu@yuxiang.ren")
        // 设置收件人，包括收件人、抄送和秘密抄送
        email.to.append(Recipient(name: "任玉祥", address: "mail@yuxiang.ren"))

        var typeName = "未知";
        if type == "0"{
            typeName = "影视剧"
        }else if type == "1" {
            typeName = "影视剧CUT"
        }
        // 邮件正文，可以是HTML格式，也可以是普通文本
        email.html = "<h2>白小兔资源反馈</h2>" +
            "<p>资源标题: \(name);</p>" +
            "<p>资源类型: \(typeName);</p>" +
            "<p>资源链接: \(baiduLink);</p>" +
            "<p>联系邮箱: \(mail);</p>" +
            "<p>其他信息: \(content);</p>"

        // 设置收件人，包括收件人、抄送和秘密抄送
//        email.to.append(Recipient(name: "收件人全名", address: "某人@某地址"))
//        email.cc.append(Recipient(name: "抄送", address: "某人@某其他地址"))
//        email.bcc.append(Recipient(name: "密送", address: "某人@某处"))

        // 追加附件
//        email.attachments.append("/本地/计算机/文件.txt")
//        email.attachments.append("/本地/电脑/照片.jpg")

        // 发送邮件，发送结束后回调
        do {
            try email.send { code, header, body in
                /// 打印邮件服务器响应信息
                print("发送成功")
            }//end send
        }catch(let error) {
            /// 如果程序运行到了这里，表示发送不成功
            print(error)
        }
    }
    
}



