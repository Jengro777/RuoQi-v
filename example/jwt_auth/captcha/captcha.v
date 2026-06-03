module captcha

import rand
import encoding.base64
import time

struct Captcha {
mut:
	text  string
	image string // Base64编码的SVG图像
}

// 生成图形验证码
pub fn generate_captcha() Captcha {
	width := 120
	height := 40
	char_count := 4

	// 设置随机种子,每次运行程序时生成不同的随机数序列
	now := time.now()
	rand.seed([u32(now.unix()), u32(now.nanosecond)])

	// 1. 生成随机文本
	chars := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789@#%*'
	mut text := ''
	for _ in 0 .. char_count {
		idx := rand.intn(chars.len) or { 0 }
		text += chars[idx..idx + 1]
	}

	// 2. 创建SVG图像
	mut svg := '<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0,0,${width},${height}">\n'

	// 背景（渐变）
	svg += '<defs><linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="#f8f9fa" />
              <stop offset="100%" stop-color="#e9ecef" />
            </linearGradient></defs>
            <rect width="100%" height="100%" fill="url(#bg)" />\n'

	// 干扰线
	for _ in 0 .. 5 {
		x1 := rand.intn(width) or { 0 }
		y1 := rand.intn(height) or { 0 }
		x2 := rand.intn(width) or { 0 }
		y2 := rand.intn(height) or { 0 }
		stroke := '#${rand.hex(3)}'
		svg += '<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${stroke}" stroke-width="1" />\n'
	}

	// 噪点
	for _ in 0 .. 50 {
		x := rand.intn(width) or { 0 }
		y := rand.intn(height) or { 0 }
		svg += '<circle cx="${x}" cy="${y}" r="1" fill="#495057" />\n'
	}

	// 验证码文本（居中显示）
	font_size := 24
	// 计算字符间距和起始位置，确保居中
	total_text_width := font_size * text.len
	start_x := (width - total_text_width) / 2 + 10 // 加10像素偏移补偿
	start_y := height / 2 + font_size / 3 // 垂直居中

	for i in 0 .. text.len {
		ch := text[i..i + 1]
		// 每个字符的位置计算（确保居中）
		char_x := start_x + i * (font_size - 2) // 减少间距使字符更紧凑
		char_y := start_y + rand.intn(8) or { 0 } - 4 // 垂直方向轻微随机偏移
		rotate := rand.intn(20) or { 0 } - 10 // 减少旋转角度

		// 随机颜色（深色系）
		fill := '#${rand.hex(2)}${rand.hex(2)}${rand.hex(2)}'

		svg += '<text x="${char_x}" y="${char_y}" font-family="Arial" font-size="${font_size}"
                fill="${fill}" transform="rotate(${rotate},${char_x},${char_y})"
                font-weight="bold" text-anchor="middle" dominant-baseline="middle">${ch}</text>\n'
	}

	svg += '</svg>'

	// 3. 返回Base64编码的SVG
	return Captcha{
		text:  text
		image: 'data:image/svg+xml;base64,' + base64.encode_str(svg)
	}
}
