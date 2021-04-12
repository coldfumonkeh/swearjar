/**
* Matt Gifford, Monkeh Works
* https://www.monkehworks.com
* ---
* This module introduces swearjar, a CFML profanity detection and filtering component library, to your ColdBox application
**/
component {

	// Module Properties
	this.title 				= "SwearJar";
	this.author 			= "Matt Gifford";
	this.webURL 			= "https://www.monkehworks.com";
	this.description 		= "A CFML profanity detection and filtering component library";
	this.version			= "@version.number@+@build.number@";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= false;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = false;
	this.modelNamespace		= 'swearjar';
	this.cfmapping			= 'swearjar';
	this.autoMapModels 		= false;

	/**
	 * Configure
	 */
	function configure(){
        // Settings
        settings = {
            libraryFilePath = './config/en_US.json'
        }
    }

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){
		// Map Library
        binder.map( "swearjar@swearjar" )
			.to( "#moduleMapping#.swearjar" )
            .initArg( name="libraryFilePath", value=settings.libraryFilePath );
	}

}
