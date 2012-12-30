Templating
==========

SADE has adopted the new exist:templating system deployed with the *eXist-db*.
However, the system was extended/adapted to allow multiple projects and multiple templates.

As in the base templating system: 
`controller.xql` dispatches the requests, for `.html` resources by default to `view.xql`, fetching the correct template-view
and view.xql invokes the templating-processing. But there are following changes:

Project configuration
---------------------

The *controller* tries to determine the context-project (from the URI)
and get the **project configuration**. The project config refers to the template to be used for given project (`param@key='template'`).
With this information, the controller tries to fetch the correct template view to pass as request data to `view.xql`,
together with the `project-id` as request parameter `$project`. 
Finally, `view.xql` just starts the templating-processing by invoking `templates:apply($node,$model)`, 
where the template-view is passed in the `$node` parameter. (The `$model` parameter is empty at this point. 
It will be filled in `templates:init()`).

![Diagram of linking within template system](/tharman/SADE/raw/sade_modules/docs/templates_linking.png)

The *template-views* have to invoke a special function `templates:init()` in the root element, to have access to the project configuration. This function fetches the correct project configuration based on the `$project` parameter 
and puts it into the `$model` map, that is passed to all other functions invoked during the processing of the template-view.
The *config* module also provides a specialized function to access the config parameters: `config:param-value()`. (see inline-docs for more details)
This allows the module functions to access config parameters in an harmonized and encapsulated way, without having to know anything about the structure of the config file.
   function-templates_init.png

![Visual input-output representation of the function templates:init()](/tharman/SADE/raw/sade_modules/docs/function-templates_init.png)

![Visual input-output representation of the function config:param-value()](/tharman/SADE/raw/sade_modules/docs/function-config_param-value.png)


Path resolution
---------------

Furthermore, the `config` module provides functions for resolving relative paths. 
This functions are based on the original `config:resolve()` function already provided by the original templating code
and used especially in the `templates:include()` and `templates:surround()` functions.
This adapted function accepts (additionally to the relative path to be resolved) 
the project configuration (as entry in the `$model` map), and tries to fetch the resources relative to the project collection and projects' template collection (in that order).
Plus, there is the equivalent function `config:resolve-template-to-uri()`, that generates the correct uri for web-resources (.css, .js). This function is used by the `controller.xql`.

The aim of all this is to allow an intuitive linking in the template-views.
Both the template-view or html-snippets to be included as well as css and js files can be refered to exactly as they are found in the project and template collections.
