redirect_to_facebook_login_if_not_logged = ->
  if $('#menus .fb_login').length
    window.colorbox_facebook()
  else
    $.fn.colorbox.close()

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

  # Hover the next-level image
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

    false
  )

  # Hover the next-level image
  $('#this-level-canvas, .game-action-retry').on('click', ->
    # change the level (the '.is-selected' level is chosen)
    window.hide_all_tipsy()
    $.fn.colorbox.close()
    window.change_level()
    false
  )

  $('#random-level-canvas').on('click', ->
    level_name = $(this).parent().attr('data-level-name')
    pack_name  = $(this).parent().attr('data-pack-name')
    location.assign("/packs/#{pack_name}/levels/#{level_name}")
  )

  $('#random-level .reload-button').on('click', ->
    $(document).bind('cbox_closed', ->
      window.colorbox_random_level()
      $(document).unbind('cbox_closed')
    )
    window.hide_all_tipsy()
    $.fn.colorbox.close()
  )

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
