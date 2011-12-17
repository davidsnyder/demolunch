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
              var searchResponse = "";
              r = JSON.parse(r);
              for(var id in r.response.data) {
                var obj = r.response.data[id];
                searchResponse += Mustache.to_html($("#search-row-template").html(),obj);        
              }
              $("#searches").html(searchResponse);
            }
        });
    });

    $('.invite').val(window.location.href.split('://')[1]);

});
