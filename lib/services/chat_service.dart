import 'package:to_best/core/constants/api_actions.dart';
import 'package:to_best/core/local_db/database_helper.dart';
import 'package:to_best/core/network/api_service.dart';
import 'package:to_best/models/chat_message_model.dart';

class ChatService {
  final ApiService _api;
  final DatabaseHelper _db;

  ChatService(this._api, this._db);

  Future<List<ChatMessageModel>> fetchMessages(String roomId, {int? since}) async {
    final res = await _api.call({
      'action': ApiActions.fetchMsgs,
      'roomId': roomId,
      if (since != null) 'since': since,
    });
    if (res?['ok'] != true) {
      // fallback to cached
      final cached = await _db.getCachedMessages(roomId);
      return cached.map(ChatMessageModel.fromMap).toList();
    }
    final msgs = (res!['messages'] as List? ?? [])
        .map((m) => ChatMessageModel.fromMap(m as Map<String, dynamic>))
        .toList();
    // Cache messages
    await _db.cacheMessages(roomId, msgs.map((m) => m.toMap()).toList());
    return msgs;
  }

  Future<List<ChatMessageModel>> getCachedMessages(String roomId) async {
    final cached = await _db.getCachedMessages(roomId);
    return cached.map(ChatMessageModel.fromMap).toList();
  }

  Future<bool> sendMessage(String roomId, Map<String, dynamic> msg) async {
    final res = await _api.call({'action': ApiActions.sendMsg, 'roomId': roomId, 'msg': msg});
    return res?['ok'] == true;
  }

  Future<bool> sendFileMessage(String roomId, Map<String, dynamic> msg) async {
    final res = await _api.call({'action': ApiActions.sendFileMsg, 'roomId': roomId, 'msg': msg});
    return res?['ok'] == true;
  }

  Future<bool> deleteMessage(String roomId, String msgId) async {
    final res = await _api.call({'action': ApiActions.deleteMsg, 'roomId': roomId, 'msgId': msgId});
    if (res?['ok'] == true) {
      await _db.deleteMessage(roomId, msgId);
    }
    return res?['ok'] == true;
  }

  Future<bool> editMessage(String roomId, String msgId, String newText) async {
    final res = await _api.call({'action': ApiActions.editMsg, 'roomId': roomId, 'msgId': msgId, 'newText': newText});
    return res?['ok'] == true;
  }

  Future<bool> pinMessage(String roomId, Map<String, dynamic> msg) async {
    final res = await _api.call({'action': ApiActions.pinMsg, 'roomId': roomId, 'msg': msg});
    return res?['ok'] == true;
  }

  Future<bool> unpinMessage(String roomId) async {
    final res = await _api.call({'action': ApiActions.unpinMsg, 'roomId': roomId});
    return res?['ok'] == true;
  }

  Future<ChatMessageModel?> getPinnedMessage(String roomId) async {
    final res = await _api.call({'action': ApiActions.getPinned, 'roomId': roomId});
    if (res?['ok'] != true || res?['pinned'] == null) return null;
    return ChatMessageModel.fromMap(res!['pinned'] as Map<String, dynamic>);
  }
}
