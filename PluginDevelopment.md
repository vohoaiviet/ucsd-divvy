# General comments #
  * The prefix header for the plugin needs to be set to Divvy\_Prefix.pch (in the plugin's build settings)
  * C source files need extension .c (not .cpp)
  * When creating new classes and C source files, make sure they don't get added to the Divvy application target (uncheck that target in the creation dialog)

# Required resources #
  * The main plugin class DivvyYourPluginName (e.g. DivvyPCA), it must conform to one and only one of the plugin protocols and derive from NSManagedObject
  * The controller class for the UI DivvyYourPluginNameController, it derives from NSViewController
  * The UI DivvyYourPluginName.xib
  * The property list DivvyYourPluginName-Info.plist
  * The data model DivvyYourPluginName.xcdatamodel
  * These should all be assigned to a loadable bundle target in Xcode called DivvyYourPluginName, and compile to DivvyYourPluginName.plugin (not the .bundle default)

# Data Model #
  * At least one entity called YourPluginName
  * YourPluginName entity is assigned to the DivvyYourPluginName configuration (in wrench segment of rightmost panel of the data modeling tool in Xcode)
  * YourPluginName entity is assigned the class DivvyYourPluginName

# Property List #
  * "Main nib file base name" is DivvyYourPluginName
  * "Principal class" is DivvyYourPluginName
  * You will have to add these entries to the plist

# UI #
  * "Raises For Not Applicable Keys" must **not** be checked in any bindings to parameters of your plugin
  * The class identity (in the rightmost identity panel) of the File's Owner should be set to DivvyYourPluginNameController
  * File's Owner's view outlet needs to be connected to the custom view in the .xib