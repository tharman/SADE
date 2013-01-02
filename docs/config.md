Project Configuration
=====================
Every project has its own configuration stored in $projects/$project-id/config.xml

This provides project-specific information as parameters to the modules.
It has three levels of parameters:

    global
    module
    container/function

There is a tentative schema [config.xsd](/tharman/SADE/blob/sade_modules/schemas/config.xsd).
See also [boilerplate config](/tharman/SADE/blob/sade_modules/src/project-boilerplate/config.xml)


config:param-value()
--------------------

To ensure consistent access to the configuration information the config-module provides appropriate functions, that can be called by the modules to retrieve param-values.
