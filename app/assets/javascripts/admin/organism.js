/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
"use strict";
/*jslint browser: true */
/*global $, jQuery */

//var $, jQuery;



jQuery(function() {
  if ($('.admin_organisms #new_organism').length === 1) { // le formulaire de admin_organisms est affiché pour une création

  var opts = {
    lines: 13, // The number of lines to draw
    length: 7, // The length of each line
    width: 4, // The line thickness
    radius: 26, // The radius of the inner circle
    corners: 0.8, // Corner roundness (0..1)
    rotate: 0, // The rotation offset
    color: '#000', // #rgb or #rrggbb
    speed: 1, // Rounds per second
    trail: 60, // Afterglow percentage
    shadow: false, // Whether to render a shadow
    hwaccel: false, // Whether to use hardware acceleration
    className: 'spinner', // The CSS class to assign to the spinner
    zIndex: 2e9, // The z-index (defaults to 2000000000)
    top: 'auto', // Top position relative to parent in px
    left: 'auto' // Left position relative to parent in px
  };
    

    $('input.btn').click(function() {
      var target = document.getElementById('new_organism');
      var spinner = new Spinner(opts).spin(target);
    });

  }
})

