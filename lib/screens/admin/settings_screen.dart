import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jarvis_mobile_app/config/app_config.dart';
import 'package:jarvis_mobile_app/config/theme.dart';
import 'package:jarvis_mobile_app/core/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _selectedModels = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Contrôleurs pour les URLs
    _controllers['openai_url'] = TextEditingController(text: AppConfig.getApiUrl('openai_url'));
    _controllers['claude_url'] = TextEditingController(text: AppConfig.getApiUrl('claude_url'));
    _controllers['ollama_url'] = TextEditingController(text: AppConfig.getApiUrl('ollama_url'));
    _controllers['custom_ai_url'] = TextEditingController(text: AppConfig.getApiUrl('custom_ai_url'));
    _controllers['webhook_text_url'] = TextEditingController(text: AppConfig.getApiUrl('webhook_text_url'));
    _controllers['webhook_voice_url'] = TextEditingController(text: AppConfig.getApiUrl('webhook_voice_url'));
    _controllers['logging_url'] = TextEditingController(text: AppConfig.getApiUrl('logging_url'));

    // Modèles sélectionnés
    _selectedModels['openai'] = AppConfig.getModel('openai');
    _selectedModels['claude'] = AppConfig.getModel('claude');
    _selectedModels['ollama'] = AppConfig.getModel('ollama');
    _selectedModels['custom'] = AppConfig.getModel('custom');
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Sauvegarder les URLs
      for (final entry in _controllers.entries) {
        await AppConfig.setApiUrl(entry.key, entry.value.text);
      }

      // Sauvegarder les modèles
      for (final entry in _selectedModels.entries) {
        await AppConfig.setModel(entry.key, entry.value);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Paramètres sauvegardés avec succès'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final adminPermissions = ref.watch(adminPermissionsProvider);

    // Vérifier les permissions
    if (!adminPermissions.canAccessAdminPanel) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accès refusé'),
        ),
        body: const Center(
          child: Text('Vous n\'avez pas les permissions pour accéder à cette page.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres Admin'),
        actions: [
          if (adminPermissions.canModifyConfig)
            IconButton(
              onPressed: _isLoading ? null : _saveSettings,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              tooltip: 'Sauvegarder',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Section APIs
            _buildSectionHeader('Configuration des APIs'),
            const SizedBox(height: 16),

            // OpenAI
            _buildUrlField(
              controller: _controllers['openai_url']!,
              label: 'URL OpenAI',
              hint: 'https://api.openai.com/v1',
              icon: Icons.api,
            ),
            const SizedBox(height: 16),

            // Claude
            _buildUrlField(
              controller: _controllers['claude_url']!,
              label: 'URL Claude',
              hint: 'https://api.anthropic.com/v1',
              icon: Icons.api,
            ),
            const SizedBox(height: 16),

            // Ollama
            _buildUrlField(
              controller: _controllers['ollama_url']!,
              label: 'URL Ollama',
              hint: 'http://localhost:11434',
              icon: Icons.api,
            ),
            const SizedBox(height: 16),

            // Custom AI
            _buildUrlField(
              controller: _controllers['custom_ai_url']!,
              label: 'URL Custom AI',
              hint: 'https://your-custom-ai.com/api',
              icon: Icons.api,
            ),
            const SizedBox(height: 32),

            // Section Webhooks
            _buildSectionHeader('Configuration des Webhooks'),
            const SizedBox(height: 16),

            // Webhook Text
            _buildUrlField(
              controller: _controllers['webhook_text_url']!,
              label: 'Webhook Text (N8N/Flowise)',
              hint: 'https://n8n.your-domain.com/webhook/text',
              icon: Icons.webhook,
            ),
            const SizedBox(height: 16),

            // Webhook Voice
            _buildUrlField(
              controller: _controllers['webhook_voice_url']!,
              label: 'Webhook Voice (N8N/Flowise)',
              hint: 'https://n8n.your-domain.com/webhook/voice',
              icon: Icons.webhook,
            ),
            const SizedBox(height: 16),

            // Logging URL
            _buildUrlField(
              controller: _controllers['logging_url']!,
              label: 'URL Logging',
              hint: 'https://logging.your-domain.com/api/logs',
              icon: Icons.analytics,
            ),
            const SizedBox(height: 32),

            // Section Modèles
            _buildSectionHeader('Configuration des Modèles'),
            const SizedBox(height: 16),

            // Modèles OpenAI
            _buildModelDropdown(
              label: 'Modèle OpenAI',
              value: _selectedModels['openai']!,
              items: const [
                'gpt-4',
                'gpt-4-turbo',
                'gpt-3.5-turbo',
                'gpt-3.5-turbo-16k',
              ],
              onChanged: (value) {
                setState(() {
                  _selectedModels['openai'] = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Modèles Claude
            _buildModelDropdown(
              label: 'Modèle Claude',
              value: _selectedModels['claude']!,
              items: const [
                'claude-3-opus-20240229',
                'claude-3-sonnet-20240229',
                'claude-3-haiku-20240307',
                'claude-2.1',
              ],
              onChanged: (value) {
                setState(() {
                  _selectedModels['claude'] = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Modèles Ollama
            _buildModelDropdown(
              label: 'Modèle Ollama',
              value: _selectedModels['ollama']!,
              items: const [
                'llama2:13b',
                'llama2:7b',
                'mistral:7b',
                'codellama:13b',
                'gpt4all:13b',
              ],
              onChanged: (value) {
                setState(() {
                  _selectedModels['ollama'] = value!;
                });
              },
            ),
            const SizedBox(height: 32),

            // Section Utilisateur
            _buildSectionHeader('Informations Utilisateur'),
            const SizedBox(height: 16),

            if (currentUser != null) ...[
              _buildInfoCard(
                title: 'Email',
                value: currentUser.email,
                icon: Icons.email,
              ),
              const SizedBox(height: 8),
              _buildInfoCard(
                title: 'Nom',
                value: currentUser.name ?? 'Non défini',
                icon: Icons.person,
              ),
              const SizedBox(height: 8),
              _buildInfoCard(
                title: 'Rôle',
                value: currentUser.isSuperAdmin ? 'Super Admin' : (currentUser.isAdmin ? 'Admin' : 'Utilisateur'),
                icon: Icons.admin_panel_settings,
              ),
              const SizedBox(height: 8),
              _buildInfoCard(
                title: 'Date de création',
                value: currentUser.createdAt.toString().split(' ')[0],
                icon: Icons.calendar_today,
              ),
            ],

            const SizedBox(height: 32),

            // Bouton de déconnexion
            if (adminPermissions.canModifyConfig)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () async {
                  await ref.read(currentUserProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildUrlField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        if (!Uri.tryParse(value)?.hasAbsolutePath ?? true) {
          return 'Veuillez entrer une URL valide';
        }
        return null;
      },
    );
  }

  Widget _buildModelDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
