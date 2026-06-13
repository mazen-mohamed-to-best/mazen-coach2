import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:to_best/core/constants/app_constants.dart';
import 'package:to_best/core/theme/app_theme.dart';
import 'package:to_best/l10n/app_localizations.dart';
import 'package:to_best/models/chat_message_model.dart';
import 'package:to_best/providers/app_providers.dart';
import 'package:uuid/uuid.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String roomId;
  final String roomTitle;
  const ChatRoomScreen({super.key, required this.roomId, required this.roomTitle});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _uuid = const Uuid();
  List<ChatMessageModel> _messages = [];
  ChatMessageModel? _pinned;
  bool _loading = true;
  bool _sending = false;
  Timer? _pollTimer;
  ChatMessageModel? _replyTo;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final chatSvc = ref.read(chatServiceProvider);
    final [msgs, pinned] = await Future.wait([
      chatSvc.fetchMessages(widget.roomId),
      chatSvc.getPinnedMessage(widget.roomId),
    ]);
    if (mounted) {
      setState(() {
        _messages = msgs as List<ChatMessageModel>;
        _pinned = pinned as ChatMessageModel?;
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _refresh() async {
    final chatSvc = ref.read(chatServiceProvider);
    final msgs = await chatSvc.fetchMessages(widget.roomId);
    if (mounted) setState(() => _messages = msgs);
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    if (user.chatBanned) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أنت محظور من الدردشة'), backgroundColor: AppColors.error));
      return;
    }
    if (user.chatMuteUntil != null && user.chatMuteUntil! > DateTime.now().millisecondsSinceEpoch) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أنت مكتوم مؤقتاً'), backgroundColor: AppColors.warning));
      return;
    }
    setState(() { _sending = true; _msgCtrl.clear(); });
    try {
      final msg = {
        'id': _uuid.v4(),
        'roomId': widget.roomId,
        'uid': user.uid,
        'senderName': user.displayName,
        if (user.pictureUrl != null) 'senderPicture': user.pictureUrl,
        'text': text,
        'ts': DateTime.now().millisecondsSinceEpoch,
        if (_replyTo != null) 'replyTo': {'id': _replyTo!.id, 'text': _replyTo!.text, 'senderName': _replyTo!.senderName},
      };
      await ref.read(chatServiceProvider).sendMessage(widget.roomId, msg);
      setState(() { _replyTo = null; });
      await _refresh();
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deleteMessage(ChatMessageModel msg) async {
    await ref.read(chatServiceProvider).deleteMessage(widget.roomId, msg.id);
    await _refresh();
  }

  Future<void> _pinMessage(ChatMessageModel msg) async {
    await ref.read(chatServiceProvider).pinMessage(widget.roomId, msg.toMap());
    await _loadMessages();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.roomTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${_messages.length} رسالة', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_outlined), onPressed: _refresh),
        ],
      ),
      body: Column(
        children: [
          if (_pinned != null) _buildPinnedBanner(_pinned!),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(child: Text(loc.noMessages, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textGrey)))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) => _buildMessage(ctx, _messages[i], user),
                      ),
          ),
          if (_replyTo != null) _buildReplyBanner(),
          _buildInputBar(loc, user),
        ],
      ),
    );
  }

  Widget _buildPinnedBanner(ChatMessageModel msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primary.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.push_pin_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(msg.text, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis)),
          GestureDetector(
            onTap: () async { await ref.read(chatServiceProvider).unpinMessage(widget.roomId); await _loadMessages(); },
            child: const Icon(Icons.close, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, ChatMessageModel msg, dynamic user) {
    final isMe = msg.uid == user?.uid;
    final isAdmin = user?.isAdmin ?? false;
    return GestureDetector(
      onLongPress: () => _showMessageOptions(context, msg, isMe || isAdmin),
      child: Padding(
        padding: EdgeInsets.only(left: isMe ? 60 : 8, right: isMe ? 8 : 60, bottom: 6),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(radius: 14, backgroundColor: AppColors.primary.withOpacity(0.15), child: Text(msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : '?', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Cairo'))),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe) Text(msg.senderName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w600)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.primary : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.deleted)
                          const Text('تم حذف هذه الرسالة', style: TextStyle(fontFamily: 'Cairo', fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textGrey))
                        else
                          Text(msg.text, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: isMe ? Colors.white : null)),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (msg.edited) const Text('معدّل', style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: Colors.white60)),
                            if (msg.edited) const SizedBox(width: 4),
                            Text(_formatTime(msg.timestamp), style: TextStyle(fontFamily: 'Cairo', fontSize: 9, color: isMe ? Colors.white60 : AppColors.textGrey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: const Duration(milliseconds: 10)).fadeIn();
  }

  Widget _buildReplyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Row(
        children: [
          const Icon(Icons.reply_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_replyTo!.senderName, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              Text(_replyTo!.text, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          )),
          GestureDetector(onTap: () => setState(() => _replyTo = null), child: const Icon(Icons.close, size: 16)),
        ],
      ),
    );
  }

  Widget _buildInputBar(AppLocalizations loc, dynamic user) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, bottom: MediaQuery.of(context).viewInsets.bottom + 8, top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(hintText: loc.typeMessage, isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), filled: true),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sending ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 44,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: _sending ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context, ChatMessageModel msg, bool canDelete) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.reply_rounded), title: const Text('رد', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); setState(() => _replyTo = msg); }),
            if (canDelete) ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.error), title: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: AppColors.error)), onTap: () { Navigator.pop(context); _deleteMessage(msg); }),
            if ((ref.read(currentUserProvider)?.isAdmin ?? false)) ListTile(leading: const Icon(Icons.push_pin_outlined), title: const Text('تثبيت', style: TextStyle(fontFamily: 'Cairo')), onTap: () { Navigator.pop(context); _pinMessage(msg); }),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
