import 'package:island_trails/models/character.dart';
import 'package:island_trails/services/storage_service.dart';

class CharacterService {
  static const String _storageKey = 'characters';
  final StorageService _storage;

  CharacterService(this._storage);

  Future<List<Character>> getAllCharacters() async {
    final jsonList = _storage.getJsonList(_storageKey);
    if (jsonList != null) {
      return jsonList.map((json) => Character.fromJson(json)).toList();
    }
    final sampleCharacters = _getSampleCharacters();
    await _saveCharacters(sampleCharacters);
    return sampleCharacters;
  }

  Future<Character?> getCharacterById(String id) async {
    final characters = await getAllCharacters();
    try {
      return characters.firstWhere((character) => character.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCharacter(Character updatedCharacter) async {
    final characters = await getAllCharacters();
    final index = characters.indexWhere((character) => character.id == updatedCharacter.id);
    if (index != -1) {
      characters[index] = updatedCharacter;
      await _saveCharacters(characters);
    }
  }

  Future<void> updateFriendshipLevel(String characterId, int newLevel) async {
    final characters = await getAllCharacters();
    final characterIndex = characters.indexWhere((character) => character.id == characterId);
    if (characterIndex != -1) {
      final character = characters[characterIndex];
      final updatedCharacter = character.copyWith(
        currentFriendshipLevel: newLevel,
        updatedAt: DateTime.now(),
      );
      characters[characterIndex] = updatedCharacter;
      await _saveCharacters(characters);
    }
  }

  Future<void> toggleFriendshipRequirement(String characterId, int levelIndex, int requirementIndex) async {
    final characters = await getAllCharacters();
    final characterIndex = characters.indexWhere((character) => character.id == characterId);
    if (characterIndex != -1) {
      final character = characters[characterIndex];
      final updatedLevels = List<FriendshipLevel>.from(character.friendshipLevels);
      final level = updatedLevels[levelIndex];
      final newCompletions = List<bool>.from(level.requirementCompletions);
      newCompletions[requirementIndex] = !newCompletions[requirementIndex];
      updatedLevels[levelIndex] = level.copyWith(requirementCompletions: newCompletions);
      final updatedCharacter = character.copyWith(
        friendshipLevels: updatedLevels,
        updatedAt: DateTime.now(),
      );
      characters[characterIndex] = updatedCharacter;
      await _saveCharacters(characters);
    }
  }

  Future<void> setUnlocked(String characterId, bool unlocked) async {
    final characters = await getAllCharacters();
    final idx = characters.indexWhere((c) => c.id == characterId);
    if (idx != -1) {
      final c = characters[idx];
      characters[idx] = c.copyWith(isUnlocked: unlocked, updatedAt: DateTime.now());
      await _saveCharacters(characters);
    }
  }

  Future<void> _saveCharacters(List<Character> characters) async {
    final jsonList = characters.map((character) => character.toJson()).toList();
    await _storage.setJsonList(_storageKey, jsonList);
  }

  List<Character> _getSampleCharacters() {
    final now = DateTime.now();
    return [
      Character(
        id: 'hello_kitty',
        name: 'Hello Kitty',
        imageUrl: 'https://pixabay.com/get/g5276a9e7c7a38cea20ce8112040b0f4ccaada7ef4744b98429dd0ca525ab20f6cf2f2aaea18d3a3fa4055b0c6d90e235a684f6a01124648a72de54f0c43a63e5_1280.jpg',
        birthday: 'November 1',
        favoriteGift: 'Apple pie',
        relationships: ['My Melody', 'Kuromi'],
        currentFriendshipLevel: 1,
        friendshipLevels: [
          FriendshipLevel(
            level: 1,
            reward: 'Hello Kitty\'s bow',
            requirements: ['Say hello 5 times', 'Give 3 gifts'],
            requirementCompletions: [false, false],
          ),
          FriendshipLevel(
            level: 2,
            reward: 'Friendship photo',
            requirements: ['Complete a quest together', 'Share a meal'],
            requirementCompletions: [false, false],
          ),
          FriendshipLevel(
            level: 3,
            reward: 'Special outfit',
            requirements: ['Play 5 games together', 'Help with island tasks'],
            requirementCompletions: [false, false],
          ),
        ],
        isUnlocked: false,
        createdAt: now,
        updatedAt: now,
      ),
      Character(
        id: 'my_melody',
        name: 'My Melody',
        imageUrl: 'https://pixabay.com/get/g89e3c7a7a55dd4ee219d1329c0635a4ee132dffc00c99901d10977fe62f1c3de442dd14f4138c78c921c624050ced514252bf318e6359972fd131793bf94a5c7_1280.png',
        birthday: 'January 18',
        favoriteGift: 'Strawberry cake',
        relationships: ['Hello Kitty', 'Cinnamoroll'],
        currentFriendshipLevel: 1,
        friendshipLevels: [
          FriendshipLevel(
            level: 1,
            reward: 'Pink hood',
            requirements: ['Water flowers together', 'Bake cookies'],
            requirementCompletions: [false, false],
          ),
          FriendshipLevel(
            level: 2,
            reward: 'Garden tools',
            requirements: ['Plant 10 flowers', 'Have a picnic'],
            requirementCompletions: [false, false],
          ),
          FriendshipLevel(
            level: 3,
            reward: 'Melody\'s diary',
            requirements: ['Create a garden together', 'Share secrets'],
            requirementCompletions: [false, false],
          ),
        ],
        isUnlocked: false,
        createdAt: now,
        updatedAt: now,
      ),
      Character(
        id: 'kuromi',
        name: 'Kuromi',
        imageUrl: 'https://pixabay.com/get/g14937c1ab1a3b289a3ff6c0f461c3112d530abc334692f25a998c67dbacd04ebc2fe84aab4486553d55606db9c36c9d1ee0ee8ebcac66410af8324ff1803fd75_1280.jpg',
        birthday: 'October 31',
        favoriteGift: 'Devil\'s food cake',
        relationships: ['Hello Kitty', 'Baku'],
        currentFriendshipLevel: 1,
        friendshipLevels: [
          FriendshipLevel(
            level: 1,
            reward: 'Skull bow',
            requirements: ['Play pranks together', 'Race around the island'],
            requirementCompletions: [false, false],
          ),
          FriendshipLevel(
            level: 2,
            reward: 'Mischief kit',
            requirements: ['Win 3 competitions', 'Explore caves'],
            requirementCompletions: [false, false],
          ),
          FriendshipLevel(
            level: 3,
            reward: 'Best friend necklace',
            requirements: ['Share adventure stories', 'Help with pranks'],
            requirementCompletions: [false, false],
          ),
        ],
        isUnlocked: false,
        createdAt: now,
        updatedAt: now,
      ),
      Character(
        id: 'cinnamoroll',
        name: 'Cinnamoroll',
        imageUrl: 'https://pixabay.com/get/gceb26ab9aacf2098b3a8b864ff67ea570f2b65aa632bed6e706ad9d3fb4e007b7e4bc21322517b5b0d17da5a4a180d5f2eb562e400c69cd13279e80b79339d5e_1280.jpg',
        birthday: 'March 6',
        favoriteGift: 'Cinnamon rolls',
        relationships: ['My Melody', 'Cappuccino'],
        currentFriendshipLevel: 1,
        friendshipLevels: [
          FriendshipLevel(
            level: 1,
            reward: 'Fluffy tail accessory',
            requirements: ['Fly together in the sky', 'Share cloud watching'],
            requirementCompletions: [false, false],
          ),
          FriendshipLevel(
            level: 2,
            reward: 'Sky map',
            requirements: ['Visit cloud castle', 'Learn to float'],
            requirementCompletions: [false, false],
          ),
          FriendshipLevel(
            level: 3,
            reward: 'Wings of friendship',
            requirements: ['Sky race challenge', 'Help other friends fly'],
            requirementCompletions: [false, false],
          ),
        ],
        isUnlocked: false,
        createdAt: now,
        updatedAt: now,
      ),
      Character(
        id: 'pompompurin',
        name: 'Pompompurin',
        imageUrl: 'https://pixabay.com/get/gc4cbe00a9f29bb4f2b16cc135af8ed3adba97d1ed20ac7230cb8db60fd3fd6777cab144f33826264d62dcb5dfefed1d31d07fc916903c533a110b6b2c0815e76_1280.jpg',
        birthday: 'April 16',
        favoriteGift: 'Pudding',
        relationships: ['Muffin', 'Bagel'],
        currentFriendshipLevel: 1,
        friendshipLevels: [
          FriendshipLevel(
            level: 1,
            reward: 'Golden retriever collar',
            requirements: ['Take naps together', 'Share snacks'],
            requirementCompletions: [false, false],
          ),
          FriendshipLevel(
            level: 2,
            reward: 'Cozy blanket',
            requirements: ['Play fetch 10 times', 'Have a sleepover'],
            requirementCompletions: [false, false],
          ),
          FriendshipLevel(
            level: 3,
            reward: 'Best buddy medal',
            requirements: ['Go on adventures', 'Help friends relax'],
            requirementCompletions: [false, false],
          ),
        ],
        isUnlocked: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
