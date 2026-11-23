import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const navy = Color(0xff1b237f);
const ink = Color(0xff121d59);
const muted = Color(0xff596b90);
const mist = Color(0xfff5f7ff);
const line = Color(0xffe1e5f2);
const intentKey = 'eats.auth.intent.v1';
final _client = Supabase.instance.client;

String? authRedirectError(Uri uri) {
  final params = uri.queryParameters;
  final fragment = uri.fragment.startsWith('?')
      ? uri.fragment.substring(1)
      : uri.fragment;
  final fields = fragment.startsWith('error')
      ? {...params, ...Uri.splitQueryString(fragment)}
      : params;
  final code = fields['error_code'] ?? fields['error'];
  final detail = fields['error_description'];
  if (code == null && detail == null) return null;
  final label = code == null
      ? 'Autentikasi gagal'
      : 'Autentikasi gagal ($code)';
  return detail == null || detail.isEmpty ? '$label.' : '$label. $detail';
}

enum EatsRole {
  pembeli(
    'buyer',
    'Pembeli',
    'Pesan makanan favoritmu',
    'Masuk untuk mulai pesan makanan favoritmu.',
    Icons.restaurant_rounded,
  ),
  penjual(
    'seller',
    'Penjual',
    'Kelola warungmu di sini',
    'Kelola warungmu dan layani pelanggan.',
    Icons.storefront_rounded,
  ),
  kurir(
    'courier',
    'Kurir',
    'Antar pesanan, raih penghasilan',
    'Siap antar pesanan hari ini?',
    Icons.two_wheeler_rounded,
  );

  const EatsRole(
    this.dbValue,
    this.title,
    this.caption,
    this.welcome,
    this.icon,
  );
  final String dbValue, title, caption, welcome;
  final IconData icon;
}

class EatsAuthApp extends StatelessWidget {
  const EatsAuthApp({super.key, this.redirectError});
  final String? redirectError;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'eaTS',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Plus Jakarta Sans',
      colorScheme: ColorScheme.fromSeed(seedColor: navy, primary: navy),
      scaffoldBackgroundColor: mist,
    ),
    home: EatsAuthGate(redirectError: redirectError),
  );
}

class EatsAuthGate extends StatefulWidget {
  const EatsAuthGate({super.key, this.redirectError});
  final String? redirectError;
  @override
  State<EatsAuthGate> createState() => _GateState();
}

class _GateState extends State<EatsAuthGate> {
  late final StreamSubscription<AuthState> sub;
  User? user = _client.auth.currentUser;
  EatsRole? role;
  bool authPage = false, signup = false, busy = false;
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool recovering = false, showPassword = false;
  String? message;
  String? confirmation;

  String get returnTo => kIsWeb
      ? Uri.base.toString().split(RegExp(r'[?#]')).first
      : 'id.eats.app://login-callback/';

  @override
  void initState() {
    super.initState();
    message = widget.redirectError;
    sub = _client.auth.onAuthStateChange.listen(
      (event) {
        if (!mounted) return;
        setState(() {
          user = event.session?.user;
          if (event.event == AuthChangeEvent.passwordRecovery) {
            recovering = true;
            showPassword = false;
            password.clear();
            message = null;
          }
          if (event.event == AuthChangeEvent.signedOut) {
            role = null;
            authPage = signup = recovering = false;
            password.clear();
          }
          busy = false;
        });
      },
      onError: (Object error) {
        if (mounted)
          setState(() {
            message ??= 'Proses autentikasi terhenti. Coba lagi.';
            busy = false;
          });
      },
    );
  }

