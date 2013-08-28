# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

window.process_login = ->
  if verify_data()
    $('#login_form').attr('action', '/login/login')
    $('#login_form').submit() 
  return
  
window.process_register = ->
  if verify_data()
    $('#login_form').attr('action', '/login/register')
    $('#login_form').submit()
  return

verify_data = ->
  uname = $('#uname').val().replace(/^\s+|\s+$/g, "")
  passw = $('#passw').val().replace(/^\s+|\s+$/g, "")

  if (!!!uname)
    $('#login_error').html('Username field empty.')
    return false

  if (!!!passw)
    $('#login_error').html('Password field empty.')
    return false

  true

