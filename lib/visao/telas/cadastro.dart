import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trailer_dm/modelo/Usuario.dart';
import 'package:trailer_dm/controle/AutorizacaoController.dart';
import 'package:trailer_dm/visao/util/layout.dart';
import 'package:trailer_dm/visao/telas/login.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = Usuario(
      usuario: _usuarioController.text,
      senha: _senhaController.text,
      nome: _nomeController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
    );

    final sucesso = await AutorizacaoController.cadastrarUsuario(usuario);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro realizado! Faça login.")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Esse usuário já existe")));
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));
    return Layout(currentIndex: 3, body: _conteudo());
  }

  Widget _conteudo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 20.h),

            Text(
              "Criar Conta",
              style: TextStyle(
                fontSize: 26.sp,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 30.h),

            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: "Nome"),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Informe o nome' : null,
            ),
            SizedBox(height: 15.h),

            TextFormField(
              controller: _telefoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Telefone"),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Informe o telefone'
                  : null,
            ),
            SizedBox(height: 15.h),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Informe o email' : null,
            ),
            SizedBox(height: 15.h),

            TextFormField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Senha",
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe a senha';
                if (value.length < 6)
                  return 'A senha deve ter pelo menos 6 caracteres';
                return null;
              },
            ),
            SizedBox(height: 15.h),

            TextFormField(
              controller: _confirmarSenhaController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Confirmar Senha",
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value != _senhaController.text)
                  return 'As senhas não coincidem';
                return null;
              },
            ),

            SizedBox(height: 30.h),

            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: _cadastrar,
                child: Text("Cadastrar", style: TextStyle(fontSize: 16.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
