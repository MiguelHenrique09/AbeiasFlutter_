import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trailer_dm/visao/util/layout.dart';
import 'package:trailer_dm/visao/telas/login.dart';
import 'package:trailer_dm/modelo/Usuario.dart';
import 'package:trailer_dm/controle/LocalStorageService.dart';
import 'package:trailer_dm/controle/AutorizacaoController.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final LocalStorageService _storage = LocalStorageService();

  Usuario? _usuario;

  @override
  void initState() {
    super.initState();
    _verificarLoginECarregar();
  }

  Future<void> _verificarLoginECarregar() async {
    final logado = await AutorizacaoController.verificaAutorizacaoOffline();

    if (!logado) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
      return;
    }

    final usuario = await _storage.usuarioLogado();

    if (usuario != null && mounted) {
      setState(() {
        _usuario = usuario;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));

    return Layout(currentIndex: 3, body: _conteudo());
  }

  Widget _conteudo() {
    if (_usuario == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Column(
          children: [
            SizedBox(height: 25.h),
            Icon(Icons.person, size: 40.sp, color: Colors.orange),

            SizedBox(height: 10.h),
            const Text(
              "Seus dados",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 25.h),

            _campoPerfil(
              titulo: "Nome",
              valor: _usuario!.nome,
              icone: Icons.person_outline,
            ),

            SizedBox(height: 12.h),

            _campoPerfil(
              titulo: "Email",
              valor: _usuario!.email,
              icone: Icons.email_outlined,
            ),

            SizedBox(height: 30.h),

            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () async {
                  await AutorizacaoController.desgravaAutorizacao();

                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  }
                },
                child: Text(
                  "Sair da Conta",
                  style: TextStyle(fontSize: 14.sp, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoPerfil({
    required String titulo,
    required String valor,
    required IconData icone,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),

      child: Row(
        children: [
          Icon(icone, color: Colors.orange, size: 24.sp),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),

                SizedBox(height: 3.h),

                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
