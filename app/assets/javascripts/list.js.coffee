# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Full definitions for future mouseover events
full_defs = {}

window.delete_word = (list_id, word_id) ->
  window.location = "/list/#{list_id}/delete/#{word_id}" if(confirm('Are you sure?'))
  return

window.store_definitions = (defs) ->
  full_defs = defs

window.show_full_def = (id) ->
  $('#full_def_panel').html(full_defs[id])

