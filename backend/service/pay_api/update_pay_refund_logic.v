module pay_api

import veb
import log
import time
import json2 as json
import model.schema_pay { PayRefund }
import common.api
import model { Context }

// ═══ Handler ═══
@['/refund/update'; post]
pub fn (app &Pay) update_pay_refund_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdatePayRefundReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_pay_refund_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_pay_refund_usecase(mut ctx Context, req UpdatePayRefundReq) !UpdatePayRefundResp {
	update_pay_refund_domain(req)!
	return update_pay_refund_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_pay_refund_domain(req UpdatePayRefundReq) ! {
	if req.id == '' {
		return error('pay refund id is required')
	}
}

// ═══ DTO ═══
pub struct UpdatePayRefundReq {
	id                  string @[json: 'id']
	channel_refund_no   ?string @[json: 'channelRefundNo']
	success_time        ?time.Time @[json: 'successTime']
	channel_error_code  ?string @[json: 'channelErrorCode']
	channel_error_msg   ?string @[json: 'channelErrorMsg']
	channel_notify_data ?string @[json: 'channelNotifyData']
	status              ?u8 @[json: 'status']
}

pub struct UpdatePayRefundResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_pay_refund_repo(mut ctx Context, req UpdatePayRefundReq) !UpdatePayRefundResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.channel_refund_no {
			channel_refund_no == v
		},
		if v := req.success_time {
			success_time == v
		},
		if v := req.channel_error_code {
			channel_error_code == v
		},
		if v := req.channel_error_msg {
			channel_error_msg == v
		},
		if v := req.channel_notify_data {
			channel_notify_data == v
		},
		if v := req.status {
			status == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update PayRefund set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdatePayRefundResp{
		msg: 'PayRefund updated successfully'
	}
}
