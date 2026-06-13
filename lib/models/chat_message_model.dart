class ChatMessageModel {
  final String id;
  final String roomId;
  final String uid;
  final String senderName;
  final String? senderPicture;
  final String text;
  final String? fileUrl;
  final String? fileType;
  final DateTime timestamp;
  final bool deleted;
  final bool edited;
  final bool isPinned;

  const ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.uid,
    required this.senderName,
    this.senderPicture,
    required this.text,
    this.fileUrl,
    this.fileType,
    required this.timestamp,
    this.deleted = false,
    this.edited = false,
    this.isPinned = false,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id']?.toString() ?? map['ts']?.toString() ?? '',
      roomId: map['roomId']?.toString() ?? '',
      uid: map['uid']?.toString() ?? '',
      senderName: map['senderName']?.toString() ?? map['name']?.toString() ?? '',
      senderPicture: map['senderPicture']?.toString() ?? map['picture']?.toString(),
      text: map['text']?.toString() ?? '',
      fileUrl: map['fileUrl']?.toString(),
      fileType: map['fileType']?.toString(),
      timestamp: map['ts'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['ts'] as num).toInt())
          : DateTime.now(),
      deleted: map['deleted'] == true,
      edited: map['edited'] == true,
      isPinned: map['pinned'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'roomId': roomId,
        'uid': uid,
        'senderName': senderName,
        if (senderPicture != null) 'senderPicture': senderPicture,
        'text': text,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (fileType != null) 'fileType': fileType,
        'ts': timestamp.millisecondsSinceEpoch,
        'deleted': deleted,
        'edited': edited,
        'pinned': isPinned,
      };

  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  bool get isImage => fileType == 'image';
}
