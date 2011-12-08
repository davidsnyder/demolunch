$(document).ready(function() {
                    var socket = io.connect('http://localhost',{port: 3000});
                    var votes = $('#votes');

                    socket.on('connect', function() {
                                console.log("Connected");
                              });

                    socket.on('message', function(message){
                                console.log(message);
                                votes.prepend(message + '<br />');
                              }) ;


                    socket.on('disconnect', function() {
                                console.log("Disconnected");
                              });

                  });
