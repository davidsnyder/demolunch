$(document).ready(function() {

    registerOptionListener();

    $("#more-options").hide();
    $("#reveal-options").click(function(e){ $(this).hide(); $("#more-options").show(); });
    
    $('.invite').val(window.location.href.split('://')[1]);    

    $('#vote-submit').hide();
    $('.option .radio').hide();    
});

function registerOptionListener() {
    $('.option-inner').click(function(e){
        $("input:radio").attr('checked',false);
        $(this).children().find("input:radio").attr('checked',true);

        $.ajax({
            type: 'POST', 
            url: $("#vote-form").attr("action"), 
            data: $('#vote-form').serialize(), 
            success: function(r){}
        });
    });
}
