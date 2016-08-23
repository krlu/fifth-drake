'use strict';
class VideoController {
};


//Load iFrame API code
var tag = document.createElement('script');
tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

//Create player after API code is done downloading.
var player;

function onYouTubeIframeAPIReady() {
    player = new YT.Player('player', {
      height: '200',
      width: '300',
      videoId: 'rkqBZx1c11s',
      events: {
        //Trigger this upon creation of player.
      }
    });
}

function seek(sec){
    if(player){
        player.seekTo(sec, true);
    }
}

function jump() {

    var sec = document.getElementById("timeJump").value;
    if(player){
        player.seekTo(sec, true);
    }
}

function jumpVideo() {
    var sec = document.getElementById("value").value
    if (player) {
        player.seekTo(sec, true);
    }
}






