function $check_sold(){
    if (($('#lines_begin_sold').text() == $('#begin_sold').text()) &&
        ($('#total_lines_debit').text() == $('#total_debit').text()) &&
        ($('#total_lines_credit').text() == $('#total_credit').text())  )
        {
        $('#lines_sold').css('background-color', '#5f0');
        $('#verrouiller').show();
    }
    else
    {
        $('#lines_sold').css('background-color', '#9c9');
        $('#verrouiller').hide();
    }

}

jQuery(function (){
    $check_sold();

    $('td.clickable').click(function(){
        $(this).parent().find(':submit').click();
    });

    $('.pointage .button').hide();

});