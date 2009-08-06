/*jquery.select_skin.js */
/*
 * jQuery select element skinning
 * version: 1.0.2 (17/01/2009)
 * @requires: jQuery v1.2 or later
 * adapted from Derek Harvey code
 *   http://www.lotsofcode.com/javascript-and-ajax/jquery-select-box-skin.htm
 * Licensed under the GPL license:
 *   http://www.gnu.org/licenses/gpl.html
 *
 * Copyright 2009 Colin Verot
 */


(function ($) {

    $.fn.select_skin = function (w) {
        return $(this).each(function(i) {
            s = $(this);

            // create the container
            s.wrap('<div class="cmf-skinned-select '+w['class']+'"></div>');
            c = s.parent();
            c.children().before('<div class="cmf-skinned-text">&nbsp;</div>').each(function() {
                if (this.selectedIndex >= 0) $(this).prev().text(this.options[this.selectedIndex].innerHTML)
            });
            c.width(s.outerWidth()-2);
            c.height(s.outerHeight()-2);

            // skin the container
            c.css('background-color', s.css('background-color'));
            c.css('position', 'relative');

            // hide the original select
            s.css( { 'opacity': 0,  'position': 'relative', 'z-index': 100 } );

            // get and skin the text label
            var t = c.children().prev();
            t.height(c.outerHeight()-s.css('padding-top').replace(/px,*\)*/g,"")-s.css('padding-bottom').replace(/px,*\)*/g,"")-t.css('padding-top').replace(/px,*\)*/g,"")-t.css('padding-bottom').replace(/px,*\)*/g,"")-2);
            t.width(c.innerWidth()-s.css('padding-right').replace(/px,*\)*/g,"")-s.css('padding-left').replace(/px,*\)*/g,"")-t.css('padding-right').replace(/px,*\)*/g,"")-t.css('padding-left').replace(/px,*\)*/g,"")-c.innerHeight());
            t.css('color', s.css('color'));
            t.css('font-size', s.css('font-size'));
            t.css('font-family', s.css('font-family'));
            t.css('font-style', s.css('font-style'));
            t.css( { 'opacity': 100, 'overflow': 'hidden', 'position': 'absolute', 'text-indent': '0px', 'z-index': 1, 'top': 0, 'left': 0 } );

            // add events
            c.children().click(function() {
                t.text(this.options[this.selectedIndex].innerHTML);
            });
            c.children().change(function() {
                t.text(this.options[this.selectedIndex].innerHTML);
            });
        });
    }
}(jQuery));

function add_rule(name){
  var rule = $('p.'+name+'.pattern').clone().show().removeClass('pattern');
  $('#'+name+'s').append(rule);
  check_remove_icon_status(name);
}
function remove_rule(element,name){
  if (!$(element).hasClass('disabled')) {
    $(element).parent().remove();
    check_remove_icon_status(name);
  }
}

function check_remove_icon_status(name){
  var c = $('#'+name+'s p.'+name);
  var icon = $('#'+name+'s p.'+name+' a.moins')[0];
  if (c.size() == 1) {
    $(icon).addClass('disabled'); 
  } else { 
    $(icon).removeClass('disabled');
  }
}

function change_rule(element, name){
  $(element).parent().replaceWith($('.rule-'+$(element).val().replace(/\s+/g,"")+'.pattern').clone().removeClass('pattern').removeClass('rule-'+$(element).val().replace(/\s+/g,"")).addClass('rule-condition'))
  check_remove_icon_status(name);
}

function change_select_for(element){
  if ($(element).val() != 'Category'){
    $('#rule_builder_target').hide()
    if ($(element).val() == 'Cart'){
      $('#rule-conditions').replaceWith("<div id='rule-conditions'></div>")
      $('#rule-conditions').append($('.rule-Totalitemsquantity.pattern').clone().removeClass('pattern').removeClass('rule-Totalitemsquantity').addClass('rule-condition')) 
    }
    else{
      $('#rule-conditions').replaceWith("<div id='rule-conditions'></div>")
      $('#rule-conditions').append($('.rule-condition.pattern').clone().removeClass('pattern'))
    }
  }
  else{
    $('#rule_builder_target').show()
    $('#rule-conditions').replaceWith("<div id='rule-conditions'></div>")
    $('#rule-conditions').append($('.rule-condition.pattern').clone().removeClass('pattern'))
  }
  check_remove_icon_status('rule-condition')
}

function change_action(element, name){
  $(element).parent().replaceWith($('.action-'+$(element).val().replace(/\s+/g,"")+'.pattern').clone().removeClass('pattern').removeClass('action-'+$(element).val().replace(/\s+/g,"")).addClass('action-condition'))
  check_remove_icon_status(name);
}

function add_cart_rule(){
  $('#rule-conditions').append($('.rule-Totalitemsquantity.pattern').clone().removeClass('pattern').removeClass('rule-Totalitemsquantity').addClass('rule-condition')) 
  check_remove_icon_status('rule-condition')
}

function SkinSelects(){
  $('select').select_skin({ class: 'ui-corner-all'});
}
