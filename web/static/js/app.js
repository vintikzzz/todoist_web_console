// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import "jquery.terminal"

const term = $('#term');
if (term.length > 0) {
  const name = $('#term').data('user');
  const url = $('#term').data('url');
  $('#term').terminal(function(command, term) {
    term.pause();
    $.post(url, {command: command}).then(function(response) {
      if (response !== null) {
        term.echo(JSON.stringify(response, null, '  '), {
          finalize: function(div) {
            div.css("color", "yellow");
          }
        }).resume();
      } else {
        term.echo().resume();
      }
    });
  }, {
      greetings: `You are authenticated as ${name}`,
      prompt: 'inbox> '
  }).focus();
}

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
