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

window.edit_list = (id) ->
  return if $("#list_#{id} .edit_box").length > 0
  $.get("/browse/edit_list/#{id}", (data) ->
    $("#list_#{id} .list_ln2").before(data)
    $("#list_#{id} .edit_box").slideDown()
    return
  )
  return

window.cancel_list_edit = (id) ->
  $("#list_#{id} .edit_box").remove()
  return

window.process_list_vote = (id, dir) ->
  cur_vote = parseInt($("#points_#{id}").html(), 10)
  if(dir == "up")
    if $("#downvote_#{id}").css('visibility') == 'visible'
      $("#upvote_#{id}").css('visibility', 'hidden')
    else
      $("#downvote_#{id}").css('visibility', 'visible')
    $("#points_#{id}").html("#{cur_vote+1}")
  else
    if $("#upvote_#{id}").css('visibility') == 'visible'
      $("#downvote_#{id}").css('visibility', 'hidden')
    else
      $("#upvote_#{id}").css('visibility', 'visible')
    $("#points_#{id}").html("#{cur_vote-1}")

  $.get("/browse/vote/#{id}/#{dir}")
  return
