redirect_to_facebook_login_if_not_logged = ->
  if $('#menus .fb_login').length
    window.colorbox_facebook()
  else
    $.fn.colorbox.close()

reload_colorbox_random_level = ->
  $(document).bind('cbox_closed', ->
    window.colorbox_random_level()
    $(document).unbind('cbox_closed')
  )
  window.hide_all_tipsy()
  $.fn.colorbox.close()

bind_invite_friends = ->
  # Click on 'later' on 'invite-friends'
  $('#invite-friends .button-next').on('click', ->
    window.hide_all_tipsy()
    $.fn.colorbox.close()
    false
  )

  # Click on a friend thumb
  $('#invite-friends .friends img').on('click', ->
    window.facebook_send_app_request($(this).attr('data-f_id'), [])
  )

  # Click on the big invite button
  $('#invite-friends .friend-button').on('click', ->
    window.facebook_send_recursive_app_request()
  )

# 1/3 facebook fan page (if any)
# 1/3 invite friends (if user don't have a 30 days derogation)
# 1/9 random level
random_social_popup = ->
  random = Math.floor((Math.random()*3)+1) # number between 1 and 3
  logged = $("#menus .fb_logged").length
  console.log("random : #{random}")

  if random == 1
    if (logged and $("#menus .fb_logged").attr('data-like-facebook-page') == 'false') or !logged
      setTimeout(window.colorbox_facebook_page, 1500)
  else if random == 2
    if logged and $("#menus .fb_logged").attr('data-display-invite-popup') == 'true'
      setTimeout(window.colorbox_invite_friends, 1500)
  else
    random2 = Math.floor((Math.random()*3)+1)
    console.log("random2 : #{random2}")
    if random2 == 1
      setTimeout(window.colorbox_random_level, 1500)

$ ->
  # Click on 'next' on "welcome"
  $('#welcome .button-next').on('click', ->
    window.colorbox_controls()
    start_animation(1000)
    false
  )

  # Click on 'next' on "controls"
  $('#controls .button-next').on('click', ->
    window.colorbox_rules()
    false
  )

  # Click on 'next' on "rules"
  $('#rules .button-next').on('click', ->
    if $("#menus .fb_logged").length and $("#menus .fb_logged").attr('data-like-facebook-page') == 'false'
      window.colorbox_facebook_page()
    else
      redirect_to_facebook_login_if_not_logged()
    false
  )

  # Click on 'next' on "facebook-page"
  $('#facebook-page .button-next').on('click', ->
    window.update_like_facebook_page_value()
    redirect_to_facebook_login_if_not_logged()
    false
  )

  # Click on the next level
  $('#next-level-canvas, .game-action-next').on('click', ->
    # change the level (the '.is-selected' level is chosen)
    window.hide_all_tipsy()
    $.fn.colorbox.close()

    button = $('#levels .is-selected')

    next_button = button.next('li')
    if not next_button.length
      next_button = button.parent().find('li:first')

    button.removeClass('is-selected')
    next_button.addClass('is-selected')

    window.change_level()

    # change the url and save related state (pack and level)
    window.push_this_state()

    random_social_popup()

    false
  )

  # Click on retry level
  $('#this-level-canvas, .game-action-retry').on('click', ->
    # change the level (the '.is-selected' level is chosen)
    window.hide_all_tipsy()
    $.fn.colorbox.close()
    window.change_level()
    false
  )

  $('.game-action-challenge').on('click', ->
    reload_colorbox_random_level()
    false
  )

  $('#random-level-canvas').on('click', ->
    level_name = $(this).parent().attr('data-level-name')
    pack_name  = $(this).parent().attr('data-pack-name')
    location.assign("/packs/#{pack_name}/levels/#{level_name}")
  )

  $('#random-level .reload-button').on('click', ->
    reload_colorbox_random_level()
    false
  )

  bind_invite_friends()

  pusher_move = (dir) ->
    $('#controls .pusher .middle img').attr('src', '/images/themes/classic/floor64.png')
    $("#controls .pusher .#{dir} img").attr('src', '/images/themes/classic/pusher64.png')
    $("#controls .keyboard img").attr("src", "/assets/arrow_keys_#{dir}.png")

  pusher_center = ->
    for dir in ['up', 'down', 'left', 'right']
      $("#controls .pusher .#{dir} img").attr('src', '/images/themes/classic/floor64.png')

    $("#controls .pusher .middle img").attr('src', '/images/themes/classic/pusher64.png')
    $("#controls .keyboard img").attr("src", "/assets/arrow_keys.png")

  # controls animation : pusher up, down, left, right
  start_animation = (delay) ->
    setTimeout(( -> pusher_move('up')), delay)
    setTimeout(( -> pusher_center()), 2*delay)
    setTimeout(( -> pusher_move('down')), 3*delay)
    setTimeout(( -> pusher_center()), 4*delay)
    setTimeout(( -> pusher_move('left')), 5*delay)
    setTimeout(( -> pusher_center()), 6*delay)
    setTimeout(( -> pusher_move('right')), 7*delay)
    setTimeout(( -> pusher_center()), 8*delay)
    setTimeout(( -> start_animation(delay)), 8*delay)
