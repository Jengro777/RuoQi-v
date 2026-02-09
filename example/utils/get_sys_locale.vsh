#!/usr/bin/env -S v run

import os

fn main() {
	current_os := os.user_os().to_lower() // Unified conversion to lowercase for easy comparison

	if current_os == 'windows' {
		// Windows
		locale := os.execute('powershell "(Get-WinSystemLocale).Name"').output.trim('\r\n')
		println(locale)
	} else if current_os in ['linux', 'macos', 'freebsd', 'openbsd', 'netbsd', 'dragonfly'] {
		// Unix
		lang_env := os.getenv('LANG')
		mut lang := 'en_US'

		if lang_env != '' {
			parts := lang_env.split('.')
			if parts.len > 0 {
				lang = parts[0]
			}
		}

		println(lang)
	} else {
		// Unknown operating system - Use a fallback plan
		println('Unknown operating system: ${current_os}')
		// Final rollback
		println('Use default language: en_US')
	}
}