  @override
  void dispose() {
    sub.cancel();
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> startGoogle() async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await SharedPreferencesAsync().setString(
        intentKey,
        '${role!.name}:${signup ? 'signup' : 'login'}',
      );
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: returnTo,
        queryParams: {'prompt': 'select_account'},
      );
      if (!launched) throw StateError('launch');
    } catch (_) {
      if (mounted)
        setState(
          () => message =
              'Google belum bisa dibuka. Periksa koneksi lalu coba lagi.',
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String? validateEmail(String? value) {
    final address = value?.trim() ?? '';
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(address)
        ? null
        : 'Masukkan alamat email yang valid.';
  }

  Future<void> authRequest(Future<void> Function() request) async {
    setState(() {
      busy = true;
      message = null;
      confirmation = null;
    });
    try {
      await request();
    } on AuthException catch (error) {
      if (mounted) setState(() => message = error.message);
    } catch (_) {
      if (mounted)
        setState(() => message = 'Terjadi gangguan koneksi. Coba lagi.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> submitEmail() async {
    if (!formKey.currentState!.validate()) return;
    final address = email.text.trim();
    final secret = password.text;
    await authRequest(() async {
      await SharedPreferencesAsync().setString(
        intentKey,
        '${role!.name}:${signup ? 'signup' : 'login'}',
      );
      if (signup) {
        final response = await _client.auth.signUp(
          email: address,
          password: secret,
          emailRedirectTo: returnTo,
          data: {'full_name': name.text.trim(), 'role': role!.dbValue},
        );
        if (mounted && response.session == null) {
          setState(() {
            signup = false;
            confirmation = 'Cek email untuk konfirmasi akun, lalu masuk.';
          });
        }
      } else {
        await _client.auth.signInWithPassword(email: address, password: secret);
      }
      if (mounted) password.clear();
    });
  }

  Future<void> requestReset() async {
    final error = validateEmail(email.text);
    if (error != null) {
      setState(
        () => message = 'Isi email akun untuk menerima link reset password.',
      );
      return;
    }
    await authRequest(() async {
      await SharedPreferencesAsync().remove(intentKey);
      await _client.auth.resetPasswordForEmail(
        email.text.trim(),
        redirectTo: returnTo,
      );
      if (mounted) {
        setState(
          () => confirmation =
              'Jika akun terdaftar, link reset akan dikirim ke email.',
        );
      }
    });
  }

  Future<void> savePassword() async {
    if (!formKey.currentState!.validate()) return;
    await authRequest(() async {
      await _client.auth.updateUser(UserAttributes(password: password.text));
      if (!mounted) return;
      password.clear();
      setState(() => recovering = false);
    });
  }

  Widget passwordField({required bool newPassword}) => _AuthField(
    label: newPassword && recovering ? 'PASSWORD BARU' : 'PASSWORD',
    hint: '••••••••',
    icon: Icons.lock_outline_rounded,
    controller: password,
    enabled: !busy,
    obscure: !showPassword,
    autofillHints: [
      newPassword ? AutofillHints.newPassword : AutofillHints.password,
    ],
    suffix: IconButton(
      tooltip: showPassword ? 'Sembunyikan password' : 'Tampilkan password',
      onPressed: busy
          ? null
          : () => setState(() => showPassword = !showPassword),
      icon: Icon(
        showPassword
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return 'Isi password.';
      if (newPassword && value.length < 6)
        return 'Password minimal 6 karakter.';
      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    final current = user;
    if (recovering && current != null) {
      return _Page(
        children: [
          const _Brand(),
          const SizedBox(height: 32),
          const _Heading('Buat password baru'),
          const SizedBox(height: 20),
          Form(key: formKey, child: passwordField(newPassword: true)),
          if (message != null) _Notice(message!),
          const SizedBox(height: 20),
          _Button(
            busy ? 'Menyimpan…' : 'Simpan password',
            busy ? null : savePassword,
          ),
        ],
      );
    }
    if (current != null)
      return _Account(key: ValueKey(current.id), user: current);
    if (!authPage)
      return _Page(
        children: [
          const SizedBox(height: 16),
          const _Brand(),
          const SizedBox(height: 38),
          const _Heading('Masuk sebagai'),
          const SizedBox(height: 6),
          const _Copy('Pilih peranmu untuk memulai pengalaman seru.'),
          const SizedBox(height: 22),
          for (final option in EatsRole.values)
            _RoleCard(
              role: option,
              selected: role == option,
              tap: () => setState(() {
                role = option;
                message = null;
              }),
            ),
          if (message != null) _Notice(message!),
          const SizedBox(height: 16),
          _Button(
            'Lanjutkan',
            () => setState(() {
              if (role == null) {
                message = 'Pilih satu peran dulu, ya.';
                return;
              }
              authPage = true;
              message = null;
            }),
          ),
        ],
      );
    final chosen = role!;
    return _Page(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              tooltip: 'Pilih peran',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: busy
                  ? null
                  : () => setState(() {
                      authPage = signup = showPassword = false;
                      password.clear();
                      message = null;
                      confirmation = null;
                    }),
            ),
            SizedBox.square(
              dimension: 48,
              child: Image.asset('assets/eats.png'),
            ),
            _Badge(chosen),
          ],
        ),
        const SizedBox(height: 42),
        _Heading(signup ? 'Daftar akun eaTS' : 'Welcome Back! 👋', large: true),
        const SizedBox(height: 10),
        _Copy(
          signup
              ? 'Buat akun ${chosen.title.toLowerCase()} untuk mulai menggunakan eaTS.'
              : chosen.welcome,
        ),
        const SizedBox(height: 32),
        AutofillGroup(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (signup) ...[
                  _AuthField(
                    label: 'NAMA LENGKAP',
                    hint: 'Nama lengkap kamu',
                    icon: Icons.person_outline_rounded,
                    controller: name,
                    enabled: !busy,
                    autofillHints: const [AutofillHints.name],
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Isi nama lengkap.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                ],
                _AuthField(
                  label: chosen == EatsRole.penjual ? 'EMAIL BISNIS' : 'EMAIL',
                  hint: 'nama@email.com',
                  icon: Icons.mail_outline_rounded,
                  controller: email,
                  enabled: !busy,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: validateEmail,
                ),
                const SizedBox(height: 20),
                passwordField(newPassword: signup),
              ],
            ),
          ),
        ),
        if (!signup)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: busy ? null : requestReset,
              child: const Text('Lupa password?'),
            ),
          )
        else
          const SizedBox(height: 20),
        if (message != null) _Notice(message!),
        if (confirmation != null) ...[
          _Copy(confirmation!),
          const SizedBox(height: 12),
        ],
        _Button(
          busy ? 'Memproses…' : (signup ? 'Daftar' : 'Masuk'),
          busy ? null : submitEmail,
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(child: Divider(color: line)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: _Copy('ATAU'),
            ),
            Expanded(child: Divider(color: line)),
          ],
        ),
        const SizedBox(height: 20),
        _Button(
          signup ? 'Daftar dengan Google' : 'Masuk dengan Google',
          busy ? null : startGoogle,
          google: true,
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Copy(signup ? 'Sudah punya akun?' : 'Belum punya akun?'),
            TextButton(
              onPressed: busy
                  ? null
                  : () => setState(() {
                      signup = !signup;
                      showPassword = false;
                      password.clear();
                      formKey.currentState?.reset();
                      message = null;
                      confirmation = null;
                    }),
              child: Text(signup ? 'Masuk' : 'Daftar'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.enabled,
    required this.autofillHints,
    required this.validator,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
  });

  final String label, hint;
  final IconData icon;
  final TextEditingController controller;
  final bool enabled, obscure;
  final Iterable<String> autofillHints;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: navy,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscure,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: line),
          ),
        ),
      ),
    ],
  );
}

