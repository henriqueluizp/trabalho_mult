import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/collection_controller.dart';
import '../main.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  final _loginForm = GlobalKey<FormState>();
  final _cadastroForm = GlobalKey<FormState>();

  final _lUsuario = TextEditingController();
  final _lSenha = TextEditingController();
  final _cUsuario = TextEditingController();
  final _cSenha = TextEditingController();

  bool _lOcultar = true;
  bool _cOcultar = true;
  String? _lErro;
  String? _cErro;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _lUsuario.dispose();
    _lSenha.dispose();
    _cUsuario.dispose();
    _cSenha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_loginForm.currentState!.validate()) return;
    setState(() { _loading = true; _lErro = null; });

    try {
      final user = await context.read<AuthService>().login(
        _lUsuario.text, _lSenha.text,
      );
      if (!mounted) return;
      if (user == null) {
        setState(() => _lErro = 'Usuário ou senha incorretos.');
        return;
      }
      await context.read<CollectionController>().setCurrentUser(user.id);
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainNavigation()));
      }
    } catch (e) {
      if (mounted) setState(() => _lErro = 'Erro ao conectar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cadastrar() async {
    if (!_cadastroForm.currentState!.validate()) return;
    setState(() { _loading = true; _cErro = null; });

    try {
      final user = await context.read<AuthService>().register(
        _cUsuario.text, _cSenha.text,
      );
      if (!mounted) return;
      if (user == null) {
        setState(() => _cErro = 'Este usuário já existe.');
        return;
      }
      await context.read<CollectionController>().setCurrentUser(user.id);
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainNavigation()));
      }
    } catch (e) {
      if (mounted) setState(() => _cErro = 'Erro ao cadastrar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.collections_bookmark,
                    size: 72, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text('MeuAcervo',
                    style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
                const SizedBox(height: 32),
                TabBar(
                  controller: _tabs,
                  tabs: const [Tab(text: 'Entrar'), Tab(text: 'Cadastrar')],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 260,
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      Form(
                        key: _loginForm,
                        child: Column(children: [
                          _campo(_lUsuario, 'Usuário', Icons.person_outline,
                              () => setState(() => _lErro = null)),
                          const SizedBox(height: 12),
                          _campoSenha(_lSenha, _lOcultar,
                              () => setState(() => _lOcultar = !_lOcultar),
                              () => setState(() => _lErro = null)),
                          if (_lErro != null) ...[
                            const SizedBox(height: 8),
                            Text(_lErro!,
                                style: TextStyle(
                                    color: theme.colorScheme.error)),
                          ],
                          const SizedBox(height: 16),
                          _botao('Entrar', _loading, _entrar),
                        ]),
                      ),
                      Form(
                        key: _cadastroForm,
                        child: Column(children: [
                          _campo(_cUsuario, 'Usuário', Icons.person_outline,
                              () => setState(() => _cErro = null)),
                          const SizedBox(height: 12),
                          _campoSenha(_cSenha, _cOcultar,
                              () => setState(() => _cOcultar = !_cOcultar),
                              () => setState(() => _cErro = null),
                              minimo: true),
                          if (_cErro != null) ...[
                            const SizedBox(height: 8),
                            Text(_cErro!,
                                style: TextStyle(
                                    color: theme.colorScheme.error)),
                          ],
                          const SizedBox(height: 16),
                          _botao('Criar Conta', _loading, _cadastrar),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String label, IconData icon,
      VoidCallback onChange) {
    return TextFormField(
      controller: ctrl,
      decoration:
          InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      autocorrect: false,
      onChanged: (_) => onChange(),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Campo obrigatório' : null,
    );
  }

  Widget _campoSenha(TextEditingController ctrl, bool ocultar,
      VoidCallback toggle, VoidCallback onChange,
      {bool minimo = false}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: minimo ? 'Senha (mín. 4 caracteres)' : 'Senha',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(ocultar
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
          onPressed: toggle,
        ),
      ),
      obscureText: ocultar,
      onChanged: (_) => onChange(),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Campo obrigatório';
        if (minimo && v.length < 4) return 'Mínimo 4 caracteres';
        return null;
      },
    );
  }

  Widget _botao(String label, bool loading, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onTap,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label),
      ),
    );
  }
}
