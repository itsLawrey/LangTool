/// Grammatical category of an [Entry].
///
/// Which form fields a word type has is defined per language by a
/// `LanguageSchema`, not here.
enum WordType {
  noun,
  verb,
  adjective,
  adverb,
  phrase,
  preposition,
  conjunction,
  pronoun,
  other,
}
