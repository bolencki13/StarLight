// <div class="col-md-6">
//     <div class="feature-item">
//         <i class="icon-screen-smartphone text-primary"></i>
//         <h3>Set Up</h3>
//         <p class="text-muted">StarLight makes set up easy; attach the lights to a structure &amp; scan them from the StarLight app!</p>
//     </div>
// </div>
var xhttp = new XMLHttpRequest();
xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
        document.getElementById("database-contents").innerHTML = this.responseText;
    }
};
xhttp.open("GET", "database.php", true);
xhttp.send();
