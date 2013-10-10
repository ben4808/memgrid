# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# global to store word data for the quiz
word_data = []
cur_index = 0
cur_ques = ""
cur_ans = ""
cur_pos = -1
correct_count = 0
ques_count = 0
num_questions = 0
is_normal = true
list_id = -1

window.initialize_quiz = (list_i, data, mode) ->
  word_data = data
  cur_index = 0
  cur_ques = ""
  cur_ans = ""
  cur_pos = -1
  correct_count = 0
  ques_count = 0
  is_normal = (mode == 'normal')
  list_id = list_i

  if is_normal
    num_questions = word_data.length
  else
    # transform word_data array to flatten out the definitions so each definition is used
    reverse_index = []
    reverse_index.push {id: w.id, word: w.word, definition: d} for d in w.definitions for w in word_data
    num_questions = reverse_index.length
    word_data = reverse_index

  update_status()
  show_question()
  return

show_question = ->
  if (cur_index >= num_questions)
    $('#ques_d').html('')
    $('#ans_d').html('COMPLETE')
    return

  cur_ques = word_data[cur_index]
  cur_index += 1

  if is_normal
    ques_html = "<b><a href='/list/#{list_id}/full_def/#{cur_ques.id}' target='_blank'>#{cur_ques.word}</a></b>"
    cur_ans = random_element(cur_ques.definitions)
  else
    ques_html = cur_ques.definition
    cur_ans = cur_ques.word

  i = 0
  other_ques = []
  answers = []
  while i < 3
    my_ques = null
    loop
      my_ques = random_element(word_data)
      break if my_ques != cur_ques && $.inArray(my_ques, other_ques) == -1
    other_ques.push(my_ques)
    answers.push(if is_normal then random_element(my_ques.definitions) else my_ques.word)
    i += 1
  answers.push(cur_ans)
  shuffle(answers)
  cur_pos = $.inArray(cur_ans, answers)

  ans_html = ""
  i = 0
  while (i < 4)
    ans_html += "<div data-i='#{i}' class='quiz_ans'>#{answers[i]}</div>"
    i += 1

  $('#ques_d').html(ques_html)
  $('#ans_d').html(ans_html)

  $('.quiz_ans').click ->
    process_answer($(this).data('i'))
    return
  return

process_answer = (i) ->
  ques_count += 1
  if i == cur_pos
    correct_count += 1
    $("#correct_notify").css('color', '#090').html('Correct')
  else
    $("#correct_notify").css('color', '#900').html('Incorrect')

  if (i != cur_pos)
    html = ""
    if is_normal
      html += "<tr><td><b><a href='/list/#{list_id}/full_def/#{cur_ques.id}' target='_blank'>#{cur_ques.word}</a></b></td>"
      html += "<td style='text-align:left'>#{cur_ans}</td></tr>"
    else
      html += "<tr><td style='text-align:left'>#{cur_ques.definition}</td>"
      html += "<td><b><a href='/list/#{list_id}/full_def/#{cur_ques.id}' target='_blank'>#{cur_ques.word}</a></b></td></tr>"
    $('#incorrect').append(html)

  update_status()
  show_question()
  return

update_status = ->
  html = "<b>Questions:</b> #{num_questions}<br>"
  pct = 0
  pct = Math.floor(correct_count * 100 / ques_count) if ques_count > 0
  html += "<b>Score:</b> #{correct_count} / #{ques_count} (#{pct}%)"
  $('#status').html(html)
  return

random_element = (list) ->
  list[Math.floor(Math.random() * list.length)]

shuffle = (list) ->
  for i in [list.length-1..1]
    j = Math.floor Math.random() * (i + 1)
    [list[i], list[j]] = [list[j], list[i]]
  list
