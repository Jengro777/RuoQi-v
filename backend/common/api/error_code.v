module api

// ═══════════════════════════════════════════════════════════════════════════════
// 统一业务错误码
//   0 = 业务成功（唯一成功值）
//   非 0 = 具体业务失败，前端用 code 精确判断，不依赖 msg 文案
//
// 码结构：6 位数字 = [分类 1 位][域 2 位][错号 3 位]
//   分类（首位）—— 回答"这次错是谁的锅"，前端/告警据此判定是否真故障：
//     1 = 用户行为(A)  正常业务失败（参数、鉴权、权限、找不到、业务校验…）
//     2 = 系统(B)      系统执行出错（服务端异常、未知兜底…）
//     3 = 下游(C)      调用下游/第三方服务出错
//     4 = 依赖组件(D)  基础设施（MySQL / Redis / Kafka …）
//   域（中两位）—— 业务域：
//     00 = 通用/平台（跨域公共）   20 = 用户   21 = 商品   22 = 订单
//     23 = 支付   24 = 财务/资金   25 = 营销   26 = 平台   27 = 租户
//     28 = 工作空间   29 = 消息   30 = 任务   31 = 仓储   32 = 物流
//     33~99 = 预留
//   错号（后三位）—— 000~999，随错号追加；每域预留 x999 作段内兜底
//
// 组织方式：先按【分类】分组，再在同一分类内按【域】依次排（按模块找码见文件头域表）。
//
// 判定规则：
//   code == 0            -> 成功
//   code / 100000 == 1   -> 用户行为（A 类，前端正常处理）
//   code / 100000 == 2   -> 系统（B 类，触发告警）
//   code / 100000 == 3   -> 下游（C 类，触发告警）
//   code / 100000 == 4   -> 依赖组件（D 类，触发告警）
//
// 纪律：
//   - code 一旦对前端暴露即冻结：只新增，不改值、不复用、不改义
//   - 分类/域号全局共享；跨域错误（参数/鉴权/权限/找不到）放域 00，各域不重复
//   - 错误码不携带版本号/错误等级；等级由日志与语义决定
//
// 命名规则：
//   - 业务域码以「域名词」开头：err_user_* / err_order_* / err_payment_* / err_tenant_* ...
//   - 域 00（通用/跨域层）统一以 common_ 开头：err_common_auth / err_common_server / err_common_db ...
//   - 系统/下游/依赖这类跨域码不带业务域名词，靠码首位（分类）识别
// ═══════════════════════════════════════════════════════════════════════════════

// category 返回错误码的分类（第 1 位）：1=用户行为(A) 2=系统(B) 3=下游(C) 4=依赖组件(D)
pub fn category(code int) int {
	return code / 100000
}

// domain 返回错误码的业务域（第 2~3 位）：00=通用/平台 20~99=业务域
pub fn domain(code int) int {
	return (code / 1000) % 100
}

// 0 业务成功（唯一成功值）
pub const success = 0

// =============== 1 用户行为(A) ===============

// · 00 通用/平台(跨域)
pub const err_common_param_invalid = 100001 // 参数/校验错误
pub const err_common_param_missing = 100002 // 必填参数缺失
pub const err_common_auth = 100101 // 未认证/凭证无效
pub const err_common_token_expired = 100102 // 凭证过期（前端触发重新登录）
pub const err_common_permission = 100103 // 无权限（已认证但无权操作）
pub const err_common_not_found = 100201 // 资源不存在（通用兜底）
pub const err_common_conflict = 100202 // 资源冲突/重复请求
pub const err_common_rate_limit = 100301 // 请求过频/限流
pub const err_common_fallback = 100999 // 通用域兜底

// · 20 用户/账户
pub const err_user_not_found = 120001 // 用户不存在
pub const err_user_password_wrong = 120002 // 密码错误
pub const err_user_exists = 120003 // 已注册/账号已存在
pub const err_user_account_locked = 120004 // 账号锁定
pub const err_user_account_banned = 120005 // 账号封禁/停用
pub const err_user_sms_code_error = 120006 // 验证码错误
pub const err_user_sms_code_expired = 120007 // 验证码过期
pub const err_user_fallback = 120999 // 用户域兜底

// · 21 商品
pub const err_product_not_found = 121001 // 商品不存在
pub const err_product_off_shelf = 121002 // 商品已下架
pub const err_product_sku_not_found = 121003 // SKU 不存在
pub const err_product_sku_invalid = 121004 // SKU 无效
pub const err_product_stock_insufficient = 121005 // 库存不足
pub const err_product_fallback = 121999 // 商品域兜底

// · 22 订单
pub const err_order_not_found = 122001 // 订单不存在
pub const err_order_state_error = 122002 // 订单状态不允许此操作
pub const err_order_cancelled = 122003 // 订单已取消
pub const err_order_expired = 122004 // 订单已过期
pub const err_order_duplicate = 122005 // 重复下单
pub const err_order_fallback = 122999 // 订单域兜底

// · 23 支付
pub const err_payment_not_found = 123001 // 支付单不存在
pub const err_payment_failed = 123002 // 支付失败
pub const err_payment_cancelled = 123003 // 支付已取消
pub const err_payment_duplicate = 123004 // 重复支付
pub const err_payment_amount_mismatch = 123005 // 金额不一致
pub const err_payment_refund_failed = 123006 // 退款失败
pub const err_payment_fallback = 123999 // 支付域兜底

