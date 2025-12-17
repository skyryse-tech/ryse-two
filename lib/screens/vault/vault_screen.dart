import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/vault_entry.dart';
import '../../providers/vault_provider.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<VaultProvider>().loadVault();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
        onPressed: () => _openEntrySheet(context),
      ),
      body: Stack(
        children: [
          const _CyberGrid(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.4), width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFFFFF).withOpacity(0.15),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.shield_outlined, color: Color(0xFFFFFFFF), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('CREDENTIALS VAULT', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2)),
                          SizedBox(height: 4),
                          Text('◆ Encrypted Storage ◆', style: TextStyle(color: Color(0xFF8892A8), fontSize: 12, letterSpacing: 1)),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 34,
                        width: 34,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.2), width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () => context.read<VaultProvider>().loadVault(),
                            icon: const Icon(Icons.sync_rounded, color: Color(0xFFFFFFFF), size: 14),
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            splashRadius: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Consumer<VaultProvider>(
                      builder: (context, provider, _) {
                        if (!provider.isConfigured) {
                          return _InfoCard(
                            title: 'Missing encryption key',
                            subtitle: 'Set VAULT_ENCRYPTION_KEY in .env to unlock the vault.',
                            icon: Icons.key_rounded,
                          );
                        }

                        if (provider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0xFFFFFFFF)),
                          );
                        }

                        if (provider.error != null) {
                          return _InfoCard(
                            title: 'Vault error',
                            subtitle: provider.error!,
                            icon: Icons.error_outline,
                          );
                        }

                        if (provider.entries.isEmpty) {
                          return _InfoCard(
                            title: 'No credentials yet',
                            subtitle: 'Tap "Add" to store your first credential.',
                            icon: Icons.lock_outline,
                          );
                        }

                        return ListView.separated(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 72),
                          itemCount: provider.entries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final entry = provider.entries[index];
                            return VaultEntryCard(
                              entry: entry,
                              onEdit: () => _openEntrySheet(context, existing: entry),
                              onDelete: () async {
                                await context.read<VaultProvider>().deleteEntry(entry.id!);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Deleted')),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEntrySheet(BuildContext context, {VaultEntry? existing}) async {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController(text: existing?.username ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final passwordController = TextEditingController(text: existing?.password ?? '');
    final urlController = TextEditingController(text: existing?.url ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        existing == null ? 'Add Credential' : 'Edit Credential',
                        style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF8892A8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _VaultField(controller: usernameController, label: 'Username', validator: _required),
                  _VaultField(controller: emailController, label: 'Email (optional)'),
                  _VaultField(controller: passwordController, label: 'Password', validator: _required, obscure: true),
                  _VaultField(controller: urlController, label: 'URL (optional)'),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;

                      final provider = context.read<VaultProvider>();
                      final entry = VaultEntry(
                        id: existing?.id,
                        service: usernameController.text.trim(),
                        username: usernameController.text.trim(),
                        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                        password: passwordController.text.trim(),
                        url: urlController.text.trim(),
                        createdAt: existing?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      if (existing == null) {
                        await provider.addEntry(entry);
                      } else {
                        await provider.updateEntry(entry);
                      }

                      if (!mounted) return;
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(existing == null ? 'Credential saved' : 'Credential updated')),
                      );
                    },
                    icon: const Icon(Icons.save_rounded),
                    label: Text(existing == null ? 'Save' : 'Update'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required field';
    }
    return null;
  }
}

class VaultEntryCard extends StatefulWidget {
  const VaultEntryCard({super.key, required this.entry, required this.onEdit, required this.onDelete});

  final VaultEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<VaultEntryCard> createState() => _VaultEntryCardState();
}

class _VaultEntryCardState extends State<VaultEntryCard> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFFFFF).withOpacity(0.05),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _copy('Username', entry.username),
                      child: Text(entry.username, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    if (entry.email != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: GestureDetector(
                          onTap: () => _copy('Email', entry.email!),
                          child: Text(entry.email!, style: const TextStyle(color: Color(0xFF8892A8), fontSize: 11)),
                        ),
                      ),
                  ],
                ),
              ),
              if (_hidden)
                GestureDetector(
                  onTap: () => _copy('Password', entry.password),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF000000),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.2), width: 0.8),
                    ),
                    child: const Text('••••••••', style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 12)),
                  ),
                ),
              IconButton(
                icon: Icon(_hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: const Color(0xFFFFFFFF), size: 14),
                onPressed: () => setState(() => _hidden = !_hidden),
              ),
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Color(0xFF8892A8), size: 16),
                onPressed: widget.onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF8892A8), size: 16),
                onPressed: widget.onDelete,
              ),
            ],
          ),
          const SizedBox(height: 4),
              if (!_hidden)
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => _copy('Password', entry.password),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.2), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Key', style: TextStyle(color: Color(0xFF8892A8), fontSize: 11)),
                          const SizedBox(width: 6),
                          Text(entry.password, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
          if (entry.url.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: GestureDetector(
                onTap: () => _copy('URL', entry.url),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF000000),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.2), width: 0.8),
                  ),
                  child: Text(entry.url, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12), overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied'), duration: const Duration(milliseconds: 1200)),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.label, required this.value, this.onCopy, this.trailing});

  final String label;
  final String value;
  final VoidCallback? onCopy;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(color: Color(0xFF8892A8), fontSize: 11)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12), overflow: TextOverflow.ellipsis),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy_rounded, color: Color(0xFF8892A8), size: 14),
              onPressed: onCopy,
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ThinRow extends StatelessWidget {
  const _ThinRow({required this.label, required this.value, this.onCopy, this.trailing});

  final String label;
  final String value;
  final VoidCallback? onCopy;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(color: Color(0xFF8892A8), fontSize: 11)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12), overflow: TextOverflow.ellipsis),
          ),
          if (onCopy != null)
            IconButton(
              icon: const Icon(Icons.copy_rounded, color: Color(0xFF8892A8), size: 14),
              onPressed: onCopy,
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}


class _VaultField extends StatelessWidget {
  const _VaultField({required this.controller, required this.label, this.validator, this.obscure = false});

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscure,
        style: const TextStyle(color: Color(0xFFFFFFFF)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF8892A8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1A2336)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFFFFFF)),
          ),
          filled: true,
          fillColor: const Color(0xFF000000),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle, required this.icon});

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF000000),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFFFFF).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFFFFFF), size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                SizedBox(
                  width: 240,
                  child: Text(subtitle, style: const TextStyle(color: Color(0xFF8892A8), fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CyberGrid extends StatelessWidget {
  const _CyberGrid();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF000000),
      ),
      child: CustomPaint(
        painter: _SlateGridPainter(),
        child: Container(),
      ),
    );
  }
}

class _SlateGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.12)
      ..strokeWidth = 0.6;

    const step = 40.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VaultColors {
  static const Color bg = Color(0xFF000000);
  static const Color accent = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF8892A8);
  static const Color border = Color(0xFF1A2336);
  static const Color grid = Color(0xFFFFFFFF);
}
