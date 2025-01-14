module currency

// pub fn test_amount_get() {
// 	// assert amount_get("U s d 900").val == 900
// 	// assert amount_get("U s d 900").currency.name == 'USD'
// 	println(amount_get('U s d 900'))
// 	println(amount_get('euro321'))
// 	panic("SSD"
// 	)
// }

pub fn test_rates_get() {
	rates_get(['EUR', 'AED', 'USD', 'EGP'], false)!
	// last arg is to say its a crypto
	rates_get(['TERRA', 'TFT', 'XLM', 'USDC'], true)!

	lock {
		currencies['TFT'] = Currency{
			name: 'TFT'
			usdval: 0.01
		}
		currencies['AED'] = Currency{
			name: 'AED'
			usdval: 0.25
		}
		default_set('USD', 1.0)

		mut u := amount_get('1$')!
		u2 := u.exchange(get('tft')!)!
		assert u2.val == 100.0

		mut a := amount_get('10Aed')!
		mut b := amount_get('AED 10')!
		assert a.val == b.val
		assert a.currency == b.currency
		assert a.val == 10.0

		c := a.exchange(get('tft ')!)!
		assert c.val == 250.0

		mut aa2 := amount_get('0')!
		assert aa2.val == 0.0

		mut aa := amount_get('10')!
		assert aa.val == 10.0
		assert aa.currency.name == 'USD'
		assert aa.currency.usdval == 1.0
	}
}
