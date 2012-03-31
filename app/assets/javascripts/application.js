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
    
    if(!$('a.option-details-btn').data("events")) {
        $('a.option-details-btn').click(function(e){
            e.preventDefault();                                        
            var option_path = $(this).attr("href");
            var that = $(this);
            if($(this).parent().children(".option-details").html().length == 0) {
                $.ajax({
                    type: 'GET', 
                    url: option_path, 
                    success: function(response){
                        that.children().removeClass("arrow-r");
                        that.children().addClass("arrow-d");                                        
                        var newOption = Mustache.to_html($("#search-row-template").html(),{option: response});        
                        that.parent().children(".option-details").append(newOption);
                    }});
            }
            else if($(this).parent().children(".option-details").is(":hidden")){
                $(this).parent().children(".option-details").show(); 
                $(this).children().removeClass("arrow-r");
                $(this).children().addClass("arrow-d");                                        
            }
            else {
                $(this).parent().children(".option-details").hide();
                $(this).children().removeClass("arrow-d");
                $(this).children().addClass("arrow-r");                                        
            }
        });
    }

    $('.search-button').click(function(e){
        e.preventDefault();
        $('.option-dialog').hide();  
        $('#search-input').show();
        $('#search-input').focus();
        $('.option-details-btn .plus-sign').hide();        
    });

  $('#search-input').blur(function(e){
       $(this).hide();        
       $('.option-dialog').show();
       $('.option-details-btn .plus-sign').show();        
  });
    
}
