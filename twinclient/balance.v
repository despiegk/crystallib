module twinclient

import json

pub fn (mut tw Client) get_balance(address string) ?BalanceResult {
	msg := tw.send('twinserver.balance.get', '{"address": "$address"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(BalanceResult, response.data) or {}
}

pub fn (mut tw Client) get_my_balance() ?BalanceResult {
	msg := tw.send('twinserver.balance.getMyBalance', '{}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(BalanceResult, response.data) or {}
}

pub fn (mut tw Client) transfer_balance(payload BalanceTransfer) ? {
	payload_encoded := json.encode_pretty(payload)
	msg := tw.send('twinserver.balance.transfer', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	println(response)
	// return json.decode(DeployResponse, response.data) or {}
}
