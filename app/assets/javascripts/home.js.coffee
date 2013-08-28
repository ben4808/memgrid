# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.make_edit_list_row = (id, name) ->
  html1 = "<form id='edit_list' action='/edit/#{id}' method='post'><input id='name' name='name' type='text' value='#{name}'>"
  html2 = "<a href='#' onclick='submit_edit()'>Submit</a> | <a href='/'>Cancel</a></form>"
  $("#list_#{id} td:nth-child(1)").html(html1)
  $("#list_#{id} td:nth-child(3)").html(html2)
  return

window.submit_edit = (id) ->
  name = $('#name').val()
  if(!!!name)
    window.location = "/"
  else
    $('#edit_list').submit()
  return
 
window.delete_list = (id) ->
  window.location = "/delete/#{id}" if(confirm('Are you sure?'))
  return
