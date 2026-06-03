module opt

fn test_opt_generate() {
	token, opt_num := opt_generate()
	dump(token)
	dump(opt_num)
	assert token != ''
	assert typeof(token).name == 'string'
	assert typeof(token).name.len > 0
}

fn test_opt_verify() {
	token_opt, opt := opt_generate()
	// token := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImN0eSI6IiJ9.eyJpc3MiOiJ2LWFkbWluIiwic3ViIjoiY2FwdGNoYSIsIm5iZiI6MTc0OTEyMTYzNCwiZXhwIjozODEyOTEzNDM0LCJpYXQiOjE3NDkxMjE2MzQsImp0aSI6Ijc0NGViMmE0LTk4MDEtNGMwMC05MmNlLTgxNTExZWRiOThlNiIsInJvbGVzIjpbXSwidGVhbV9pZCI6IiIsImFwcF9pZCI6IiIsInBvcnRhbF9pZCI6IiIsImNsaWVudF9pcCI6IiIsImRldmljZV9pZCI6IiIsImNhcHRjaGFfb3B0IjoiMTAwMDAifQ.AyOmQxTZF4vp5plPtrsehqoiF6TNi-B40afeJkfrrrY'
	// captcha_opt := '10000'
	verify := opt_verify(token_opt, opt)
	assert verify == true
}
