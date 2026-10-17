import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trailer_dm/modelo/Autorizacao.dart';
import 'package:trailer_dm/controle/ApiLogin.dart';
import 'package:trailer_dm/controle/AutorizacaoController.dart';
import 'package:trailer_dm/visao/util/layout.dart';
import 'package:trailer_dm/visao/telas/principal.dart';
import 'package:trailer_dm/visao/telas/cadastro.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    final auth = Autorizacao(
      email: _emailController.text.trim(),
      senha: _senhaController.text,
      tokenAutorizacao: '',
    );

    try {
      await AutorizacaoController.verificaAutorizacaoOnline(auth);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Principal()),
      );
    } on ApiErro catch (e) {
      if (mounted) _mensagem(e.mensagem);
    } catch (_) {
      if (mounted) _mensagem("Não foi possível conectar ao servidor");
    } finally {
      if (mounted) setState(() => _carregando = false);
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
              "Abeias Burguer",
              style: TextStyle(
                fontSize: 26.sp,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              "Faça já seu login",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),

            SizedBox(height: 35.h),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe o email';
                return null;
              },
            ),

            SizedBox(height: 20.h),

            TextFormField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Senha",
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe a senha';
                return null;
              },
            ),

            SizedBox(height: 35.h),

            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: _carregando ? null : _entrar,
                child: _carregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text("Entrar", style: TextStyle(fontSize: 16.sp)),
              ),
            ),

            SizedBox(height: 15.h),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Cadastro()),
                );
              },
              child: Text(
                "Não tem conta? Cadastre-se",
                style: TextStyle(fontSize: 13.sp, color: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
