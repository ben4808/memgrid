# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.show_full_def = (id) ->
  window.open('/full_def/' + id, '_blank', 'height=600,width=800,resizable=yes,scrollbars=yes,menubar=yes,toolbar=yes,status=yes')

window.delete_word = (list_id, word_id) ->
  if(confirm('Are you sure?'))
    $.get("/list/#{list_id}/delete/#{word_id}").done ->
      $("#word_#{word_id}").remove()
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
    $("#def_td_#{word_id}").html(data)
    return
  )
  return

window.cancel_def_edit = (word_id) ->
  $("#def_td_#{word_id} .edit_box").remove()
  return
