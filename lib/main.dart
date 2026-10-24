import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://lcaadbeaefmtmwjjztvr.supabase.co';
const supabaseKey = 'sb_publishable_4TvGhijPtPitDh4jkDuwrQ_8evN85gN';

// ألوان فري فاير
const cOrange = Color(0xFFFF6A00);
const cGold = Color(0xFFFFB800);
const cRed = Color(0xFFE5231B);
const cBg = Color(0xFF0B0B10);
const cCard = Color(0xFF16161F);

const bevel = BeveledRectangleBorder(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(16),
    bottomRight: Radius.circular(16),
  ),
);

SupabaseClient get sb => Supabase.instance.client;

String get myName {
  final meta = sb.auth.currentUser?.userMetadata ?? {};
  return (meta['username'] ?? 'لاعب').toString();
}

void toast(BuildContext c, String m) {
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(
    content: Text(m),
    behavior: SnackBarBehavior.floating,
    backgroundColor: cCard,
    shape: bevel,
  ));
}

String timeAgo(dynamic s) {
  final d = DateTime.tryParse('$s')?.toLocal();
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'الآن';
  if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} د';
  if (diff.inHours < 24) return 'قبل ${diff.inHours} س';
  return 'قبل ${diff.inDays} يوم';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ساحة فري فاير',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: cBg,
        colorScheme: const ColorScheme.dark(
          primary: cOrange,
          secondary: cGold,
          surface: cCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF120A04),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const AuthGate(),
    );
  }
}

// ---------------------------------------------------------------- الشعار

class LogoPainter extends CustomPainter {
  static const hexa = [
    [50, 2], [93, 26], [93, 74], [50, 98], [7, 74], [7, 26]
  ];
  static const flame = [
    [50, 6], [62, 26], [72, 44], [76, 62], [68, 80], [50, 92],
    [32, 80], [24, 62], [30, 46], [38, 56], [42, 36]
  ];
  static const inner = [
    [50, 40], [58, 56], [60, 70], [50, 82], [40, 70], [43, 56]
  ];

  Path _poly(List<List<int>> pts, Size s) {
    final p = Path();
    for (var i = 0; i < pts.length; i++) {
      final x = pts[i][0] * s.width / 100;
      final y = pts[i][1] * s.height / 100;
      if (i == 0) {
        p.moveTo(x, y);
      } else {
        p.lineTo(x, y);
      }
    }
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final hex = _poly(hexa, size);

    // توهج
    canvas.drawPath(
      hex,
      Paint()
        ..color = cOrange.withOpacity(0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.08),
    );
    canvas.drawPath(hex, Paint()..color = const Color(0xFF181822));
    canvas.drawPath(
      hex,
      Paint()
        ..color = cOrange
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.05
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      _poly(flame, size),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cGold, cOrange, cRed],
        ).createShader(rect),
    );
    canvas.drawPath(_poly(inner, size), Paint()..color = const Color(0xFFFFE08A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: LogoPainter()),
    );
  }
}

// ---------------------------------------------------------------- عناصر التصميم

class StripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = cOrange.withOpacity(0.05)
      ..strokeWidth = 1.2;
    for (double x = -size.height; x < size.width; x += 26) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FFBackground extends StatelessWidget {
  final Widget child;
  const FFBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF241104), cBg, Color(0xFF07070A)],
          stops: [0, 0.45, 1],
        ),
      ),
      child: CustomPaint(painter: StripesPainter(), child: child),
    );
  }
}

class GradText extends StatelessWidget {
  final String text;
  final double size;
  const GradText(this.text, {super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (r) => const LinearGradient(colors: [cGold, cOrange, cRed])
          .createShader(r),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: 1.5,
          color: Colors.white,
        ),
      ),
    );
  }
}

class FFButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool busy;
  const FFButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: const ShapeDecoration(
            shape: bevel,
            gradient: LinearGradient(colors: [cGold, cOrange]),
            shadows: [
              BoxShadow(color: Color(0x66FF6A00), blurRadius: 14, spreadRadius: 1)
            ],
          ),
          child: InkWell(
            onTap: busy ? null : onTap,
            customBorder: bevel,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (busy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  else if (icon != null)
                    Icon(icon, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration ffInput(String label, IconData icon) {
  OutlineInputBorder b(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: c, width: 1.3),
      );
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: cOrange),
    filled: true,
    fillColor: const Color(0xFF1B1B26),
    enabledBorder: b(cOrange.withOpacity(0.35)),
    focusedBorder: b(cOrange),
    border: b(cOrange),
  );
}

class Avatar extends StatelessWidget {
  final String name;
  final double r;
  const Avatar(this.name, {super.key, this.r = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: r * 2,
      height: r * 2,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [cGold, cRed]),
      ),
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w900, fontSize: r * 0.95),
      ),
    );
  }
}

