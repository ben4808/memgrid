# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

word_data = {}
cur_temp_id = 0
show_actions = false;

window.initialize_list_data = (list_id, data, sa) ->
  cur_temp_id = 0
  word_data = data
  show_actions = sa
  refresh_word_list(list_id)

window.show_full_def = (list_id, word_id) ->
  window.open("/list/#{list_id}/full_def/#{word_id}", '_blank', 'height=600,width=800,resizable=yes,scrollbars=yes,menubar=yes,toolbar=yes,status=yes')

window.add_word = (list_id) ->
  word = $('#word').val().replace /^\s+|\s+$/g, ""  
  if word.length == 0
    $('#not_a_word').html('No word specified.')
    return

  add_word_helper(list_id, word)
  return

window.add_word_multiple = (list_id) ->
  words = $('#mult_words').val().split(/\s+/).map (w) -> w.replace(/^\s+|\s+$/g, "")

  for word in words
    w = word.replace(/[^\w_-]/, '')
    w = w.replace(/_/, ' ')
    add_word_helper(list_id, w)
  return

add_word_helper = (list_id, word) ->
  cur_temp_id -= 1
  temp_id = cur_temp_id
  word_data[temp_id] = {word: word, definitions: "<i>Loading...</i>"}
  refresh_word_list(list_id)
  $.post("/list/#{list_id}/new", {word: word}, (data) ->
    d = $.parseJSON(data)
    delete word_data[temp_id]
    word_data[d.id] = {word: word, definitions: d.definition}
    refresh_word_list(list_id)
    return
  )

window.delete_word = (list_id, word_id) ->
  if(confirm('Are you sure?'))
    $.get("/list/#{list_id}/delete/#{word_id}").done ->
      delete word_data[word_id]
      refresh_word_list(list_id)
      return
  return

window.edit_word = (list_id, word_id) ->
  return if $("#def_td_#{word_id} .edit_box").length > 0
  $.get("/list/#{list_id}/edit_box/#{word_id}", (data) ->
    $("#def_td_#{word_id}").append(data)
    $("#def_td_#{word_id} .edit_box").slideDown()
    return
  )
  return
 
window.add_def_line = (word_id) ->
  num_lines = $("#def_td_#{word_id} .edit_box input[type=text]").length
  $("#def_td_#{word_id} .edit_box a").before("<input id=\"def_#{num_lines}\" name=\"def_#{num_lines}\" type=\"text\" size=\"60\" maxlength=\"255\" value=\"\" /><br>")
  return

window.submit_edit = (list_id, word_id) ->
  $.post("/list/#{list_id}/edit/#{word_id}", $("#edit_def_form").serialize(), (data) ->
    word_data[word_id].definitions = data
    refresh_word_list(list_id)
    return
  )
  return

window.cancel_def_edit = (word_id) ->
  $("#def_td_#{word_id} .edit_box").remove()
  return

window.favorite = (list_id) ->
  $.get("/list/#{list_id}/favorite", (data) ->
    alert("List added to your favorites list.")
    return
  )
  return

window.refresh_word_list = (list_id) ->
  ids_hash = {}
  for k, v of word_data
    ids_hash[v.word] = k

  words = []
  words.push w.word for k, w of word_data
  words.sort()

  html = ""
  for w in words
    word = w
    id = ids_hash[word]
    word_obj = word_data[id]
    definition = word_obj.definitions

    html += "<tr id='word_#{id}'>"
    html += "<td><b><a href='javascript:void(0)' data-id='#{id}'>#{word}</a></b></td>"
    html += "<td id='def_td_#{id}'>#{definition}</td>"
    html += "<td width='80'>"
    if show_actions
      html += "<a href='javascript:void(0)' onclick='edit_word(#{list_id}, #{id})'>Edit</a> | <a href='javascript:void(0)' onclick='delete_word(#{list_id}, #{id})'>Delete</a>"
    html += "</td></tr>"

  $('#word_list tbody').html(html)
  $("a[data-id]").unbind().click ->
      show_full_def(list_id, $(this).data("id"))
  return
