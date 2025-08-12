import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/app_config.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _openaiController;
  late TextEditingController _claudeController;
  late TextEditingController _ollamaController;
  late TextEditingController _n8nController;
  late TextEditingController _agentController;
  String _selectedProvider = 'n8n';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    final authService = context.read<AuthService>();
    final config = authService.config;
    
    _openaiController = TextEditingController(text: config?.openaiApiKey ?? '');
    _claudeController = TextEditingController(text: config?.claudeApiKey ?? '');
    _ollamaController = TextEditingController(text: config?.ollamaUrl ?? '');
    _n8nController = TextEditingController(text: config?.n8nWebhookUrl ?? '');
    _agentController = TextEditingController(text: config?.defaultAgent ?? 'Jarvis');
    _selectedProvider = config?.defaultProvider ?? 'n8n';
    _isDarkMode = config?.isDarkMode ?? false;
  }

  @override
  void dispose() {
    _openaiController.dispose();
    _claudeController.dispose();
    _ollamaController.dispose();
    _n8nController.dispose();
    _agentController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final authService = context.read<AuthService>();
      final currentConfig = authService.config ?? AppConfig();
      
      final newConfig = currentConfig.copyWith(
        openaiApiKey: _openaiController.text.isNotEmpty ? _openaiController.text : null,
        claudeApiKey: _claudeController.text.isNotEmpty ? _claudeController.text : null,
        ollamaUrl: _ollamaController.text.isNotEmpty ? _ollamaController.text : null,
        n8nWebhookUrl: _n8nController.text,
        defaultProvider: _selectedProvider,
        defaultAgent: _agentController.text,
        isDarkMode: _isDarkMode,
      );
      
      authService.updateConfig(newConfig);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres sauvegardés'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres avancés'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Sauvegarder',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section API Keys
            _buildSection(
              title: 'Clés API',
              icon: Icons.key,
              children: [
                _buildTextField(
                  controller: _openaiController,
                  label: 'Clé API OpenAI',
                  hint: 'sk-...',
                  icon: Icons.psychology,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _claudeController,
                  label: 'Clé API Claude',
                  hint: 'sk-ant-...',
                  icon: Icons.auto_awesome,
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ollamaController,
                  label: 'URL Ollama',
                  hint: 'http://localhost:11434',
                  icon: Icons.computer,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Section Configuration
            _buildSection(
              title: 'Configuration',
              icon: Icons.settings,
              children: [
                _buildTextField(
                  controller: _n8nController,
                  label: 'URL Webhook n8n',
                  hint: 'https://n8n1890.infra.ori3com.cloud/webhook/...',
                  icon: Icons.webhook,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'URL n8n est requise';
                    }
                    if (!Uri.tryParse(value)?.hasScheme == true) {
                      return 'URL invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _agentController,
                  label: 'Nom de l\'agent par défaut',
                  hint: 'Jarvis',
                  icon: Icons.smart_toy,
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Provider IA par défaut',
                  value: _selectedProvider,
                  items: const [
                    DropdownMenuItem(value: 'n8n', child: Text('n8n')),
                    DropdownMenuItem(value: 'openai', child: Text('OpenAI')),
                    DropdownMenuItem(value: 'claude', child: Text('Claude')),
                    DropdownMenuItem(value: 'ollama', child: Text('Ollama')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProvider = value!;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Section Apparence
            _buildSection(
              title: 'Apparence',
              icon: Icons.palette,
              children: [
                SwitchListTile(
                  title: const Text('Mode sombre'),
                  subtitle: const Text('Activer le thème sombre'),
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                  },
                  secondary: const Icon(Icons.dark_mode),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Section Informations
            _buildSection(
              title: 'Informations',
              icon: Icons.info,
              children: [
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(authService.userEmail ?? 'Non connecté'),
                    );
                  },
                ),
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text('Statut'),
                      subtitle: Text(authService.isAdmin ? 'Administrateur' : 'Utilisateur'),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.app_settings_alt),
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