// ---------------------------------------------------------------- الدخول

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: sb.auth.onAuthStateChange,
      builder: (context, _) {
        return sb.auth.currentSession == null
            ? const LoginPage()
            : const HomePage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool register = false;
  bool busy = false;
  bool hide = true;

  String _email(String u) => '${u.toLowerCase()}@freefire.app';

  String _err(String m) {
    final l = m.toLowerCase();
    if (l.contains('invalid login')) return 'اسم المستخدم أو كلمة المرور غير صحيحة';
    if (l.contains('already')) return 'هذا الاسم مستخدم، اختر اسماً آخر';
    if (l.contains('rate limit')) return 'محاولات كثيرة، انتظر قليلاً';
    return m;
  }

  Future<void> submit() async {
    final u = userCtrl.text.trim();
    final p = passCtrl.text;
    if (!RegExp(r'^[A-Za-z0-9_]{3,20}$').hasMatch(u)) {
      toast(context, 'اسم المستخدم: من 3 إلى 20 حرفاً إنجليزياً أو أرقاماً أو _');
      return;
    }
    if (p.length < 6) {
      toast(context, 'كلمة المرور 6 أحرف على الأقل');
      return;
    }
    setState(() => busy = true);
    try {
      if (register) {
        final res = await sb.auth
            .signUp(email: _email(u), password: p, data: {'username': u});
        if (res.session == null && mounted) {
          toast(context, 'عطّل Confirm email من إعدادات Supabase ثم سجّل الدخول');
        }
      } else {
        await sb.auth.signInWithPassword(email: _email(u), password: p);
      }
    } on AuthException catch (e) {
      if (mounted) toast(context, _err(e.message));
    } catch (e) {
      if (mounted) toast(context, 'خطأ: $e');
    }
    if (mounted) setState(() => busy = false);
  }

  Widget tab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: active ? cOrange : Colors.white12, width: 3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: active ? cGold : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FFBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Logo(size: 150),
                  const SizedBox(height: 14),
                  const GradText('FREE FIRE', size: 36),
                  const SizedBox(height: 4),
                  const Text(
                    'ساحة التحديات والصور',
                    style: TextStyle(color: Colors.white70, letterSpacing: 1),
                  ),
                  const SizedBox(height: 28),
                  Row(children: [
                    tab('دخول', !register, () => setState(() => register = false)),
                    tab('حساب جديد', register,
                        () => setState(() => register = true)),
                  ]),
                  const SizedBox(height: 20),
                  TextField(
                    controller: userCtrl,
                    textDirection: TextDirection.ltr,
                    decoration: ffInput('اسم المستخدم', Icons.person),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtrl,
                    obscureText: hide,
                    textDirection: TextDirection.ltr,
                    decoration: ffInput('كلمة المرور', Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(hide ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => hide = !hide),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FFButton(
                      label: register ? 'إنشاء الحساب' : 'دخول إلى الساحة',
                      icon: Icons.local_fire_department,
                      busy: busy,
                      onTap: busy ? null : submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- الرئيسية

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = sb
        .from('posts')
        .stream(primaryKey: ['id']).order('created_at', ascending: false);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: const Row(
          children: [
            Logo(size: 38),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GradText('FREE FIRE', size: 20),
                Text('ساحة التحديات',
                    style: TextStyle(fontSize: 11, color: Colors.white60)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout, color: cOrange),
            onPressed: () => sb.auth.signOut(),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [cRed, cOrange, cGold]),
            ),
            child: SizedBox(height: 3, width: double.infinity),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 200,
        child: FFButton(
          label: 'إرسال صورة',
          icon: Icons.add_a_photo,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddPostPage())),
        ),
      ),
      body: FFBackground(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(child: Text('خطأ: ${snap.error}'));
            }
            if (!snap.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: cOrange));
            }
            final posts = snap.data!;
            if (posts.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Logo(size: 110),
                    SizedBox(height: 14),
                    Text('الساحة فارغة... كن أول من يرسل تحدياً!',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 100),
              itemCount: posts.length,
              itemBuilder: (_, i) => PostCard(post: posts[i]),
            );
          },
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final sender = (post['sender_name'] ?? '').toString();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: ShapeDecoration(
        shape: BeveledRectangleBorder(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          side: BorderSide(color: cOrange.withOpacity(0.6), width: 1.4),
        ),
        color: cCard,
        shadows: [
          BoxShadow(color: cOrange.withOpacity(0.18), blurRadius: 16),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PostPage(post: post))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Row(
                children: [
                  Avatar(sender),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['title'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cGold.withOpacity(0.15),
                                border: Border.all(color: cGold.withOpacity(0.6)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'المرسل: $sender',
                                style: const TextStyle(
                                    color: cGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(timeAgo(post['created_at']),
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.local_fire_department, color: cOrange),
                ],
              ),
            ),
            Stack(
              children: [
                Image.network(
                  post['image_url'],
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  loadingBuilder: (c, w, p) => p == null
                      ? w
                      : const SizedBox(
                          height: 250,
                          child: Center(
                              child: CircularProgressIndicator(color: cOrange)),
                        ),
                  errorBuilder: (_, __, ___) => const SizedBox(
                      height: 250, child: Icon(Icons.broken_image)),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xDD000000), Colors.transparent],
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.chat_bubble, size: 16, color: cGold),
                        SizedBox(width: 6),
                        Text('التعليقات',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: cGold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- إرسال صورة

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final titleCtrl = TextEditingController();
  XFile? picked;
  bool busy = false;

  Future<void> pick() async {
    final f = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (f != null) setState(() => picked = f);
  }

  Future<void> send() async {
    if (picked == null || titleCtrl.text.trim().isEmpty) {
      toast(context, 'اختر صورة واكتب عنوان الرسالة');
      return;
    }
    setState(() => busy = true);
    try {
      final bytes = await picked!.readAsBytes();
      final uid = sb.auth.currentUser!.id;
      final path = '$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await sb.storage.from('images').uploadBinary(path, bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'));
      final url = sb.storage.from('images').getPublicUrl(path);
      await sb.from('posts').insert({
        'user_id': uid,
        'sender_name': myName,
        'title': titleCtrl.text.trim(),
        'image_url': url,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) toast(context, 'فشل الإرسال: $e');
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const GradText('إرسال صورة', size: 20)),
      body: FFBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: pick,
              child: Container(
                height: 260,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: cCard,
                  shape: BeveledRectangleBorder(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      bottomRight: Radius.circular(22),
                    ),
                    side: BorderSide(color: cOrange, width: 1.6),
                  ),
                ),
                child: picked == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 54, color: cOrange),
                            SizedBox(height: 8),
                            Text('اضغط لاختيار الصورة'),
                          ],
                        ),
                      )
                    : FutureBuilder(
                        future: picked!.readAsBytes(),
                        builder: (_, s) => s.hasData
                            ? Image.memory(s.data!,
                                fit: BoxFit.cover, width: double.infinity)
                            : const SizedBox(),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              decoration: ffInput('عنوان الرسالة (مثال: تحدي روم 1v1)',
                  Icons.local_fire_department),
            ),
            const SizedBox(height: 18),
            FFButton(
              label: 'إرسال إلى الساحة',
              icon: Icons.send,
              busy: busy,
              onTap: busy ? null : send,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- الصورة والتعليقات

class PostPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final ctrl = TextEditingController();

  Future<void> addComment() async {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    ctrl.clear();
    try {
      await sb.from('comments').insert({
        'post_id': widget.post['id'],
        'user_id': sb.auth.currentUser!.id,
        'sender_name': myName,
        'content': text,
      });
    } catch (e) {
      if (mounted) toast(context, 'فشل التعليق: $e');
    }
  }

  Future<void> deletePost() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cCard,
        title: const Text('حذف الصورة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف', style: TextStyle(color: cRed))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await sb.from('posts').delete().eq('id', widget.post['id']);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) toast(context, 'فشل الحذف: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final mine = p['user_id'] == sb.auth.currentUser?.id;
    final stream = sb
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', p['id'])
        .order('created_at', ascending: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(p['title'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          if (mine)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: cRed),
              onPressed: deletePost,
            ),
        ],
      ),
      body: FFBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Image.network(p['image_url'], fit: BoxFit.cover),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Avatar((p['sender_name'] ?? '').toString(), r: 16),
                        const SizedBox(width: 10),
                        Text('المرسل: ${p['sender_name'] ?? ''}',
                            style: const TextStyle(
                                color: cGold, fontWeight: FontWeight.w900)),
                        const Spacer(),
                        Text(timeAgo(p['created_at']),
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Divider(color: cOrange, height: 1),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: stream,
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                              child: CircularProgressIndicator(color: cOrange)),
                        );
                      }
                      final list = snap.data!;
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(28),
                          child: Center(
                              child: Text('لا توجد تعليقات... ابدأ التحدي!',
                                  style: TextStyle(color: Colors.white60))),
                        );
                      }
                      return Column(
                        children: list.map((c) {
                          final own = c['user_id'] == sb.auth.currentUser?.id;
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: own
                                  ? cOrange.withOpacity(0.16)
                                  : cCard,
                              border: const Border(
                                  right: BorderSide(color: cOrange, width: 3)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Avatar((c['sender_name'] ?? '').toString(),
                                    r: 14),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c['sender_name'] ?? '',
                                          style: const TextStyle(
                                              color: cGold,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Text(c['content'] ?? ''),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Container(
              color: const Color(0xFF120A04),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ctrl,
                          decoration: ffInput('اكتب تعليقاً...', Icons.edit),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [cGold, cOrange]),
                        ),
                        child: IconButton(
                          onPressed: addComment,
                          icon: const Icon(Icons.send, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
