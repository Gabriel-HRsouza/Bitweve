class PostComment {
  final String author;
  final String? npcId;
  final String text;
  final int mood; // −1 negativo · 0 neutro · 1 positivo
  String? reply;

  PostComment({required this.author, this.npcId, required this.text, this.mood = 1, this.reply});

  Map<String, dynamic> toJson() => {'author': author, 'npcId': npcId, 'text': text, 'mood': mood, 'reply': reply};

  factory PostComment.fromJson(Map<String, dynamic> j) => PostComment(
        author: j['author'] as String? ?? '',
        npcId: j['npcId'] as String?,
        text: j['text'] as String? ?? '',
        mood: j['mood'] as int? ?? 1,
        reply: j['reply'] as String?,
      );
}

class SocialPost {
  final String id;
  final String category;
  final String imageKey;
  final String caption;
  final int age;
  final int year;
  int likes;
  int shares;
  final List<PostComment> comments;
  bool viral;
  bool controversy;
  int followersGained;

  SocialPost({
    required this.id,
    required this.category,
    required this.imageKey,
    required this.caption,
    required this.age,
    required this.year,
    this.likes = 0,
    this.shares = 0,
    List<PostComment>? comments,
    this.viral = false,
    this.controversy = false,
    this.followersGained = 0,
  }) : comments = comments ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'imageKey': imageKey,
        'caption': caption,
        'age': age,
        'year': year,
        'likes': likes,
        'shares': shares,
        'comments': comments.map((e) => e.toJson()).toList(),
        'viral': viral,
        'controversy': controversy,
        'followersGained': followersGained,
      };

  factory SocialPost.fromJson(Map<String, dynamic> j) => SocialPost(
        id: j['id'] as String,
        category: j['category'] as String? ?? 'photos',
        imageKey: j['imageKey'] as String? ?? 'photos_0',
        caption: j['caption'] as String? ?? '',
        age: j['age'] as int? ?? 0,
        year: j['year'] as int? ?? 2000,
        likes: j['likes'] as int? ?? 0,
        shares: j['shares'] as int? ?? 0,
        comments: (j['comments'] as List?)?.map((e) => PostComment.fromJson((e as Map).cast<String, dynamic>())).toList(),
        viral: j['viral'] as bool? ?? false,
        controversy: j['controversy'] as bool? ?? false,
        followersGained: j['followersGained'] as int? ?? 0,
      );
}

class DirectMessage {
  final String id;
  final String from;
  final String? npcId;
  final String text;
  final int age;
  final String kind; // fan | friend | brand | hater | romance
  bool read;
  String? reply;

  DirectMessage({
    required this.id,
    required this.from,
    this.npcId,
    required this.text,
    required this.age,
    this.kind = 'fan',
    this.read = false,
    this.reply,
  });

  Map<String, dynamic> toJson() => {
        'id': id, 'from': from, 'npcId': npcId, 'text': text, 'age': age, 'kind': kind, 'read': read, 'reply': reply,
      };

  factory DirectMessage.fromJson(Map<String, dynamic> j) => DirectMessage(
        id: j['id'] as String,
        from: j['from'] as String? ?? '',
        npcId: j['npcId'] as String?,
        text: j['text'] as String? ?? '',
        age: j['age'] as int? ?? 0,
        kind: j['kind'] as String? ?? 'fan',
        read: j['read'] as bool? ?? false,
        reply: j['reply'] as String?,
      );
}

/// Estado da rede social "Pulso".
class SocialState {
  String handle;
  bool hasAccount;
  bool verified;
  int totalLikes;
  int socialRep; // reputação online 0..100
  final List<SocialPost> posts;
  final List<DirectMessage> inbox;
  final List<String> likedFeed; // ids de posts de NPCs curtidos
  final List<String> commentedFeed;

  SocialState({
    this.handle = '',
    this.hasAccount = false,
    this.verified = false,
    this.totalLikes = 0,
    this.socialRep = 50,
    List<SocialPost>? posts,
    List<DirectMessage>? inbox,
    List<String>? likedFeed,
    List<String>? commentedFeed,
  })  : posts = posts ?? [],
        inbox = inbox ?? [],
        likedFeed = likedFeed ?? [],
        commentedFeed = commentedFeed ?? [];

  int get unread => inbox.where((m) => !m.read).length;

  Map<String, dynamic> toJson() => {
        'handle': handle,
        'hasAccount': hasAccount,
        'verified': verified,
        'totalLikes': totalLikes,
        'socialRep': socialRep,
        'posts': posts.map((e) => e.toJson()).toList(),
        'inbox': inbox.map((e) => e.toJson()).toList(),
        'likedFeed': likedFeed,
        'commentedFeed': commentedFeed,
      };

  factory SocialState.fromJson(Map<String, dynamic> j) => SocialState(
        handle: j['handle'] as String? ?? '',
        hasAccount: j['hasAccount'] as bool? ?? false,
        verified: j['verified'] as bool? ?? false,
        totalLikes: j['totalLikes'] as int? ?? 0,
        socialRep: j['socialRep'] as int? ?? 50,
        posts: (j['posts'] as List?)?.map((e) => SocialPost.fromJson((e as Map).cast<String, dynamic>())).toList(),
        inbox: (j['inbox'] as List?)?.map((e) => DirectMessage.fromJson((e as Map).cast<String, dynamic>())).toList(),
        likedFeed: (j['likedFeed'] as List?)?.cast<String>().toList(),
        commentedFeed: (j['commentedFeed'] as List?)?.cast<String>().toList(),
      );
}
