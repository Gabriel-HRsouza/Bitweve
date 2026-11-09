class ChatLine {
  final bool mine;
  final String text;
  const ChatLine(this.mine, this.text);

  Map<String, dynamic> toJson() => {'m': mine, 't': text};
  factory ChatLine.fromJson(Map<String, dynamic> j) => ChatLine(j['m'] as bool? ?? false, j['t'] as String? ?? '');
}

/// Um match no app de namoro. Guarda os dados do perfil para virar NPC depois.
class DatingMatch {
  final String profileId;
  final String firstName;
  final String lastName;
  final String gender;
  final int age;
  final String avatarJson;
  final String bio;
  final int compatibility;
  int interest; // 0..100 interesse da outra pessoa
  bool blocked;
  bool unmatched;
  String? npcId; // quando vira pessoa da sua vida
  int dates;
  final List<ChatLine> chat;

  DatingMatch({
    required this.profileId,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.age,
    required this.avatarJson,
    required this.bio,
    required this.compatibility,
    this.interest = 50,
    this.blocked = false,
    this.unmatched = false,
    this.npcId,
    this.dates = 0,
    List<ChatLine>? chat,
  }) : chat = chat ?? [];

  bool get active => !blocked && !unmatched;

  Map<String, dynamic> toJson() => {
        'profileId': profileId,
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'age': age,
        'avatarJson': avatarJson,
        'bio': bio,
        'compatibility': compatibility,
        'interest': interest,
        'blocked': blocked,
        'unmatched': unmatched,
        'npcId': npcId,
        'dates': dates,
        'chat': chat.map((e) => e.toJson()).toList(),
      };

  factory DatingMatch.fromJson(Map<String, dynamic> j) => DatingMatch(
        profileId: j['profileId'] as String,
        firstName: j['firstName'] as String? ?? '',
        lastName: j['lastName'] as String? ?? '',
        gender: j['gender'] as String? ?? 'female',
        age: j['age'] as int? ?? 18,
        avatarJson: j['avatarJson'] as String? ?? '{}',
        bio: j['bio'] as String? ?? '',
        compatibility: j['compatibility'] as int? ?? 50,
        interest: j['interest'] as int? ?? 50,
        blocked: j['blocked'] as bool? ?? false,
        unmatched: j['unmatched'] as bool? ?? false,
        npcId: j['npcId'] as String?,
        dates: j['dates'] as int? ?? 0,
        chat: (j['chat'] as List?)?.map((e) => ChatLine.fromJson((e as Map).cast<String, dynamic>())).toList(),
      );
}

/// Estado do app de namoro "Faísca".
class DatingState {
  bool hasProfile;
  String bio;
  final List<String> interests;
  int minAge;
  int maxAge;
  String lookingFor; // serious | casual | friendship
  final List<String> swiped; // perfis já vistos (curtidos ou passados)
  final List<String> liked;
  final List<DatingMatch> matches;
  int superLikes;
  int rejections;

  DatingState({
    this.hasProfile = false,
    this.bio = '',
    List<String>? interests,
    this.minAge = 18,
    this.maxAge = 40,
    this.lookingFor = 'serious',
    List<String>? swiped,
    List<String>? liked,
    List<DatingMatch>? matches,
    this.superLikes = 1,
    this.rejections = 0,
  })  : interests = interests ?? [],
        swiped = swiped ?? [],
        liked = liked ?? [],
        matches = matches ?? [];

  Map<String, dynamic> toJson() => {
        'hasProfile': hasProfile,
        'bio': bio,
        'interests': interests,
        'minAge': minAge,
        'maxAge': maxAge,
        'lookingFor': lookingFor,
        'swiped': swiped.length > 400 ? swiped.sublist(swiped.length - 400) : swiped,
        'liked': liked.length > 200 ? liked.sublist(liked.length - 200) : liked,
        'matches': matches.map((e) => e.toJson()).toList(),
        'superLikes': superLikes,
        'rejections': rejections,
      };

  factory DatingState.fromJson(Map<String, dynamic> j) => DatingState(
        hasProfile: j['hasProfile'] as bool? ?? false,
        bio: j['bio'] as String? ?? '',
        interests: (j['interests'] as List?)?.cast<String>().toList(),
        minAge: j['minAge'] as int? ?? 18,
        maxAge: j['maxAge'] as int? ?? 40,
        lookingFor: j['lookingFor'] as String? ?? 'serious',
        swiped: (j['swiped'] as List?)?.cast<String>().toList(),
        liked: (j['liked'] as List?)?.cast<String>().toList(),
        matches: (j['matches'] as List?)?.map((e) => DatingMatch.fromJson((e as Map).cast<String, dynamic>())).toList(),
        superLikes: j['superLikes'] as int? ?? 1,
        rejections: j['rejections'] as int? ?? 0,
      );
}
