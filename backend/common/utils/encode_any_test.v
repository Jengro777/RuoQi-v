module utils

import log
import x.json2 as json

fn test_encode_any() {
	log.info('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	mut req_params := map[string]Any{}
	mut offer_detail_param := map[string]Any{}

	req_params['access_token'] = '9b4305e9-2c5a-4711-8399-0caefda516f4'
	offer_detail_param['offerId'] = '46369207'
	offer_detail_param['countrt'] = 'en'
	req_params['offerDetailParam'] = offer_detail_param

	json_str := encode_any(req_params).json_str()
	json_map := json.decode[json.Any](json_str) or {
		eprintln('Failed to decode JSON')
		return
	}.as_map()

	log.info(json_str)

	mut req_params_str := ''
	ignored_keys := ['key1', 'key2']
	for key, value in json_map {
		if key in ignored_keys {
			continue
		}
		req_params_str += '${key}${value}'
	}
	log.info('req_params_str: ${req_params_str}')

	assert req_params_str == 'access_token9b4305e9-2c5a-4711-8399-0caefda516f4offerDetailParam{"offerId":"46369207","countrt":"en"}'
}
