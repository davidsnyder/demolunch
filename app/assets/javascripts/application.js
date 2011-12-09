$(document).ready(function() {
    $('#vote-submit').click(function(e) { 
        e.preventDefault(); 
        $.ajax({
            type: 'POST', 
            url: '/socket_test', 
            data: $('#vote-form').serialize(), 
            success: function(r) {}
        });
    });
});
