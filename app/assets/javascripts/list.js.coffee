# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# backup to restore if they cancel an edit
saved_html = {}

window.delete_word = (list_id, word_id) ->
  if(confirm('Are you sure?'))
    $.get("/list/#{list_id}/delete/#{word_id}").done ->
      $("#word_#{word_id}").remove()
      return
  return

window.edit_word = (list_id, word_id) ->
  form_html = "<form id=\"form_#{word_id}\" method=\"post\">"
  defs = []
  $("#word_#{word_id} span").each ->
    defs.push($(this).attr('title'))
  if (defs.length > 0)
    form_html += "<input id=\"def_#{i}\" name=\"def_#{i}\" type=\"text\" size=\"60\" maxlength=\"255\" value=\"#{defs[i]}\" /><br>" for i in [0..defs.length-1]
  form_html += "<a href=\"#\" onclick=\"add_def_line(#{word_id})\">Add Definition</a>"

  action_html = "<a href=\"#\" onclick=\"submit_edit(#{list_id}, #{word_id})\">Submit</a> | "
  action_html += "<a href=\"#\" onclick=\"cancel_edit(#{list_id}, #{word_id})\">Cancel</a>"

  saved_html[word_id] = $("#word_#{word_id} td:nth-child(2)").html()

  $("#word_#{word_id} td:nth-child(2)").html(form_html)
  $("#word_#{word_id} td:nth-child(3)").html(action_html)
  return

window.add_def_line = (word_id) ->
  num_lines = $("#word_#{word_id} td:nth-child(2) input").length
  $("#word_#{word_id} td:nth-child(2) a").before("<input id=\"def_#{num_lines}\" name=\"def_#{num_lines}\" type=\"text\" size=\"60\" maxlength=\"255\" value=\"\" /><br>")
  return

window.submit_edit = (list_id, word_id) ->
  i = 0
  defs = loop
    break if $("#def_#{i}").length == 0
    value = $("#def_#{i}").val()
    i += 1
    continue if value.replace(/^\s+|\s+$/g, '').length == 0
    value

  $.post("/list/#{list_id}/edit/#{word_id}", $("#form_#{word_id}").serialize(), ->
    def_html = ""
    if defs.length == 0
      def_html = "<i>No definition specified.</i>"
    else
      def_html += (if i > 0 then "<br>" else "") + (if defs.length > 1 then "<b>#{i+1}.</b> " else "") + "<span title=\"#{defs[i]}\">" + defs[i][0..99] + (if defs[i].length > 100 then " ..." else "") + "</span>" for i in [0..defs.length-1]

    action_html = "<a href=\"#\" onclick=\"edit_word(#{list_id}, #{word_id})\">Edit</a> | "
    action_html += "<a href=\"#\" onclick=\"delete_word(#{list_id}, #{word_id})\">Delete</a>"

    $("#word_#{word_id} td:nth-child(2)").html(def_html)
    $("#word_#{word_id} td:nth-child(3)").html(action_html)
    return
  )
  return

window.cancel_edit = (list_id, word_id) ->
  $("#word_#{word_id} td:nth-child(2)").html(saved_html[word_id])

  action_html = "<a href=\"#\" onclick=\"edit_word(#{list_id}, #{word_id})\">Edit</a> | "
  action_html += "<a href=\"#\" onclick=\"delete_word(#{list_id}, #{word_id})\">Delete</a>"
  $("#word_#{word_id} td:nth-child(3)").html(action_html)
  return
