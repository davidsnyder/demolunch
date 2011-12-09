$(document).ready(function() {

                    var socket = io.connect('http://localhost',{port: 3000});
                    var votes = $('#votes');
                    var url = window.location.href.split('://')[1].split('/'); //should insert this some other way?
                    var meal_id = url[url.length-1];

                    socket.on('connect', function() {
                                socket.emit('join', meal_id );
                                console.log(meal_id);
                              });

                    socket.on('vote', function(message){
                                votes.prepend(message + '<br />');
                              }) ;

                    socket.on('disconnect', function() {
                                console.log("Disconnected");
                              });
                  });
