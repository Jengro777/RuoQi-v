import 'package:flutter/material.dart';

/// 找回密码（APP 终端用户）——业务静态页。
///
/// 步骤：查找账号 → 身份验证 → 设置新密码 → 完成。
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _accountController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  int _step = 0;
  String _verifyType = '手机号';

  @override
  void dispose() {
    _accountController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_step == 3 ? '设置新密码' : '找回密码')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Stepper(current: 0),
              const SizedBox(height: 28),
              if (_step == 0) _buildFindAccount(context),
              if (_step == 1) _buildVerify(context),
              if (_step == 2) _buildNewPassword(context),
              if (_step == 3) _buildDone(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFindAccount(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('查找账号', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '输入注册时使用的手机号、邮箱或用户名',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: '手机号', label: Text('手机号')),
            ButtonSegment(value: '邮箱', label: Text('邮箱')),
            ButtonSegment(value: '账号', label: Text('账号')),
          ],
          selected: {_verifyType},
          onSelectionChanged: (s) => setState(() => _verifyType = s.first),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _accountController,
          decoration: InputDecoration(
            labelText: _verifyType,
            hintText: '请输入$_verifyType',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => setState(() => _step = 1),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('查找账号'),
        ),
        const SizedBox(height: 12),
        Text(
          '如果您之前使用第三方账号登录，若没有绑定手机号或邮箱，无法直接找回密码，需要通过第三方账号登录！',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildVerify(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('身份验证', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '验证码已经发送到您的手机：+86-147******973，请查收',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '验证码',
                  hintText: '请输入验证码',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: () {}, child: const Text('获取验证码')),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => setState(() => _step = 2),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('下一步'),
        ),
      ],
    );
  }

  Widget _buildNewPassword(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('设置新密码', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '输入密码',
            hintText: '请输入密码',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '确认密码',
            hintText: '请确认密码',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => setState(() => _step = 3),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('确认重置密码'),
        ),
      ],
    );
  }

  Widget _buildDone(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.check_circle_outline, size: 72, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text('密码重置成功', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Text('3s 后自动跳转 App 登录页', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('立即跳转'),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    const labels = ['查找账号', '身份验证', '设置密码', '完成'];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const Expanded(child: Divider()),
          Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: i <= current
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: i <= current ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(labels[i], style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ],
    );
  }
}
