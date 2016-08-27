'use strict';
class VideoController {
};

//Create player after API code is done downloading.
var player;
var videoId = 'eQ1tJgmNlj4'

function loadVod(newId){
    videoId = newId
    console.log(videoId)
    //Load iFrame API code
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    onYouTubeIframeAPIReady()
}

function onYouTubeIframeAPIReady() {
    player = new YT.Player('player', {
      height: '400',
      width: '600',
      videoId: videoId,
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

function jumpVideo() {
    var sec = document.getElementById("value").value
    if (player) {
        player.seekTo(sec, true);
    }
}






