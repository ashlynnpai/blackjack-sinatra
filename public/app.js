$(document).ready(function(){
  player_hit();
  player_stay();
});
  
function player_hit() {
  $(document).on("click", "#hit", function() {
    alert("player hits!");
    $.ajax({
      type: 'POST',
      url: '/game/hit'
    }).done(function(msg){
      $("#main").replaceWith(msg);
    });
    return false;
  });
}

function player_stay() {
  $(document).on("click", "#stand", function() {
    alert("player stays!");
    $.ajax({
      type: 'POST',
      url: '/game/stand'
    }).done(function(msg){
      $("#main").replaceWith(msg);
    });
    return false;
  });
}

