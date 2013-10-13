# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.submit_search = ->
  keyword = $('#search_keyword').val().replace(/^\s+|\s+$/g, "").toLowerCase()
  window.location = "/browse/search/#{keyword}" if keyword.length > 0
  return
