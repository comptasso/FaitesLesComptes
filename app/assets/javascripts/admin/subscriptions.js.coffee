toggle_end_date= ->
  status = $("input[name='subscription[permanent]']:checked").val()
  console.log("dans toggle avec statut #{status}")
  if (status == 'true')
    $('.subscription_end_date').hide()
  else
    $('.subscription_end_date').show()

jQuery ->
  if $('.admin_subscriptions')?
  # gestion du champ end_date lors de l'affichage initial
    toggle_end_date() 
  # gestion lors du changement de choix sur un radio button
    $('input.radio_buttons').change(toggle_end_date)