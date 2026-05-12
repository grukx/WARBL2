#!/bin/bash

uglifyjs -- js/midi.js > js/midi.min.js
uglifyjs -- js/constants.js > js/constants.min.js
uglifyjs -- js/synth.js > js/synth.min.js
uglifyjs -- js/nouislider.js > js/nouislider.min.js

uglifycss css/config.css > css/config.min.css
  
