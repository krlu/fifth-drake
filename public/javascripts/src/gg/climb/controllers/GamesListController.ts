'use strict';
class GamesListController {
};

// returns
function filterBy(){
    var team = document.getElementById("team").value
    var filteredGids = []
    for(var i = 0; i < myGids.length; i += 1){
        if(myGids[i]["team1"] == team || myGids[i]["team2"] == team){
            filteredGids.push(myGids[i])
        }
    }
    makeList(filteredGids)
}

function makeList(gids){
    var m = "";

    // Right now, this loop only works with one
    // explicitly specified array (options[0] aka 'set0')
    for(var i = 0; i < gids.length; i += 1){
        var gameData = gids[i]["team1"] + " vs " + gids[i]["team2"]+ " " + gids[i]["gameDate"]
        var linkData = '<a href=/lol/games/id/' + gids[i]["gameKey"] + '/' + gids[i]["vodURL"]
        + ' class=\"list-group-item\">'
        m += '<li class="list-group-item">' + linkData + gameData + '<a></li>';
    }

    document.getElementById('gamesList').innerHTML =  m ;
}
