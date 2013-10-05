# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# global to store word data for the quiz
word_data = []
cur_index = 0
cur_word = ""
cur_def = ""
cur_pos = -1
correct_count = 0

window.initialize_quiz = (data) ->
  word_data = data
  cur_index = 0
  cur_word = ""
  cur_def = ""
  cur_pos = -1
  correct_count = 0

  update_status()
  show_question()
  return

show_question = ->
  if (cur_index >= word_data.length)
    $('#word_d').html('')
    $('#definition').html('COMPLETE')
    return

  cur_word = word_data[cur_index]
  cur_index += 1

  word_html = "<b><a href='/full_def/#{cur_word.id}' target='_blank'>#{cur_word.word}</a></b>"
  cur_def = random_element(cur_word.definitions)

  i = 0
  other_words = []
  defs = []
  while (i < 3)
    my_word = null
    loop
      my_word = random_element(word_data)
      break if my_word != cur_word && $.inArray(my_word, other_words) == -1
    other_words.push(my_word)
    defs.push(random_element(my_word.definitions))
    i += 1
  defs.push(cur_def)
  shuffle(defs)
  cur_pos = $.inArray(cur_def, defs)

  def_html = ""
  i = 0
  while (i < 4)
    def_html += "<div data-i='#{i}' class='quiz_definition'>#{defs[i]}</div>"
    i += 1

  $('#word_d').html(word_html)
  $('#definition').html(def_html)

  $('.quiz_definition').click ->
    process_answer($(this).data('i'))
    return
  return

process_answer = (i) ->
  correct_count += 1 if (i == cur_pos)

  if (i != cur_pos)
    html = "<tr><td><b><a href='/full_def/#{cur_word.id}' target='_blank'>#{cur_word.word}</a></b></td>"
    html += "<td style='text-align:left'>#{cur_def}</td></tr>"
    $('#incorrect').append(html)

  update_status()
  show_question()
  return

update_status = ->
  html = "<b>Words:</b> #{word_data.length}<br>"
  pct = 0
  pct = Math.floor(correct_count * 100 / cur_index) if cur_index > 0
  html += "<b>Score:</b> #{correct_count} / #{cur_index} (#{pct}%)"
  $('#status').html(html)
  return

random_element = (list) ->
  list[Math.floor(Math.random() * list.length)]

shuffle = (list) ->
  for i in [list.length-1..1]
    j = Math.floor Math.random() * (i + 1)
    [list[i], list[j]] = [list[j], list[i]]
  list
