import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:trailer_dm/controle/AutorizacaoController.dart';
import 'package:trailer_dm/visao/util/layout.dart';
import 'package:trailer_dm/visao/telas/principal.dart';

const String baseUrl = 'https://abeias.wasmer.app';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late final WebViewController _controller;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0E1240))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _carregando = true);
          },
          onNavigationRequest: (request) {
            final uri = Uri.parse(request.url);
            if (uri.path == '/app/token-ok') {
              _finalizar(uri.queryParameters);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _carregando = false);
            final path = Uri.parse(url).path;
            const ficar = [
              '/pages/usuarioLogin',
              '/pages/usuarioCadastro',
              '/app/token',
              '/app/token-ok',
            ];
            if (!ficar.contains(path)) {
              _controller.loadRequest(Uri.parse('$baseUrl/app/token'));
            }
          },
        ),
      );
    _abrirLogin();
  }

  Future<void> _abrirLogin() async {
    final ua = await _controller.getUserAgent();
    await _controller.setUserAgent('$ua AbeiasApp');
    await WebViewCookieManager().clearCookies();
    await _controller.loadRequest(Uri.parse('$baseUrl/pages/usuarioLogin'));
  }

  Future<void> _finalizar(Map<String, String> dados) async {
    final token = dados['token'];
    if (token == null) return;

    await AutorizacaoController.salvarSessaoWeb(
      token: token,
      nome: dados['nome'] ?? '',
      email: dados['email'] ?? '',
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Principal()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      currentIndex: 3,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_carregando)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFFEA116)),
            ),
        ],
      ),
    );
  }
}
