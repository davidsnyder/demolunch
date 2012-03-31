$(document).ready(function() {

    registerOptionListener();
    
    $('.invite').val(window.location.href.split('://')[1]);    

    $('#vote-submit').hide();
    $('#search-input').hide();        
    $('#search-submit').hide();
    $('.option .radio').hide();    
    
    $("#search-input").autocomplete({
	source: function(request, response) {
	    $.ajax({
                type: 'GET',
                dataType: "json",
		url: $('#search-form').attr("action"),
		data: $('#search-form').serialize(),
		success: function(search_results) {
		    response($.map(search_results.response.data,function(item){
                        item["label"]=item.name+" - "+item.address;
                        return item;
                    }));
		}
	    });
	},
        delay: 200,
	minLength: 3,
        select: function(event, ui) {
            if($("#"+ui.item.uuid).length > 0) {
                $("#"+ui.item.uuid).effect("highlight", {}, 1000);
                event.stopPropagation(); //dont close the menu
                event.preventDefault();
            }
            else {
                //var newOption = Mustache.to_html($("#option-template").html(),{option: ui.item,option_klass: $('#option-klass').attr('val')});        
                //$("#option-bars").append(newOption);
                var payload = {};
                var form = $('#ballot-form').serializeArray();
                for (attr in form) {
                    payload[form[attr].name] = form[attr].value;
                }
                payload["ballot[options_attributes]"] = ui.item;
                $.ajax({
                    type: 'PUT', 
                    url: $('#ballot-form').attr('action'),
                    data: payload, 
                    success: function(r){
                        $("#search-input").val("");
                        $("#search-input").hide();
                        $('.option-dialog').show();
                        registerOptionListener();                        
                    }           
                });
            }
            return false;                            
	}
    });
    
});

function registerOptionListener() {
    $('.option-inner').click(function(e){
        $("input:radio").attr('checked',false);
        $(this).children().find("input:radio").attr('checked',true);

        // $('.option-inner').removeClass('selected');
        // $(this).addClass('selected');

        $.ajax({
            type: 'POST', 
            url: $("#vote-form").attr("action"), 
            data: $('#vote-form').serialize(), 
            success: function(r){}
        });
    });

    $('a.option-details-btn').click(function(e){
        e.preventDefault();                                        
        var option_path = $(this).attr("href");
        $.ajax({
            type: 'GET', 
            url: option_path, 
            success: function(response){$("#detail").html(response);}
        });
    });

    $('.search-button').click(function(e){
        e.preventDefault();
        $('.option-dialog').hide();        
        $('#search-input').show();
        $('#search-input').focus();        
    });

  $('#search-input').blur(function(e){
       $(this).hide();        
       $('.option-dialog').show();
  });
    
}
