# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.load_lists = (url, query_type, user, keyword, records_per_request, cur_offset) ->
  $('#load_more').remove()
  original_html = $('#lists').html()
  $('#lists').append('Loading...')
  $.post(url, {type: query_type, user: user, keyword: keyword, count: records_per_request, offset: cur_offset}, (data) ->
    $('#lists').html(original_html + data)
    return
  )
  return
