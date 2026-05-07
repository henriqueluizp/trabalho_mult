import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../../../features/collection/collection_module.dart';
import '../../../../features/collection/presentation/controllers/collection_controller.dart';
import '../../../../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formLoginKey = GlobalKey<FormState>();
  final _formCadastroKey = GlobalKey<FormState>();

  final _loginUsuarioCtrl = TextEditingController();
  final _loginSenhaCtrl = TextEditingController();
  final _cadastroUsuarioCtrl = TextEditingController();
  final _cadastroSenhaCtrl = TextEditingController();

  bool _loginOcultarSenha = true;
  bool _cadastroOcultarSenha = true;
  String? _loginErro;
  String? _cadastroErro;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUsuarioCtrl.dispose();
    _loginSenhaCtrl.dispose();
    _cadastroUsuarioCtrl.dispose();
    _cadastroSenhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formLoginKey.currentState!.validate()) return;
    setState(() { _carregando = true; _loginErro = null; });

    final auth = getIt<AuthLocalDatasource>();
    final user = await auth.login(
      _loginUsuarioCtrl.text,
      _loginSenhaCtrl.text,
    );

    if (!mounted) return;
    setState(() => _carregando = false);

    if (user == null) {
      setState(() => _loginErro = 'Usuário ou senha incorretos.');
      return;
    }

    await context.read<CollectionController>().setCurrentUser(user.id);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  Future<void> _cadastrar() async {
    if (!_formCadastroKey.currentState!.validate()) return;
    setState(() { _carregando = true; _cadastroErro = null; });

    final auth = getIt<AuthLocalDatasource>();
    final user = await auth.register(
      _cadastroUsuarioCtrl.text,
      _cadastroSenhaCtrl.text,
    );

    if (!mounted) return;
    setState(() => _carregando = false);

    if (user == null) {
      setState(() => _cadastroErro = 'Este nome de usuário já está em uso.');
      return;
    }

    await context.read<CollectionController>().setCurrentUser(user.id);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
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
                Text(
                  'MeuAcervo',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                // Abas: Entrar | Cadastrar
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Entrar'),
                    Tab(text: 'Cadastrar'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 280,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _FormLogin(
                        formKey: _formLoginKey,
                        usuarioCtrl: _loginUsuarioCtrl,
                        senhaCtrl: _loginSenhaCtrl,
                        ocultarSenha: _loginOcultarSenha,
                        erro: _loginErro,
                        carregando: _carregando,
                        onToggleSenha: () => setState(
                            () => _loginOcultarSenha = !_loginOcultarSenha),
                        onChanged: () =>
                            setState(() => _loginErro = null),
                        onSubmit: _entrar,
                      ),
                      _FormCadastro(
                        formKey: _formCadastroKey,
                        usuarioCtrl: _cadastroUsuarioCtrl,
                        senhaCtrl: _cadastroSenhaCtrl,
                        ocultarSenha: _cadastroOcultarSenha,
                        erro: _cadastroErro,
                        carregando: _carregando,
                        onToggleSenha: () => setState(() =>
                            _cadastroOcultarSenha = !_cadastroOcultarSenha),
                        onChanged: () =>
                            setState(() => _cadastroErro = null),
                        onSubmit: _cadastrar,
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
}

class _FormLogin extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usuarioCtrl;
  final TextEditingController senhaCtrl;
  final bool ocultarSenha;
  final String? erro;
  final bool carregando;
  final VoidCallback onToggleSenha;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  const _FormLogin({
    required this.formKey,
    required this.usuarioCtrl,
    required this.senhaCtrl,
    required this.ocultarSenha,
    required this.erro,
    required this.carregando,
    required this.onToggleSenha,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: usuarioCtrl,
            decoration: const InputDecoration(
              labelText: 'Usuário',
              prefixIcon: Icon(Icons.person_outline),
            ),
            autocorrect: false,
            onChanged: (_) => onChanged(),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Informe o usuário' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: senhaCtrl,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(ocultarSenha
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: onToggleSenha,
              ),
            ),
            obscureText: ocultarSenha,
            onChanged: (_) => onChanged(),
            validator: (v) =>
                v == null || v.isEmpty ? 'Informe a senha' : null,
          ),
          if (erro != null) ...[
            const SizedBox(height: 8),
            Text(erro!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: carregando ? null : onSubmit,
              child: carregando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Entrar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCadastro extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usuarioCtrl;
  final TextEditingController senhaCtrl;
  final bool ocultarSenha;
  final String? erro;
  final bool carregando;
  final VoidCallback onToggleSenha;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  const _FormCadastro({
    required this.formKey,
    required this.usuarioCtrl,
    required this.senhaCtrl,
    required this.ocultarSenha,
    required this.erro,
    required this.carregando,
    required this.onToggleSenha,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: usuarioCtrl,
            decoration: const InputDecoration(
              labelText: 'Usuário',
              prefixIcon: Icon(Icons.person_outline),
            ),
            autocorrect: false,
            onChanged: (_) => onChanged(),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Informe o usuário' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: senhaCtrl,
            decoration: InputDecoration(
              labelText: 'Senha (mín. 4 caracteres)',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(ocultarSenha
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: onToggleSenha,
              ),
            ),
            obscureText: ocultarSenha,
            onChanged: (_) => onChanged(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe a senha';
              if (v.length < 4) return 'Mínimo 4 caracteres';
              return null;
            },
          ),
          if (erro != null) ...[
            const SizedBox(height: 8),
            Text(erro!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: carregando ? null : onSubmit,
              child: carregando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Criar Conta'),
            ),
          ),
        ],
      ),
    );
  }
}
