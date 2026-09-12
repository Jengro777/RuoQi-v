import 'package:flutter/material.dart';

/// 手机号注册（APP 终端用户）——业务静态页。
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController();
  bool _agreed = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign up',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
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
                      children: const [
                        Icon(Icons.flag, size: 18),
                        SizedBox(width: 6),
                        Text('CN  +86', style: TextStyle(fontSize: 13)),
                        Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 96),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _agreed ? () {} : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('下一步'),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _agreed,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text.rich(
                  TextSpan(
                    style: Theme.of(context).textTheme.bodySmall,
                    children: [
                      const TextSpan(text: '已阅读并同意 '),
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
                onChanged: (v) => setState(() => _agreed = v ?? false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
