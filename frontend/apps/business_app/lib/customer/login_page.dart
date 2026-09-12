import 'package:flutter/material.dart';
import 'package:common/common.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.embedded = false});

  /// 嵌入业务工作台弹窗时去掉自带 AppBar（弹窗顶部已有控制台导航栏）。
  final bool embedded;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('登录功能待接入后端')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '客户登录',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? '请输入用户名' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? '请输入密码' : null,
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _submit, child: const Text('登 录')),
                const SizedBox(height: 12),
                const Center(
                  child: AppBadge(appName: 'customer_app', version: '1.0.0'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: body,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('RuoQi 客户 App')),
      body: body,
    );
  }
}
