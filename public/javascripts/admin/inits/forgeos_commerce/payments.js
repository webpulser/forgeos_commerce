jQuery(document).ready(function(){

	var icons = {
		header: "ui-icon-circle-arrow-e",
		headerSelected: "ui-icon-circle-arrow-s"
		};
		$( "#accordion_payments" ).accordion({
			icons: icons,
			collapsible: true,
			active: false,
			autoHeight: false
		});

});
