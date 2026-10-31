import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../app/theme/app_colors.dart';

class VoiceSearchSheet extends StatefulWidget {
  final String title;
  final String hint;

  const VoiceSearchSheet({
    super.key,
    this.title = 'Voice Search',
    this.hint = 'Say a Pokémon name, move, or ability...',
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onResult,
    String title = 'Voice Search',
    String hint = 'Say a Pokémon name, move, or ability...',
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VoiceSearchSheet(title: title, hint: hint),
    );
    if (result != null && result.trim().isNotEmpty) {
      onResult(result.trim());
    }
  }

  @override
  State<VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends State<VoiceSearchSheet>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;
  bool _permissionDenied = false;
  bool _isPermanentlyDenied = false;
  String _recognizedWords = '';
  String? _errorMessage;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _autoSubmitTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkPermissionAndInit(autoStart: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSubmitTimer?.cancel();
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isListening && !_isInitialized) {
      // User may have granted microphone access in System Settings
      _checkPermissionAndInit(autoStart: true);
    }
  }

  Future<void> _checkPermissionAndInit({bool autoStart = true}) async {
    try {
      final status = await Permission.microphone.status;
      if (status.isGranted) {
        if (!mounted) return;
        setState(() {
          _permissionDenied = false;
          _isPermanentlyDenied = false;
          _errorMessage = null;
        });
        await _initSpeech(autoStart: autoStart);
      } else if (status.isPermanentlyDenied || status.isRestricted) {
        if (!mounted) return;
        setState(() {
          _permissionDenied = true;
          _isPermanentlyDenied = true;
          _isListening = false;
          _errorMessage =
              'Microphone access is disabled in settings. Tap below to enable it.';
        });
      } else {
        // Request microphone permission directly
        final reqResult = await Permission.microphone.request();
        if (!mounted) return;
        if (reqResult.isGranted) {
          setState(() {
            _permissionDenied = false;
            _isPermanentlyDenied = false;
            _errorMessage = null;
          });
          await _initSpeech(autoStart: autoStart);
        } else {
          setState(() {
            _permissionDenied = true;
            _isPermanentlyDenied = reqResult.isPermanentlyDenied;
            _isListening = false;
            _errorMessage = reqResult.isPermanentlyDenied
                ? 'Microphone access is disabled. Please enable it in Settings.'
                : 'Microphone permission was denied. Tap Allow to enable voice search.';
          });
        }
      }
    } catch (_) {
      // In case permission_handler is unavailable on platform, fallback to speech.initialize
      await _initSpeech(autoStart: autoStart);
    }
  }

  Future<void> _initSpeech({bool autoStart = true}) async {
    try {
      final available = await _speech.initialize(
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            if (_recognizedWords.isEmpty) {
              if (err.errorMsg == 'error_speech_timeout' ||
                  err.errorMsg == 'error_no_match') {
                _errorMessage = 'No speech detected. Tap mic to try again.';
              } else if (err.errorMsg == 'error_permission') {
                _permissionDenied = true;
                _errorMessage =
                    'Microphone permission is required for voice search.';
              } else if (err.errorMsg == 'error_network' ||
                  err.errorMsg == 'error_network_timeout') {
                _errorMessage = 'Network error. Please check your connection.';
              } else {
                _errorMessage = err.errorMsg.isNotEmpty
                    ? err.errorMsg
                    : 'Speech recognition error. Tap mic to retry.';
              }
            }
          });
        },
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'notListening' || status == 'done') {
            setState(() => _isListening = false);
            if (_recognizedWords.trim().isNotEmpty) {
              _scheduleAutoSubmit();
            }
          }
        },
        options: [
          SpeechToText.androidNoBluetooth,
          SpeechToText.androidIntentLookup,
        ],
      );

      if (!mounted) return;
      setState(() => _isInitialized = available);

      if (available) {
        if (autoStart) {
          _startListening();
        }
      } else {
        final micPerm = await Permission.microphone.isGranted;
        if (!mounted) return;
        setState(() {
          if (!micPerm) {
            _permissionDenied = true;
            _errorMessage =
                'Microphone permission is required. Tap Allow to proceed.';
          } else {
            _errorMessage =
                'Voice search service is unavailable on this device.';
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Microphone not accessible on this device.';
      });
    }
  }

  Future<void> _startListening() async {
    _autoSubmitTimer?.cancel();
    setState(() {
      _isListening = true;
      _errorMessage = null;
    });

    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _recognizedWords = result.recognizedWords;
          });

          if (result.finalResult && _recognizedWords.trim().isNotEmpty) {
            _scheduleAutoSubmit();
          }
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.search,
          cancelOnError: false,
          partialResults: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _errorMessage = 'Listening failed. Tap mic to retry.';
      });
    }
  }

  void _scheduleAutoSubmit() {
    _autoSubmitTimer?.cancel();
    _autoSubmitTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted && _recognizedWords.trim().isNotEmpty) {
        Navigator.of(context).pop(_recognizedWords.trim());
      }
    });
  }

  void _onMicTap() {
    if (_permissionDenied) {
      if (_isPermanentlyDenied) {
        openAppSettings();
      } else {
        _checkPermissionAndInit(autoStart: true);
      }
      return;
    }

    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      if (_recognizedWords.trim().isNotEmpty) {
        Navigator.of(context).pop(_recognizedWords.trim());
      }
    } else {
      if (_isInitialized) {
        _startListening();
      } else {
        _checkPermissionAndInit(autoStart: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 28 + bottomPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Hint or Listening Subtext
          Text(
            _isListening
                ? 'Listening now...'
                : (_errorMessage != null
                    ? _errorMessage!
                    : (_recognizedWords.isNotEmpty
                        ? 'Tap Search or speak again'
                        : widget.hint)),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: _isListening ? FontWeight.w700 : FontWeight.w500,
              color: _errorMessage != null
                  ? (_permissionDenied ? Colors.amber.shade800 : Colors.redAccent)
                  : (_isListening
                      ? AppColors.primary
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
            ),
          ),
          const SizedBox(height: 28),

          // Animated Pulsing Mic Button
          GestureDetector(
            onTap: _onMicTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isListening)
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.22),
                      ),
                    ),
                  ),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? AppColors.primary
                        : (_permissionDenied
                            ? Colors.amber.shade700
                            : (isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200)),
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening
                                ? AppColors.primary
                                : (_permissionDenied
                                    ? Colors.amber.shade700
                                    : Colors.black))
                            .withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? LucideIcons.mic : LucideIcons.micOff,
                    color: (_isListening || _permissionDenied)
                        ? Colors.white
                        : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                    size: 32,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action button if permission is denied
          if (_permissionDenied) ...[
            ElevatedButton.icon(
              onPressed: () {
                if (_isPermanentlyDenied) {
                  openAppSettings();
                } else {
                  _checkPermissionAndInit(autoStart: true);
                }
              },
              icon: Icon(
                _isPermanentlyDenied ? Icons.settings : Icons.mic,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                _isPermanentlyDenied ? 'Open Settings' : 'Allow Microphone',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Live Transcription Display Box
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isListening
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : Theme.of(context).dividerColor,
                width: 1.2,
              ),
            ),
            child: Text(
              _recognizedWords.isNotEmpty
                  ? _recognizedWords
                  : (_isListening
                      ? '...'
                      : (_permissionDenied
                          ? 'Permission needed to start voice input'
                          : 'Say a keyword...')),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: _recognizedWords.isNotEmpty
                    ? FontWeight.w700
                    : FontWeight.w400,
                color: _recognizedWords.isNotEmpty
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bottom Action Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              if (_recognizedWords.trim().isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_recognizedWords.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
