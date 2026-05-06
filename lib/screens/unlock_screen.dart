import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class UnlockScreen extends StatefulWidget {
  const UnlockScreen({super.key});

  @override
  State<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends State<UnlockScreen> {
  String _pin = '';
  bool _isSettingUp = false;
  String _setupPin = '';
  bool _isLoading = false;
  bool _showAuthOptions = false;

  @override
  void initState() {
    super.initState();
    _checkPinSetup();
  }

  Future<void> _checkPinSetup() async {
    setState(() => _isLoading = true);

    try {
      final isPinSetup = await AuthService.instance.isPinSetup();
      final isAuthenticated = AuthService.instance.isAuthenticated;

      setState(() {
        _isSettingUp = !isPinSetup;
        _showAuthOptions = !isAuthenticated;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Check PIN setup error: $e');
      setState(() {
        _isSettingUp = true;
        _isLoading = false;
      });
    }
  }

  void _onKeyPress(String key) {
    if (_pin.length < 4) {
      setState(() {
        _pin += key;
      });

      // Haptic feedback
      HapticFeedback.lightImpact();

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _verifyPin() async {
    if (_isSettingUp) {
      await _handlePinSetup();
    } else {
      await _handlePinVerification();
    }
  }

  Future<void> _handlePinSetup() async {
    if (_setupPin.isEmpty) {
      setState(() {
        _setupPin = _pin;
        _pin = '';
      });
      _showSnackBar('Confirm your PIN');
    } else {
      if (_setupPin == _pin) {
        try {
          final success = await AuthService.instance.setupPin(_pin);
          if (success) {
            if (_showAuthOptions) {
              _showAuthenticationDialog();
            } else {
              if (mounted) {
                context.go('/chat');
              }
            }
          } else {
            _showSnackBar('Failed to setup PIN');
            _resetPinSetup();
          }
        } catch (e) {
          _showSnackBar('Error setting up PIN: $e');
          _resetPinSetup();
        }
      } else {
        _showSnackBar('PINs do not match. Try again.');
        _resetPinSetup();
      }
    }
  }

  Future<void> _handlePinVerification() async {
    try {
      final isValid = await AuthService.instance.verifyPin(_pin);
      if (isValid) {
        // Update last active time
        await AuthService.instance.updateLastActiveTime();

        if (_showAuthOptions) {
          _showAuthenticationDialog();
        } else {
          if (mounted) {
            context.go('/chat');
          }
        }
      } else {
        setState(() => _pin = '');
        _showSnackBar('Incorrect PIN');
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      _showSnackBar('Error verifying PIN: $e');
      setState(() => _pin = '');
    }
  }

  void _resetPinSetup() {
    setState(() {
      _setupPin = '';
      _pin = '';
    });
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showAuthenticationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sign In Required'),
        content: const Text(
          'You need to sign in with your Chatsusa account to access the secure chat system.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSignInDialog();
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showSignInDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Sign In to Chatsusa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your Chatsusa email',
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
                obscureText: true,
                enabled: !isLoading,
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.pop(context);
                      context.go('/');
                    },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        _showSnackBar('Please enter both email and password');
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      final navigator = Navigator.of(context);
                      final router = GoRouter.of(context);

                      try {
                        final result =
                            await AuthService.instance.signInWithEmail(
                          email: email,
                          password: password,
                        );

                        if (result.isSuccess) {
                          navigator.pop();
                          if (mounted) {
                            router.go('/chat');
                          }
                        } else {
                          _showSnackBar('Sign in failed: ${result.error}');
                        }
                      } catch (e) {
                        _showSnackBar('Sign in error: $e');
                      } finally {
                        setDialogState(() => isLoading = false);
                      }
                    },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _isSettingUp
                  ? (_setupPin.isEmpty ? 'Set a 4-digit PIN' : 'Confirm PIN')
                  : 'Enter PIN',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _isSettingUp
                  ? 'This PIN will secure access to your chat'
                  : 'Enter your PIN to access secure chat',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Demo hint (remove in production)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Text(
                '💡 Demo: Use the small unlock button on the home screen to skip PIN setup',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // PIN dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _pin.length
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                );
              }),
            ),
            const SizedBox(height: 64),

            // PIN pad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                children: [
                  for (int i = 0; i < 3; i++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int j = 1; j <= 3; j++)
                          _buildDialButton('${i * 3 + j}'),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 80, height: 80),
                      _buildDialButton('0'),
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: IconButton(
                          onPressed: _onBackspace,
                          icon: const Icon(Icons.backspace_outlined),
                          iconSize: 28,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Additional options
            if (!_isSettingUp && !_showAuthOptions)
              TextButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset PIN'),
                      content: const Text(
                        'Are you sure you want to reset your PIN? This will also clear your authentication.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await AuthService.instance.clearPin();
                    await AuthService.instance.signOut();
                    _checkPinSetup();
                  }
                },
                child: const Text('Reset PIN'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialButton(String digit) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 64,
      height: 64,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onKeyPress(digit),
          child: Center(
            child: Text(
              digit,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ),
    );
  }
}
