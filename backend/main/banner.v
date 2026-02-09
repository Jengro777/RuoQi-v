module main

pub fn banner() {
	cyan := '\x1b[38;5;51m'
	reset := '\x1b[0m'

	println(
		r'
		____                     ___    _          __     __
 |  _ \   _   _    ___    / _ \  (_)         \ \   / /
 | |_) | | | | |  / _ \  | | | | | |  _____   \ \ / /
 |  _ <  | |_| | | (_) | | |_| | | | |_____|   \ V /
 |_| \_\  \__,_|  \___/   \__\_\ |_|            \_/
' +
		reset)

	println(cyan + ':: RuoQi-V :: Admin Dashboard (v0.5.0)' + reset)
}
