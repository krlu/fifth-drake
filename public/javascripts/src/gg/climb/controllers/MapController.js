'use strict';
var mc;
window.onload = function() {
    mc = new MapController();
    mc.init();
    var button = document.getElementById("test");
    button.onclick = mc.initializePlayers;
    var button2 = document.getElementById("test2");
    button2.onclick = mc.test2;
};

function MapController() {
    this.minimap            = null;
    this.game               = null;
    this.blueTeam           = null;
    this.redTeam            = null;
    this.timestampInstance  = null;
    this.timestampOffset    = null;
}

MapController.prototype = {
    constructor: MapController
};

MapController.prototype.test2 = function() {
    console.log(mc.blueTeam);
}

MapController.prototype.init = function() {
    //initailize

    this.timestampInstance  = 0;
    this.timestampOffset    = 0;
    var gameID              = "TSM TL G1.json";
    this.loadData(gameID);
}

MapController.prototype.initializePlayers = function() {
    // this.game = this.retrieveData();
    // iterate through all of the players and then put them onto the map
    MapController.prototype.movePlayersToCurrentInstance();
    mc.blueTeam = "Test";
}

MapController.prototype.loadData = function(gameID) {
    var xhr = new XMLHttpRequest();
    xhr.onload = this.saveData;
    xhr.open("GET", gameID, true);
    xhr.send();
}

MapController.prototype.saveData = function() {
    var json = JSON.parse(this.responseText);
    var response = json.map(function(timeStamp) {
        return {
            time:       timeStamp.t,
            blueTeam:   MapController.prototype.getBluePlayers(timeStamp.playerStats),
            redTeam:    MapController.prototype.getRedPlayers(timeStamp.playerStats)
        }
    });
    localStorage.setItem("coordinates", JSON.stringify(response))
}

MapController.prototype.retrieveData = function() {
    return JSON.parse(localStorage.getItem("coordinates"));
}

MapController.prototype.getPlayers = function(playerStats, isBlue) {
    var arr = [];
    var lo;
    var hi;
    if(isBlue) {
        lo = 1;
        hi = 5;
    } else {
        lo = 6;
        hi = 10;
    }
    for (var player in playerStats) {
        if (playerStats.hasOwnProperty(player)) {
            if (parseInt(player) >= lo && parseInt(player) <= hi) {
                arr.push({
                    x: playerStats[player]["x"],
                    y: playerStats[player]["y"],
                    championName: playerStats[player]["championName"],
                    playerName: playerStats[player]["summonerName"]
                })
            }
        }
    }
    return arr;
}

MapController.prototype.getBluePlayers = function(playerStats) {
    return this.getPlayers(playerStats, true);
}

MapController.prototype.getRedPlayers = function(playerStats) {
    return this.getPlayers(playerStats, false);
}

MapController.prototype.jumpToTimestamp = function(timestamp) {
    // do initial check to see if the timestamp is in the game bounds

    // do the timestamp setting
    this.timestampInstance = timestamp;
    MapController.prototype.movePlayersToCurrentInstance();

}

MapController.prototype.movePlayersToCurrentInstance = function() {
    // var localInstance = this.timestampInstance - this.timestampOffset;
    var localInstance = 0;
    this.game = MapController.prototype.retrieveData();
    this.game[localInstance].blueTeam.forEach(function(player) {
        MapController.prototype.drawIcon(player, "blue");
    });
    this.game[localInstance].redTeam.forEach(function(player) {
        MapController.prototype.drawIcon(player, "red");
    });
    this.timestampInstance++;
};

MapController.prototype.drawIcon = function(player, color) {
    console.log(player)
    var icon = document.getElementById(player.championName);
    var x = 512 * parseInt(player.x) / 15000;
    var y = 512 - (512 * parseInt(player.y) / 15000);
    if(icon) {
        icon.style.transform = "translate(" + x + "px, " + y + "px)";
    } else {
        var championName = player.championName;
        var mapContainer = document.getElementById("map");
        var imgURL = Player.prototype.getChampionUrl(championName);
        var divIcon = document.createElement("div");

        divIcon.setAttribute("id", championName);
        divIcon.setAttribute("style", "left:" + 0 + "px; top:" + 0 + "px; background-image: url(" + imgURL + ");"
            + "transform: translate(" + x + "px," + y + "px); border-color:" + color + ";");

        divIcon.classList.add("imageContainer");

        mapContainer.insertBefore(divIcon, mapContainer.childNodes[0]);
    }
}

function Team() {
    this.top        = null;
    this.jungle     = null;
    this.mid        = null;
    this.adc        = null;
    this.support    = null;
}

Team.prototype = {
    top:        Player,
    jungle:     Player,
    mid:        Player,
    adc:        Player,
    support:    Player
}
Team.prototype.init = function(rawTeam) {
    this.top        = this.getPlayer(rawTeam["top"]);
    this.jungle     = this.getPlayer(rawTeam["jungle"]);
    this.mid        = this.getPlayer(rawTeam["mid"]);
    this.adc        = this.getPlayer(rawTeam["adc"]);
    this.support    = this.getPlayer(rawTeam["support"]);
}

Team.prototype.getPlayer = function(data) {
    return new Player(data)
}

function Player(data) {
    this.x              = data.x;
    this.y              = data.y;
    this.championName   = data.champName;
    this.iconUrl        = this.getChampionUrl(data.championName);
    this.playerName     = data.playerName;
}

Player.prototype = {
    constructor: Player
}

Player.prototype.getChampionUrl = function(championName) {
    var baseURL = 'http://ddragon.leagueoflegends.com/cdn/6.8.1/img/champion/';
    var imgURL = baseURL + championName + ".png";
    return imgURL;
}