module captcha

fn test_generate_captcha() {
	// 生成验证码
	captcha := generate_captcha()
	dump('验证码文本: ${captcha.text}')
	dump('图像数据: ${captcha.image[..50]}...') // 打印部分Base64数据
	assert captcha.text.len == 4
	assert typeof(captcha.image).name == 'string'
}

// captcha_html 案例，仅供参考
// fn test_generate_captch() {
// 	// 设置随机种子
// 	now := time.now()
// 	rand.seed([u32(now.unix()), u32(now.nanosecond)])
// 	// 生成验证码
// 	captcha := generate_captcha()
// 	// 构建包含验证码图片的HTML页面
// 	html := '
// 	<!DOCTYPE html>
// 	<html>
// 	<head>
// 		<title>验证码示例</title>
// 		<style>
// 			body {
// 				font-family: Arial, sans-serif;
// 				display: flex;
// 				flex-direction: column;
// 				align-items: center;
// 				margin: 200px;
// 			}
// 			#captcha-img {
// 				display: block;
// 				margin: 0 auto;
// 				width: 150px; /* 固定宽度 */
// 				height: 50px; /* 固定高度 */
// 			}
// 		</style>
// 	</head>
// 	<body>
// 		<div class="captcha-container">
// 		<img id="captcha-img" src="${captcha.image}" alt="验证码">
// 		</div>
// 	</body>
// 	</html>
// 	'
// 	dump(html)
// }
