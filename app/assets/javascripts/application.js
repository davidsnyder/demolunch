$(document).ready(function() {

    registerOptionListener();

    $('#vote-submit').hide();

    $('#search-submit').click(function(e) { 
        e.preventDefault(); 
        $.ajax({
            type: 'GET', 
            url: $('#search-form').attr("action"), 
            data: $('#search-form').serialize(), 
            success: function(r){
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
    
    $('.option .radio').hide();

    $('.invite').val(window.location.href.split('://')[1]);

});

function registerOptionListener() {
    console.log("here");
    $('.option').click(function(e){
        $("input:radio").attr('checked',false);
        $('.option').removeClass('selected');

        $(this).children().find("input:radio").attr('checked',true);
        $(this).addClass('selected');
        $.ajax({
            type: 'POST', 
            url: $("#new_vote").attr("action"), 
            data: $('#new_vote').serialize(), 
            success: function(r){}
        });
    });
}
