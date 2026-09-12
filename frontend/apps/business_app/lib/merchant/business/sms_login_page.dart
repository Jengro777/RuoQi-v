import 'package:flutter/material.dart';

/// 手机验证码登录（终端用户 APP）——由 IDM 原型重构的业务静态页。
class SmsLoginPage extends StatefulWidget {
  const SmsLoginPage({super.key});

  @override
  State<SmsLoginPage> createState() => _SmsLoginPageState();
}

class _SmsLoginPageState extends State<SmsLoginPage> {
  final _phoneController = TextEditingController(text: '15020579521');
  final _codeController = TextEditingController();
  final String _region = 'CN  +86';

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Icon(Icons.verified_user_outlined, size: 64, color: colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                '手机验证码登录',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              // 手机号输入（带地区前缀）
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '手机号',
                  hintText: '请输入手机号',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flag, size: 18),
                        const SizedBox(width: 6),
                        Text(_region, style: const TextStyle(fontSize: 13)),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 96),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // 验证码输入 + 获取验证码
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '验证码',
                        hintText: '请输入验证码',
                        prefixIcon: Icon(Icons.sms_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('获取验证码'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('下一步'),
              ),
              const SizedBox(height: 20),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    const TextSpan(text: '未注册的手机号验证后将自动创建账号，登录即代表你已同意 '),
                    TextSpan(
                      text: '用户协议',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                    const TextSpan(text: ' 和 '),
                    TextSpan(
                      text: '隐私政策',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('其他方式登录'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