class _Account extends StatefulWidget {
  const _Account({super.key, required this.user});
  final User user;
  @override
  State<_Account> createState() => _AccountState();
}

class _AccountState extends State<_Account> {
  EatsRole? stored, chosen;
  bool busy = true, failed = false, mismatch = false, loginIntent = false;
  String? message;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      failed = false;
      message = null;
    });
    try {
      final prefs = SharedPreferencesAsync();
      final intent = (await prefs.getString(intentKey))?.split(':');
      final selected = EatsRole.values
          .where((r) => r.name == intent?.first)
          .firstOrNull;
      final row = await _client
          .from('profiles')
          .select('role, google_role_pending')
          .eq('id', widget.user.id)
          .single();
      final saved = row['google_role_pending'] == true
          ? null
          : EatsRole.values.firstWhere((role) => role.dbValue == row['role']);
      if (saved != null) await prefs.remove(intentKey);
      if (!mounted) return;
      setState(() {
        chosen = selected;
        stored = saved;
        mismatch = selected != null && saved != null && selected != saved;
        loginIntent = intent?.last == 'login';
      });
    } catch (_) {
      if (mounted)
        setState(() {
          failed = true;
          message = 'Profil belum bisa dimuat. Periksa koneksi dan konfigurasi database.';
        });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> register() async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await _client.rpc(
        'eats_confirm_google_role',
        params: {'selected_role': chosen!.dbValue},
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          busy = false;
          message = 'Peran belum bisa dikonfirmasi. Coba lagi.';
        });
      }
      return;
    }
    if (mounted) await load();
  }

  Future<void> leave() async {
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await SharedPreferencesAsync().remove(intentKey);
      await _client.auth.signOut(scope: SignOutScope.local);
    } catch (_) {
      if (mounted)
        setState(() {
          busy = false;
          message = 'Gagal keluar. Coba lagi.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (busy)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final accountRole = stored;
    return _Page(
      children: [
        const _Brand(),
        const SizedBox(height: 32),
        if (failed) ...[
          _Notice(message!),
          _Button('Coba lagi', load),
        ] else if (accountRole == null) ...[
          const _Heading('Selesaikan pendaftaran'),
          const SizedBox(height: 8),
          _Copy(
            loginIntent
                ? 'Akun ini belum mengonfirmasi peran eaTS. Pilih peran untuk melanjutkan.'
                : 'Konfirmasi peran untuk akun Google yang kamu pilih.',
          ),
          const SizedBox(height: 8),
          _Copy(widget.user.email ?? ''),
          const SizedBox(height: 20),
          for (final role in EatsRole.values)
            _RoleCard(
              role: role,
              selected: role == chosen,
              tap: () => setState(() => chosen = role),
            ),
          if (message != null) _Notice(message!),
          _Button('Konfirmasi peran', chosen == null ? null : register),
        ] else ...[
          _Badge(accountRole),
          const SizedBox(height: 20),
          _Heading(
            mismatch
                ? 'Periksa peran akun'
                : 'Halo, ${widget.user.userMetadata?['given_name'] ?? accountRole.title}!',
          ),
          const SizedBox(height: 10),
          _Copy(
            mismatch
                ? 'Akun ini terdaftar sebagai ${accountRole.title}. Lanjutkan dengan peran tersebut atau gunakan akun Google lain.'
                : 'Kamu sudah masuk sebagai ${accountRole.title}.',
          ),
          const SizedBox(height: 8),
          _Copy(widget.user.email ?? ''),
          const SizedBox(height: 24),
          _RoleArt(accountRole),
          if (mismatch)
            _Button(
              'Lanjut sebagai ${accountRole.title}',
              () => setState(() => mismatch = false),
            ),
          if (message != null) _Notice(message!),
        ],
        const SizedBox(height: 12),
        TextButton(
          onPressed: leave,
          child: Text(
            mismatch || stored == null ? 'Gunakan akun lain' : 'Keluar',
          ),
        ),
      ],
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Image.asset('assets/eats.png', height: 100, semanticLabel: 'Logo eaTS'),
      const Text(
        'eaTS',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: navy,
        ),
      ),
      const SizedBox(height: 5),
      const _Copy('Jajan Cepat, Kuliah Tepat!'),
    ],
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, {this.large = false});
  final String text;
  final bool large;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: ink,
      fontSize: large ? 29 : 22,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.9,
    ),
  );
}

