Templating
==========

SADE has adopted the new exist:templating-system deployed with eXist-db.
However, to allow multiple projects and multiple templates, the system was extended/adapted.

As in the base templating-system: 
Controller.xql dispatches the requests, by default to view.xql, fetching the correct template-view.
And view.xql invokes the templating-processing.

But there are following changes:
The controller tries to determine the context-project (from the URI)
and get the **project configuration**. The project config refers to the template to be used for given project (`param@key='template'`).
With this information, the controller tries to fetch the correct template view to pass as request data to `view.xql`,
together with the `project-id` as request parameter `$project' 

The `template-views` have to invoke a special function `templates:init()` in the root element, to have access to the project configuration. This function fetches the correct project configuration based on the `$project` parameter 
and puts it into the `$model`-map, that is passed to all other functions invoked during the processing of the template-view.
The config-module provides a specialized function to access the config-parameters: config:param-value()
This allows these functions to access config parameters in an harmonized and encapsulated way, without having to know anything about the structure of the config-file.

Furthermore, the config-module also provides functions for resolving relative paths. 
This is an adapted version of the config:resolve() function already provided by the original templating-system
and used especially in the templates:include() and templates:surround() functions.
This adapted function accepts (additionally to the relative path to be resolved) the project-configuration (as $model-map), and tries to fetch the resources relative to the project-collection and projects' template-collection (in that order).
There are further equivalent functions, that try to generate the correct uri for web-resources (.css, .js) to be used by the controller.

The aim of all this is to allow an intuitive linking in the template-views.
Both the template-view or html-snippets to be included as well as css and js files can be refered to exactly as they are found in the project and template-collection.


TODO: Example!