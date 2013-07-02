"use strict";
/*jslint browser: true */
/*global $, jQuery */


$(document).ready(function () {
    $('#new_archive').submit(function () {
      blockUIForDownload();
    });
  });

  var fileDownloadCheckTimer;
 function blockUIForDownload() {
    var token = new Date().getTime(); //use the current timestamp as the token value
    
    $('#download_token_value_id').val(token);
    $('.inner-champ').block({ message: '<h1><img src="/assets/loading.gif" /> Juste un instant...</h1>' });
    // $.blockUI();
    fileDownloadCheckTimer = window.setInterval(function () {
      var cookieValue = $.cookie('file_archive_token');
      if (cookieValue == token)
       finishDownload();
    }, 1000);
  }


 function finishDownload() {
 window.clearInterval(fileDownloadCheckTimer);
 $.removeCookie('file_archive_token', { path: '/' }); //remove the cookie
 $('.inner-champ').unblock();
 
}
