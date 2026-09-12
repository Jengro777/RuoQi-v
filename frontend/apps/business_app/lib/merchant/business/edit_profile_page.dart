import 'package:flutter/material.dart';

/// 个人资料编辑（APP 终端用户）——业务表单静态页。
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nicknameController = TextEditingController(text: '用户0728');
  String _gender = '男';

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 头像
          Center(
            child: Column(
              children: [
                const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 44)),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('修改头像'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  title: const Text('昵称'),
                  trailing: SizedBox(
                    width: 180,
                    child: TextField(
                      controller: _nicknameController,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('性别'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: '男', label: Text('男')),
                      ButtonSegment(value: '女', label: Text('女')),
                    ],
                    selected: {_gender},
                    onSelectionChanged: (s) => setState(() => _gender = s.first),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  title: Text('出生日期'),
                  trailing: Text('1998-01-01'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
