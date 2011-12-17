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
    });

    function voteString(votes) {
        var voters = [];
        for(vote_i in votes) {
            voters.push(votes[vote_i].name);
        }
        return voters.join(', ');
    }

    socket.on('vote', function(message){ 
        session = JSON.parse(message);
        var optionBars = "";
        var option;
        for(var id in session.options) {
            option = {
                fraction: (session.options[id].votes.length / session.total_votes * 100),
                voters: voteString(session.options[id].votes),
                name: session.options[id].name,
                id: id
            };
            optionBars += Mustache.to_html($("#option-template").html(),option);        
            $("#option-bars").html(optionBars);
        };
        animate(800); //update the piechart
    });

    socket.on('disconnect', function() {
        console.log("Disconnected");
    });

    var r = Raphael("holder");

    var bg = r.circle(300, 300, 0).attr({stroke: "#fff", "stroke-width": 4});        

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
        delta = 30,
        rad = Math.PI / 180,
        offset;
        
        for(var id in paths) {
            if(!(id in session.options)) {
                keys.push(id);
            }
        }

        for(var id in session.options) {
            keys.push(id);
        }
        keys.sort();
        
        var prev_end = 0;
        for(var i=0; i < keys.length; i++) {
            var id = keys[i];

            // this loop processes all old and new keys, so that when a slice disappears, it disappears into the angle that its neighbors squeeze it into.
            if(session.options[id] == undefined) { //wink out null slices
                var current_end = paths[id].attrs['segment'][4];
                paths[id].animate({segment: [300, 300, 150,start,start]}, ms || 1500,'',function(){this.remove()});
                labels[id].animate({opacity:0}, 0,'',function(){this.remove()});
                delete labels[id];
                delete paths[id];
                continue; // bad form, carlos. *tsk tsk*. Seriously though, this is kind of gross and needs to be noted to minimize future headaches.
            }
            offset = 360 / session.total_votes * (session.options[id].votes.length * 0.999999); //FIXME: the whole pie disappears if this is exactly 360?
            if(!(paths[id] == undefined)) {
                // we only care to record the previous segment's end if they were already in the pie
                prev_end = paths[id].attrs['segment'][4];
                labels[id].animate({opacity:0}, 0,'',function(){this.remove()}); //remove any existing label
                delete labels[id];                
            }
            else {
                // rationale with going to prev_end: prev_end is the angle that the future neighbors of the newborn slice were meeting at.
                // prev_end is arguably a deceptive name given that it corresponds to the new placement of the previous segment, not the previous placement of the current slice.
                paths[id] = r.path().attr({segment: [300, 300, 150, prev_end, prev_end], stroke: "#fff"}).click(function() { //create a new segment for this id
                    //TODO: send vote on click / do something else
                    animate();
                });
            }
            paths[id].animate({segment: [300, 300, 150, start, start + offset]}, ms || 1500);  //animate yourself to this new segment size            
            labels[id] = r.text(300 + (150 + delta + 55) * Math.cos((start+(offset/2)) * rad), 300 + (150 + delta + 25) * Math.sin((start+(offset/2)) * rad), session.options[id].name).attr({fill: "#000", stroke: "none", opacity: 1, "font-size": 20});
            start+=offset;            
            paths[id].angle = start - offset / 2;            
        }
    }
});
