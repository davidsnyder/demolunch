$(document).ready(function() {

    var socket = io.connect('http://localhost',{port: 3000});
    var votes  = $('#votes');
    
    var url = window.location.href.split('://')[1].split('/'); //should insert this some other way?
    var session_id = url[url.length-1];
    
    var session = {}; 
    var paths   = {};
    var labels  = {};
    var keys    = [];
    
    socket.on('connect', function() {
        socket.emit('join', session_id );
        $.ajax({
            type: 'GET', 
            url: session_id+'.json',
            success: function(ballot){
                session = ballot;
                animate(800);
            }
        });
        
    });

    socket.on('vote', function(ballot){
        session = JSON.parse(ballot);
        var optionBars = "";
        for(var option_id in session.options) {
            optionBars += Mustache.to_html($("#option-template").html(),{option:session.options[option_id]});        
            $("#option-bars").html(optionBars);
        }
        registerOptionListener();
        animate(800); //update the piechart 
    });

    socket.on('disconnect', function() {
        console.log("Disconnected");
    });

    var r = Raphael("holder",700,400);
    var bg = r.circle(300,300,0).attr({stroke: "#fff", "stroke-width": 4});        

    r.customAttributes.segment = function (x, y, r, a1, a2) {
        var flag = (a2 - a1) > 180,
        color = (a2 - a1) / 360;
        a1 = (a1 % 360) * Math.PI / 180;
        a2 = (a2 % 360) * Math.PI / 180;
        return {
            path: [["M", x, y], ["l", r * Math.cos(a1), r * Math.sin(a1)], ["A", r, r, 0, +flag, 1, x + r * Math.cos(a2), y + r * Math.sin(a2)], ["z"]],
            fill: "hsb(" + color + ", .75, .8)"
        };
    };

    function animate(ms) {
        var start = 0,
        keys = [],
        delta = 10,
        rad = Math.PI / 180,
        offset;

        if(session.total_votes > 0) {
            
            for(var key_id in session.options) {
                if(session.options[key_id].votes.length == 0) {
                    delete session.options[key_id];
                } else {
                    keys.push(key_id);
                }
            }
            keys.sort();
            
            for(var path_id in paths) {
                if(!(path_id in session.options)) {
                    keys.push(path_id);
                }
            }
            
            var prev_end = 0;
            for(var i=0; i < keys.length; i++) {
                var id = keys[i];
                // this loop processes all old and new keys, so that when a slice disappears, it disappears into the angle that its neighbors squeeze it into.
                if(session.options[id] == undefined) { //wink out null slices
                    var current_end = paths[id].attrs['segment'][4];
                    paths[id].animate({segment: [350, 200, 100,start,start]}, ms || 1500,'',function(){this.remove()});
                    labels[id].animate({opacity:0}, 0,'',function(){this.remove();});
                    delete labels[id];
                    delete paths[id];
                    continue; // bad form, carlos. *tsk tsk*. Seriously though, this is kind of gross and needs to be noted to minimize future headaches.
                }
                offset = 360 / session.total_votes * (session.options[id].votes.length * 0.999999); //FIXME: the whole pie disappears if this is exactly 360?
                if(offset > 0) {
                    if(!(paths[id] == undefined)) {
                        // we only care to record the previous segment's end if they were already in the pie
                        prev_end = paths[id].attrs['segment'][4];
                        labels[id].animate({opacity:0}, 0,'',function(){this.remove();}); //remove any existing label
                        delete labels[id];                
                    }
                    else {
                        // rationale with going to prev_end: prev_end is the angle that the future neighbors of the newborn slice were meeting at.
                        // prev_end is arguably a deceptive name given that it corresponds to the new placement of the previous segment, not the previous placement of the current slice.
                        paths[id] = r.path().attr({segment: [350, 200, 100, prev_end, prev_end], stroke: "#fff"}).click(function() { //create a new segment for this id
                            //TODO: send vote on click / do something else
                            animate();
                        });
                    }
                    paths[id].animate({segment: [350, 200, 100, start, start + offset]}, ms || 1500);  //animate yourself to this new segment size            
                    labels[id] = r.text(350 + (150 + delta + 55) * Math.cos((start+(offset/2)) * rad), 200 + (150 + delta + 25) * Math.sin((start+(offset/2)) * rad), session.options[id].name).attr({fill: "#000", stroke: "none", opacity: 1, "font-size": 20});
                    start+=offset;            
                    paths[id].angle = start - offset / 2;
                }
            }
        }
    }
    
});
