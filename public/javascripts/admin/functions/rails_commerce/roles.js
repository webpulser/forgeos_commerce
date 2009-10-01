/* Roles */

/* Plugin unwrap: remove an element around an other */
$.fn.unwrap = function() {
  this.parent(':not(body)')
    .each(function(){
      $(this).replaceWith( this.childNodes );
    });

  return this;
};