Modules
=======

All specific functionality of SADE shall be provided by separate modules.
The core scripts only deliver the basic infrastructure, glue between project, template and modules.

A module has to deliver a descriptor - a kind of interface description - an xml-file describing the exposed functionality and required dependencies, especially also webscripts (.js, .css).


Issues
------
Module configuration - How to configure modules and ensure their availability to the templating-system. (https://telotadev.bbaw.de/redmine/issues/1501)


Module import (dynamic vs. static)
----------------------------------

Dynamic modules import is basically possible (with `util:import-module()` function),  
but it makes development/debugging near to impossible, so it seems preferable to import modules statically, preferably generating the import-declarations upon module installation.


Shared modules
--------------

How to deal with code shared between different modules (like jquery or some xslt-scripts)?
Proposed solution:
Start embedded in one module, extract to a separate module, when needed by multiple modules.
However, the overhead and added complexity of shared modules has to be taken into account.
So it may be preferable to rather double the code in some cases.

First candidates for shared modules are jQuery and perhaps a set of basic xslt-scripts.


List of (planned) modules
-------------------------


Here a basic set of modules:
; navigation
: allow configuration and management on various indexes on the data and their display in the user interface
; search
; text-viewer
: allows to navigate through pages, indexes, text
: (has to interact with image-viewer to sync navigation) 
; image-viewer 
: integrate the digilib library to display images  (as a servlet) 
; teixslt
: XSLT-stylesheets for TEI by Sebastian Rahtz ([ http://www.tei-c.org/Tools/Stylesheets/ tei-c.org])

Following is a list of discussed/planned modules:

;Timeline/Timemap
: displaying data over time and space (e4d)
; user
: user management
; i18n 
: internationalization
; diagnostics
: a harmonized approach to error-handling/messaging
: possibly base on [http://www.loc.gov/standards/sru/specs/diagnostics.html sru:diagnostics]
; OAI-PMH provider 
; FCS REST-interface
: provide an (read-only) REST-interface to search in the data, compliant with the ([http://www.loc.gov/standards/sru/index.html SRU]-based) [http://clarin.eu/fcs (CLARIN) Federated Content Search effort]
; FCS reader/aggregator
: provide an interface able to read foreign FCS-interfaces