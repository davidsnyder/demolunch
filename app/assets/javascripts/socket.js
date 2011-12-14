$(document).ready(function() {

    var socket = io.connect('http://localhost',{port: 3000});
    var votes  = $('#votes');
    
    var url = window.location.href.split('://')[1].split('/'); //should insert this some other way?
    var meal_id = url[url.length-1];
    
    var session = {}; 
    var paths   = {};
    var keys    = [];
    
    socket.on('connect', function() {
        socket.emit('join', meal_id );
    });

    socket.on('join_confirm', function(message) { //render the piechart
        session = JSON.parse(message);
        votes.prepend(message + '<br />');                
        var bg = r.circle(200, 200, 0).attr({stroke: "#fff", "stroke-width": 4});
        animate();
    });

    socket.on('vote', function(message){ //update the piechart
        session = JSON.parse(message);
        votes.prepend(message + '<br />');        
        animate();
    });

    socket.on('disconnect', function() {
        console.log("Disconnected");
    });

    //TODO: pull Raphael init stuff out somewhere else

    var r = Raphael("holder");

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
        offset;
        
        for(var id in paths) {
            if(session.votes[id] == undefined) { //wink out null slices
                var current_end = paths[id].attrs['segment'][4];
                paths[id].animate({segment: [200, 200, 150,current_end,current_end]}, ms || 1500,'',function(){this.remove()});
                delete paths[id];
            }
        }

        for(var id in session.votes) {
            keys.push(id);
        }
        keys.sort();
        
        for(i=0; i < keys.length; i++) {
            var id = keys[i];
            offset = 360 / session.total * (session.votes[id].length * 0.999999); //FIXME: the whole pie disappears if this is exactly 360?
            if(!(paths[id] == undefined)) {
                paths[id].animate({segment: [200, 200, 150, start, start+=offset]}, ms || 1500);  //animate yourself to this new segment size
                paths[id].angle = start - offset / 2;
            }
            else {
                paths[id] = r.path().attr({segment: [200, 200, 150, start, start], stroke: "#fff"}).click(function() { //create a new segment for this id
                    //TODO: send vote on click / do something else
                    animate();
                });
                //TODO: Figure out how to draw labels
                paths[id].animate({segment: [200, 200, 150, start, start += offset]}, ms || 1500);  //animate yourself to this new segment size
                paths[id].angle = start - offset / 2;
            }
            
        }
    }
    
});