class _Copy extends StatelessWidget {
  const _Copy(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 14, height: 1.5, color: muted),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.role);
  final EatsRole role;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(role.icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              role.title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.selected,
    required this.tap,
  });
  final EatsRole role;
  final bool selected;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: selected ? 3 : 1,
        shadowColor: const Color(0x30131a56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? navy : line,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: tap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    color: selected ? navy : const Color(0xffedeef8),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    role.icon,
                    color: selected ? Colors.white : navy,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.title,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      _Copy(role.caption),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? navy : line,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _RoleArt extends StatelessWidget {
  const _RoleArt(this.role);
  final EatsRole role;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: 170,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xffe5e9ff), Color(0xfff0f6ff)],
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final size in [230.0, 166.0, 102.0])
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          Transform.rotate(
            angle: -.09,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(role.icon, size: 44, color: Colors.white),
            ),
          ),
          const Positioned(
            top: 22,
            right: 40,
            child: Icon(Icons.auto_awesome, color: Color(0xffd1a555), size: 23),
          ),
          const Positioned(
            bottom: 32,
            left: 46,
            child: Icon(Icons.star_rounded, color: Color(0xffafbce6), size: 19),
          ),
        ],
      ),
    ),
  );
}

class _Button extends StatelessWidget {
  const _Button(this.text, this.action, {this.google = false});
  final String text;
  final VoidCallback? action;
  final bool google;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: action,
    style: FilledButton.styleFrom(
      foregroundColor: google ? ink : Colors.white,
      backgroundColor: google ? Colors.white : navy,
      side: google ? const BorderSide(color: line) : null,
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (google) ...[
          Image.asset('assets/google.png', width: 22, height: 22),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xff933c19), height: 1.4),
      ),
    ),
  );
}
