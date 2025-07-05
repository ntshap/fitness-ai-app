import 'package:flutter/material.dart';
import 'package:fitness_ai_app/services/simple_auth_service.dart';

class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  final SimpleAuthService _authService = SimpleAuthService();
  Map<String, dynamic>? _debugInfo;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  void _loadDebugInfo() {
    setState(() {
      _debugInfo = _authService.getDebugInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Auth'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Authentication Debug Info',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_debugInfo != null) ...[
              Text('Users Count: ${_debugInfo!['users_count']}'),
              Text('Current User: ${_debugInfo!['current_user'] ?? 'None'}'),
              Text('Users List: ${_debugInfo!['users_list']}'),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _authService.resetAuth();
                _loadDebugInfo();
              },
              child: const Text('Reset Auth'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadDebugInfo,
              child: const Text('Refresh Info'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Test Login:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final result = await _authService.login(
                  email: 'test@test.com',
                  password: 'test123',
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login result: ${result['success'] ? 'Success' : result['message']}'),
                    ),
                  );
                  _loadDebugInfo();
                }
              },
              child: const Text('Test Login (test@test.com / test123)'),
            ),
          ],
        ),
      ),
    );
  }
}
