import 'package:flutter/material.dart';

/// 第三方登录授权（APP 终端用户）——业务静态页。
///
/// 展示第三方登录的两种路径：未关联账号（需注册关联）与已登录（授权确认）。
class ThirdPartyLoginPage extends StatefulWidget {
  const ThirdPartyLoginPage({super.key});

  @override
  State<ThirdPartyLoginPage> createState() => _ThirdPartyLoginPageState();
}

class _ThirdPartyLoginPageState extends State<ThirdPartyLoginPage> {
  bool _linked = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('第三方登录')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    _linked ? Icons.link : Icons.link_off,
                    size: 40,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _linked ? '已关联账号 - 登录成功' : '未关联账号 - 登录成功',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '使用 Facebook / Google / Apple 账号继续',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('未关联账号')),
                  ButtonSegment(value: true, label: Text('已关联账号')),
                ],
                selected: {_linked},
                onSelectionChanged: (s) => setState(() => _linked = s.first),
              ),
              const SizedBox(height: 24),
              if (!_linked)
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const _ThirdPartyButton(icon: Icons.facebook, label: '通过 Facebook 继续'),
                        const SizedBox(height: 10),
                        const _ThirdPartyButton(icon: Icons.g_mobiledata, label: '通过 Google 继续'),
                        const SizedBox(height: 10),
                        const _ThirdPartyButton(icon: Icons.apple, label: '通过 Apple ID 继续'),
                      ],
                    ),
                  ),
                )
              else
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: const Text('确认授权'),
                ),
              const SizedBox(height: 20),
              Text(
                '中国大陆',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThirdPartyButton extends StatelessWidget {
  const _ThirdPartyButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(46),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
