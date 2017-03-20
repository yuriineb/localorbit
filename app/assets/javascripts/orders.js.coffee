$ ->

  $("#signature").jSignature()

  $("input.check-all").change ->
    $("input[name='item_ids[]']").prop("checked", $(this).prop("checked"))

  $("#mark-all-delivered").click (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to mark all items delivered?")
      $(".order-item-row .delivery-status > input").val("delivered")
      amt = $(".order-item-row .quantity-ordered-ro").val()
      $(".order-item-row .quantity .quantity-delivered").val(amt)
      $(this).closest("form").submit()

  $("#undo-delivery").click (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to UNDO marking all of these items delivered?")
      $(".order-item-row .delivery-status > input").val("pending")
      $(".order-item-row .delivered-at > input").val('NULL')
      $(".order-item-row .quantity .quantity-delivered").val("")
      $(this).closest("form").submit()

  $(".order-item-row .action-link a").click (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to remove this item?")
      $(this).parent().find("input").val("true")
      $(this).closest("form").submit()

  # Change Delivery
  $("#delivery-changer").on "click", "a", (e) ->
    e.preventDefault()
    $("#delivery-changer .fields").toggleClass('is-hidden')
    $("#delivery-changer a").toggleClass('is-hidden')

  $(".delivery-clear").click (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to remove the fee?")
      $(this).parent().find("input").val("true")
      $(this).closest("form").submit()


  $(".credit-clear").click (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to remove the credit?")
      $(this).parent().find("input").val("true")
      $(this).closest("form").submit()

  $("#merge_button").click (e) ->
    e.preventDefault()
    $("#merge_options").show()
    $(".button-bar").hide()

  $("#merge_cancel_button").click (e) ->
    e.preventDefault()
    $("#merge_options").hide()
    $(".button-bar").show()

  $("#duplicate_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Duplicate Order")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#export_invoice_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Export Invoice")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#export_bill_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Export Bill")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#unclose_order").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Unclose Order")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#uninvoice_order").click (e) ->
    e.preventDefault()
    $(this).parent().parent().parent().parent().find("input[name=commit]").val("Uninvoice Order")
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#save_sig").click (e) ->
    e.preventDefault()
    datapair = $("#signature").jSignature("getData","base30")
    $("input[name='order[signature_data]']").val(datapair[1])
    $(this).closest("form").submit()
    $(this).prop("disabled","disabled")

  $("#clear_sig").click (e) ->
    e.preventDefault()
    datapair = $("#signature").jSignature("clear")

  $(".shrink_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().find(".shrink_options").show()
    $(this).parent().parent().find(".product_ops").hide()

  $(".shrink_cancel_button").click (e) ->
    e.preventDefault()
    $(this).parent().parent().find(".product_ops").show()
    $(this).parent().parent().find(".shrink_options").hide()
