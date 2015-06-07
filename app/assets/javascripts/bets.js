// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// force number field to contain string that is formatted as a valid currency amount
function forceCurrency(event) {
	// remove disallowed chars
	this.value = this.value.replace(/[^0-9\.]/g, "");

	// if only showing a dollar amount, add decimal points to show cents
	var indexOfDecimal = this.value.indexOf(".");
	if (indexOfDecimal === -1) {
		this.value += ".00";
	}
	// if decimal is there, force exactly 2 digits after it
	else {
		var charsAfterDecimal = this.value.slice(indexOfDecimal + 1, this.value.length);
		
		// add zeroes to the end of value until there are exactly 2 digits there
		while (charsAfterDecimal.length < 2) {
			this.value += "0";
			charsAfterDecimal = this.value.slice(indexOfDecimal + 1, this.value.length);
		}

		// cut off any digits after decimal if more than 2
		this.value = this.value.slice(0, indexOfDecimal + 3);
	}

	// if value starts with decimal point, add a zero in front. It looks better
	if (this.value.charAt(0) == ".") {
		this.value = "0" + this.value;
	}
}

function initNumberField() {
	var numberField = document.querySelector('#bet_amount');
	forceCurrency.call(numberField);
}

$('#bet_amount').change(forceCurrency);

$(document).ready(initNumberField);
$(document).on('page:load', initNumberField);	