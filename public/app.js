$(document).ready(function(){
  player_hit();
  player_stay();
  test();
});


function player_hit() {
  $(document).on("click", "#hit", function() {
    $.ajax({
      type: 'POST',
      url: '/game/hit'
    }).done(function(msg){
      $(".main").replaceWith(msg);
    });
    return false;
  });
}

function player_stay() {
  $(document).on("click", "#stand", function() {
    $.ajax({
      type: 'POST',
      url: '/game/stand'
    }).done(function(msg){
      $(".main").replaceWith(msg);
    });
    return false;
  });
}

function test(){
  $(document).on("click", "#test", function() {
    alert('test');
    $('.avatar-container').html('test');
    });
}

/*
function avatarOne(){
  $(document).on("click", "#avatar1", function() {
    $('.avatar-container').html('<img src="/images/avatar1.png" /> ');
    });
}

function avatarTwo(){
  $(document).on("click", "#avatar2", function() {
    $('.avatar-container').html('<img src="/images/avatar2.png" /> ');
    });
}

function avatarThree(){
  $(document).on("click", "#avatar3", function() {
    $('.avatar-container').html('<img src="/images/avatar3.png" /> ');
    });
}
*/

