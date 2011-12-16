$(document).ready(function() {
    $('#vote-submit').click(function(e) { 
        e.preventDefault(); 
        $.ajax({
            type: 'POST', 
            url: $("#vote-form").attr("action"), 
            data: $('#vote-form').serialize(), 
            success: function(r) {}
        });
    });

    $('#search-submit').click(function(e) { 
        e.preventDefault(); 
        $.ajax({
            type: 'GET', 
            url: $('#search-form').attr("action"), 
            data: $('#search-form').serialize(), 
            success: function(r) {
                $("#searches").prepend(r + '<br />');                }
        });
    });

     $('.invite').val(window.location.href.split('://')[1]);

     $('#option-template').hide();

});
