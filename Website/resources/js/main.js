function loadPosts(elementName) {
    var client = new XMLHttpRequest();
    client.open('GET', './resources/feeds/home.json');
    client.onreadystatechange = function() {
        if (!client.responseText) return;
        var element = document.getElementById(elementName);
        while (element.firstChild) {
            element.removeChild(element.firstChild);
        }
        var aryJSON = JSON.parse(client.responseText);
        for (var i = aryJSON.length-1; i >= 0; i--) {
            document.getElementById(elementName).appendChild(JSONToHTML(aryJSON[i]));
        }
    }
    client.send();
}
function JSONToHTML(json) {
    var card = document.createElement("div");
    card.className = "card-content mdl-card mdl-shadow--2dp";

    if (json.hasOwnProperty("image-url")) {
        card.style.background = "url('"+json['image-url']+"') center / cover";
    }
    if (json.hasOwnProperty("video-url")) {
        var video = document.createElement("iframe");
        video.src = json['video-url'];
        video.frameborder = "0";
        card.appendChild(video);
    }

    var title = document.createElement("div");
    title.className = "mdl-card__title mdl-card--expand";
    title.innerHTML = "<h2 class='mdl-card__title-text'></h2>";
    if (json.hasOwnProperty("title")) {
        title.innerHTML = "<h2 class='mdl-card__title-text'>"+json['title']+"</h2>";
    }
    card.appendChild(title);

    var content = document.createElement("div");
    content.className = "mdl-card__supporting-text";
    if (json.hasOwnProperty("content")) {
        content.innerHTML = json['content'];
    }
    card.appendChild(content);

    if (json.hasOwnProperty("button")) {
        var action = "";
        if (json.hasOwnProperty("button-url")) {
            action = json['button-url'];
        }
        var button = document.createElement("div");
        button.className = "mdl-card__actions mdl-card--border";
        button.innerHTML = "<a class='mdl-button mdl-button--colored mdl-js-button' href='"+action+"'>"+json['button']+"</a>";
        card.appendChild(button);
    }

    return card;
}
function resetMenu() {
    var query = window.location.search.substring(1);
    if (query == "purchase") {
        document.getElementById('purchase-panel-link').click();
    } else if (query == "home") {
        document.getElementById('home-panel-link').click();
    }
}
