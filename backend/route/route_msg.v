module route

import log
import model { Context }
import service.msg_api.emaillog { EmailLog }
import service.msg_api.emailprovider { EmailProvider }
import service.msg_api.messagesender { MessageSender }
import service.msg_api.smslog { SmsLog }
import service.msg_api.smsprovider { SmsProvider }

// =============================================================================
// 消息中心 路由注册
//
// 电子邮件 + 短信 的 日志、提供商、发送器
// 全使用 register_routes_platform（管理端接口）
// =============================================================================

fn (mut app AliasApp) routes_msg(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// Email log management
	app.register_routes_platform[EmailLog, Context](mut &EmailLog{}, '/msg/emaillog', mut ctx)

	// Email provider management
	app.register_routes_platform[EmailProvider, Context](mut &EmailProvider{}, '/msg/emailprovider', mut ctx)

	// SMS log management
	app.register_routes_platform[SmsLog, Context](mut &SmsLog{}, '/msg/smslog', mut ctx)

	// SMS provider management
	app.register_routes_platform[SmsProvider, Context](mut &SmsProvider{}, '/msg/smsprovider', mut ctx)

	// Message sender (send operations)
	app.register_routes_platform[MessageSender, Context](mut &MessageSender{}, '/msg/sender', mut ctx)
}
