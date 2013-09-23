# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.delete_all
User.find_by_sql("delete from sqlite_sequence where name='users'")
User.create([
  { username: 'bzoon', password: 'astron' },
  { username: 'user2', password: 'pass' }
])

List.delete_all
User.find_by_sql("delete from sqlite_sequence where name='lists'")
List.create([
  { user_id: 1, name: 'Book Words - A', points: 2, description: 'Book words that start with A', public: true },
  { user_id: 1, name: 'Book Words - B', points: 1, description: 'Book words that start with B', public: true },
  { user_id: 2, name: 'my_words', points: 0, description: 'Words I want to learn.', public: false },
  { user_id: 2, name: 'pub_words', points: 0, description: 'List to share with friends', public: true }
])
('C'..'Z').each do |l|
  List.create(user_id: 1, name: "Book Words - #{l}", points: 0, description: "Book words that start with #{l}", public: true)
end

Word.delete_all
User.find_by_sql("delete from sqlite_sequence where name='words'")
Word.create([
  { word: 'abase', first_def: 'to lower physically', definition: '<b>abase</b> verb<br><b>1</b> to lower physically <br><b>2</b> to lower in rank, office, prestige, or esteem <br><br>' },
  { word: 'abash', first_def: 'to destroy the self-possession or self-confidence of :disconcert', definition: '<b>abash</b> verb<br>to destroy the self-possession or self-confidence of :disconcert <br><br>' },
  { word: 'abattoir', first_def: 'slaughterhouse', definition: '<b>abattoir</b> noun<br>slaughterhouse <br><br>' },
  { word: 'abeam', first_def: 'off to the side of a ship or plane especially at a right angle to the middle of the ship or plane\'s length', definition: '<b>abeam</b> adverb or adjective<br>off to the side of a ship or plane especially at a right angle to the middle of the ship or plane\'s length <br><br>' },
  { word: 'aberrant', first_def: 'straying from the right or normal way', definition: '<b>aberrant<sup>1</sup></b> adjective<br><b>1</b> straying from the right or normal way <br><b>2</b> deviating from the usual or natural type :atypical <br><br><b>aberrant<sup>2</sup></b> noun<br><b>1</b> a group, individual, or structure that is not normal or typical :an aberrant group, individual, or structure <br><b>2</b> a person whose behavior departs substantially from the standard <br><br>' },
  { word: 'abet', first_def: 'to actively second and encourage (as an activity or plan)', definition: '<b>abet</b> verb<br><b>1</b> to actively second and encourage (as an activity or plan) <br><b>2</b> to assist or support in the achievement of a purpose <br><br>' },
  { word: 'abhor', first_def: 'to regard with extreme repugnance :loathe', definition: '<b>abhor</b> verb<br>to regard with extreme repugnance :loathe <br><br>' },
  { word: 'banal', first_def: 'lacking originality, freshness, or novelty :trite', definition: '<b>banal</b> adjective<br>lacking originality, freshness, or novelty :trite <br><br>' },
  { word: 'bandy', first_def: 'to bat (as a tennis ball) to and fro', definition: '<b>bandy<sup>1</sup></b> verb<br><b>1</b> to bat (as a tennis ball) to and fro <br><b>2 a</b> to toss from side to side or pass about from one to another often in a careless or inappropriate manner <br><b>b</b> exchange <i>especially</i> to exchange (words) argumentatively <br><b>c</b> to discuss lightly or banteringly <br><b>d</b> to use in a glib or offhand manner often used with about &lt;bandy these statistics about with considerable bravado Richard Pollak&gt; <br><b>3</b> to band together <br><b>1</b> contend <br><b>2</b> unite <br><br><b>bandy<sup>2</sup></b> noun<br>a game similar to hockey and believed to be its prototype <br><br><b>bandy<sup>3</sup></b> adjective<br><b>1</b> bowed <br><b>2</b> bowlegged <br><br>' },
  { word: 'ballyhoo', first_def: 'a noisy attention-getting demonstration or talk', definition: '<b>ballyhoo</b> noun<br><b>1</b> a noisy attention-getting demonstration or talk <br><b>2</b> flamboyant, exaggerated, or sensational promotion or publicity <br><b>3</b> excited commotion <br><br>' }
])

ListWord.delete_all
User.find_by_sql("delete from sqlite_sequence where name='list_words'")
ListWord.create([
  { list_id: 1, word_id: 1 },
  { list_id: 1, word_id: 2 },
  { list_id: 1, word_id: 3 },
  { list_id: 1, word_id: 4 },
  { list_id: 1, word_id: 5 },
  { list_id: 1, word_id: 6 },
  { list_id: 1, word_id: 7 },
  { list_id: 2, word_id: 8 },
  { list_id: 2, word_id: 9 },
  { list_id: 2, word_id: 10 },
  { list_id: 3, word_id: 6 },
  { list_id: 4, word_id: 10 }
])

ListwordDef.delete_all
User.find_by_sql("delete from sqlite_sequence where name='listword_defs'")
ListwordDef.create([
  { list_word_id: 1, definition: 'to lower physically +1', points: 1 },
  { list_word_id: 1, definition: '2nd def', points: 0 },
  { list_word_id: 2, definition: 'to destroy the self-possession or self-confidence of :disconcert', points: 0 },
  { list_word_id: 3, definition: 'slaughterhouse', points: 0 },
  { list_word_id: 4, definition: 'off to the side of a ship or plane especially at a right angle to the middle of the ship or plane\'s length', points: 0 },
  { list_word_id: 5, definition: 'straying from the right or normal way', points: 0 },
  { list_word_id: 6, definition: 'to actively second and encourage (as an activity or plan)', points: 0 },
  { list_word_id: 7, definition: 'to regard with extreme repugnance :loathe', points: 0 },
  { list_word_id: 8, definition: 'lacking originality, freshness, or novelty :trite', points: 0 },
  { list_word_id: 9, definition: 'to bat (as a tennis ball) to and fro', points: 0 },
  { list_word_id: 10, definition: 'a noisy attention-getting demonstration or talk', points: 0 },
  { list_word_id: 11, definition: 'abet definition', points: 0 },
  { list_word_id: 12, definition: 'hoorah!!!', points: 1 }
])

Favorite.delete_all
User.find_by_sql("delete from sqlite_sequence where name='favorites'")
Favorite.create([
  { user_id: 1, list_id: 1 },
  { user_id: 1, list_id: 4 },
  { user_id: 2, list_id: 1 }
])

ListVote.delete_all
User.find_by_sql("delete from sqlite_sequence where name='list_votes'")
ListVote.create([
  { user_id: 1, list_id: 1, is_up: true },
  { user_id: 1, list_id: 2, is_up: true },
  { user_id: 1, list_id: 4, is_up: false },
  { user_id: 2, list_id: 1, is_up: true },
  { user_id: 2, list_id: 4, is_up: true }
])

DefVote.delete_all
User.find_by_sql("delete from sqlite_sequence where name='def_votes'")
DefVote.create([
  { user_id: 1, listword_def_id: 13 },
  { user_id: 2, listword_def_id: 1 }
])
