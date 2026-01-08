import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Mock State
  String _selectedZone = '玄関左';
  bool _notificationApp = true;
  bool _notificationPush = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              title: '自宅設定',
              children: [
                ListTile(
                  title: const Text('置き配ゾーン'),
                  subtitle: Text(_selectedZone),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showZonePicker(context),
                ),
                SwitchListTile(
                  title: const Text('アプリ内通知'),
                  value: _notificationApp,
                  onChanged: (val) => setState(() => _notificationApp = val),
                  secondary: const Icon(Icons.notifications),
                ),
                SwitchListTile(
                  title: const Text('プッシュ通知 (Beta)'),
                  value: _notificationPush,
                  onChanged: (val) => setState(() => _notificationPush = val),
                  secondary: const Icon(Icons.notifications_active),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'アカウント',
              children: [
                const ListTile(
                  title: Text('表示名'),
                  subtitle: Text('佐藤 太郎'),
                  leading: Icon(Icons.person),
                ),
                const ListTile(
                  title: Text('メールアドレス'),
                  subtitle: Text('taro.sato@example.com'),
                  leading: Icon(Icons.email),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'デバイス状態',
              children: const [
                ListTile(
                  title: Text('Ding-Dong AI 01'),
                  subtitle: Text('オンライン • バッテリー 85%'),
                  leading: Icon(Icons.router, color: Colors.green),
                  trailing: Icon(Icons.check_circle, color: Colors.green),
                ),
                ListTile(
                  title: Text('カメラ'),
                  subtitle: Text('正常稼働中'),
                  leading: Icon(Icons.videocam, color: Colors.green),
                ),
                ListTile(
                  title: Text('マイク'),
                  subtitle: Text('正常稼働中'),
                  leading: Icon(Icons.mic, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor)),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  void _showZonePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => SimpleDialog(
        title: const Text('置き配ゾーンを選択'),
        children: [
          SimpleDialogOption(
            onPressed: () { setState(() => _selectedZone = '玄関左'); Navigator.pop(c); },
            child: const Padding(padding: EdgeInsets.all(8.0), child: Text('玄関左')),
          ),
          SimpleDialogOption(
            onPressed: () { setState(() => _selectedZone = '玄関右'); Navigator.pop(c); },
            child: const Padding(padding: EdgeInsets.all(8.0), child: Text('玄関右')),
          ),
          SimpleDialogOption(
            onPressed: () { setState(() => _selectedZone = '宅配ボックス前'); Navigator.pop(c); },
            child: const Padding(padding: EdgeInsets.all(8.0), child: Text('宅配ボックス前')),
          ),
        ],
      ),
    );
  }
}
