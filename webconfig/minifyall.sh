#!/bin/bash

uglifyjs -- js/midi.js > js/midi.min.js
uglifyjs -- js/constants.js > js/constants.min.js

uglifycss css/config.css > css/config.min.css
  
