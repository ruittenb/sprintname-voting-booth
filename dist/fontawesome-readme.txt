
FONTAWESOME

http://antenna.io/demo/jquery-bar-rating/examples/

CONFIGURATION

theme: ''
	Defines a theme.

initialRating: null
	Defines initial rating.
	The default value is `null`, which means that the plugin will try to set the initial rating by finding an option with a `selected` attribute.
	Optionally, if your ratings are numeric, you can pass a fractional rating here (2.5, 2.8, 5.5). Currently the only theme that supports displaying of fractional ratings is the `fontawesome-stars-o` theme.
	
allowEmpty: null
	If set to true, users will be able to submit empty ratings.
	The default value is `null`, which means that empty ratings will be allowed under the condition that the select field already contains a first option with an empty value.
	
emptyValue: ''
	Defines a value that will be considered empty. It is unlikely you will need to modify this setting.
	
showValues: false
	If set to true, rating values will be displayed on the bars.
	
showSelectedRating: true
	If set to true, user selected rating will be displayed next to the widget.
	
deselectable: true
	If set to true, users will be able to deselect ratings.
	
	For this feature to work the `allowEmpty` setting needs to be set to `true` or the select field must contain a first option with an empty value.
	
reverse: false
	If set to true, the ratings will be reversed.
	
readonly: false
	If set to true, the ratings will be read-only.
	
fastClicks: true
	Remove 300ms click delay on touch devices.
	
hoverState: true
	Change state on hover.
	
silent: false
	Supress callbacks when controlling ratings programatically.