// · 24 财务/资金
pub const err_finance_balance_insufficient = 124001 // 余额不足
pub const err_finance_wallet_not_found = 124002 // 钱包不存在
pub const err_finance_account_frozen = 124003 // 账户资金冻结
pub const err_finance_invoice_error = 124004 // 开票失败
pub const err_finance_settlement_error = 124005 // 结算失败
pub const err_finance_fallback = 124999 // 财务域兜底

// · 25 营销/优惠
pub const err_marketing_coupon_not_found = 125001 // 优惠券不存在
pub const err_marketing_coupon_expired = 125002 // 优惠券已过期
pub const err_marketing_coupon_used = 125003 // 优惠券已使用
pub const err_marketing_coupon_not_usable = 125004 // 不满足使用条件
pub const err_marketing_fallback = 125999 // 营销域兜底

// · 26 平台
pub const err_platform_not_ready = 126001 // 平台未就绪/维护中
pub const err_platform_config_error = 126002 // 平台配置错误/未初始化
pub const err_platform_feature_disabled = 126003 // 功能未开放/未授权开通
pub const err_platform_fallback = 126999 // 平台域兜底

// · 27 租户
pub const err_tenant_not_found = 127001 // 租户不存在
pub const err_tenant_disabled = 127002 // 租户已停用/冻结
pub const err_tenant_exists = 127003 // 租户已存在
pub const err_tenant_quota_exceeded = 127004 // 租户配额超限
pub const err_tenant_fallback = 127999 // 租户域兜底

// · 28 工作空间
pub const err_workspace_limited = 128001 // 空间配额不足
pub const err_workspace_not_found = 128002 // 工作空间不存在
pub const err_workspace_exists = 128003 // 工作空间已存在
pub const err_workspace_archived = 128004 // 工作空间已归档/停用
pub const err_workspace_fallback = 128999 // 工作空间域兜底

// · 29 消息
pub const err_msg_send_failed = 129001 // 消息发送失败
pub const err_msg_template_not_found = 129002 // 消息模板不存在
pub const err_msg_recipient_invalid = 129003 // 收件人无效
pub const err_msg_send_timeout = 129004 // 消息发送超时
pub const err_msg_rate_limited = 129005 // 消息发送频率受限
pub const err_msg_channel_unavailable = 129006 // 消息渠道未接入/不可用
pub const err_msg_fallback = 129999 // 消息域兜底

// · 30 任务
pub const err_job_not_found = 130001 // 任务不存在
pub const err_job_execution_failed = 130002 // 任务执行失败
pub const err_job_cancelled = 130003 // 任务已取消
pub const err_job_duplicate = 130004 // 任务重复触发
pub const err_job_unsupported = 130005 // 任务类型不支持
pub const err_job_fallback = 130999 // 任务域兜底

// · 31 仓储
pub const err_warehouse_not_found = 131001 // 仓库不存在
pub const err_warehouse_location_not_found = 131002 // 库位不存在
pub const err_warehouse_inbound_failed = 131003 // 入库操作失败
pub const err_warehouse_outbound_failed = 131004 // 出库操作失败
pub const err_warehouse_stock_error = 131005 // 库存记录异常
pub const err_warehouse_fallback = 131999 // 仓储域兜底

// · 32 物流
pub const err_logistics_not_found = 132001 // 运单/物流单不存在
pub const err_logistics_tracking_failed = 132002 // 轨迹查询失败
pub const err_logistics_status_error = 132003 // 物流状态异常
pub const err_logistics_ship_failed = 132004 // 发货失败
pub const err_logistics_dispatch_failed = 132005 // 调度/揽收失败
pub const err_logistics_fallback = 132999 // 物流域兜底

// =============== 2 系统(B) ===============

// · 00 通用/平台
pub const err_common_server = 200001 // 未知服务端错误
pub const err_common_resource_exhausted = 200002 // 系统资源耗尽(内存/连接/句柄等)
pub const err_common_overload = 200003 // 过载保护/有损降级已触发
pub const err_common_serialize = 200004 // 序列化失败
pub const err_common_consistency = 200005 // 数据一致性异常/对账不平
pub const err_common_unknown = 200999 // 未知兜底

// =============== 3 下游(C) ===============

// · 00 通用/平台
pub const err_common_downstream_timeout = 300001 // 调用下游服务超时
pub const err_common_downstream_failed = 300002 // 调用下游服务失败
pub const err_common_downstream_rejected = 300003 // 下游拒绝(限流/降级/无权限等)
pub const err_common_downstream_bad_response = 300004 // 下游返回异常响应/数据格式错误
pub const err_common_downstream_unreachable = 300005 // 下游不可达/连接失败
pub const err_common_downstream_fallback = 300999 // 下游服务兜底

// =============== 4 依赖组件(D) ===============

// · 00 通用/平台
pub const err_common_db = 400001 // 数据库异常
pub const err_common_db_timeout = 400002 // 数据库超时
pub const err_common_db_connect = 400003 // 数据库连接失败
pub const err_common_cache = 401001 // 缓存异常
pub const err_common_cache_timeout = 401002 // 缓存超时
pub const err_common_cache_connect = 401003 // 缓存连接失败
pub const err_common_mq = 402001 // 消息队列异常
pub const err_common_mq_timeout = 402002 // 消息队列超时
pub const err_common_mq_connect = 402003 // 消息队列连接失败
pub const err_common_oss = 403001 // 对象存储异常
pub const err_common_infra_fallback = 409999 // 依赖组件兜底
