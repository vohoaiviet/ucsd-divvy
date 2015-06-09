# Divvy Core #

  * Sort consistency and persistence for the datasets panel
  * Ability to remove a dataset view
  * Fix bug where a plugin can't be added after a persistent store is already present
  * Send processing to another thread when updating a dataset view, and replace its image temporarily with a working image
  * Get rid of all the ...InDefaultContext constructors and replace with appropriate awakeFromInsert and awakeFromFetch code.

# Plugins #

  * Full UI and feature implementation for existing plugins
  * None plugins for point and dataset visualizers
  * Spectral clustering
  * Isomap / MVU?
  * Image point visualizer

# Outreach #
  * Create a Divvy demo video using some compelling sample datasets (MNIST, ??)
  * Launch divvy.ucsd.edu
  * Provide scripts to move data out of common apps into Divvy

# Long Term #
  * Click to visualize outliers
  * Labeled dimensions?