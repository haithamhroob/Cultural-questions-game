import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showNewPlayerForm = false;

  void _onPlayerSelected(String name) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signIn(name);
  }

  void _setupNewProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signIn(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final previousPlayers = authService.allUsers;

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, size: 80, color: Color(0xFFF39C12)),
                const SizedBox(height: 16),
                const Text(
                  'اختر اللاعب',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 32),
                
                // --- Previous Players List ---
                if (previousPlayers.isNotEmpty && !_showNewPlayerForm) ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: previousPlayers.length,
                    itemBuilder: (context, index) {
                      final name = previousPlayers[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF2C3E50),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => authService.deleteUser(name),
                            ),
                            onTap: () => _onPlayerSelected(name),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => setState(() => _showNewPlayerForm = true),
                    icon: const Icon(Icons.add, color: Color(0xFFF39C12)),
                    label: const Text('إضافة لاعب جديد', style: TextStyle(color: Color(0xFFF39C12), fontSize: 18)),
                  ),
                ],

                // --- New Player Form ---
                if (previousPlayers.isEmpty || _showNewPlayerForm)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              autofocus: true,
                              decoration: const InputDecoration(
                                labelText: 'اسم اللاعب الجديد',
                                prefixIcon: Icon(Icons.person_add),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => (value == null || value.isEmpty) ? 'برجاء إدخال اسمك' : null,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                if (previousPlayers.isNotEmpty)
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () => setState(() => _showNewPlayerForm = false),
                                      child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: _setupNewProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF27AE60),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('ابدأ اللعب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
