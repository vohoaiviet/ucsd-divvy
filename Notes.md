# SVN #

For Xcode projects, add "`*`.pbxuser `*`.mode1v3 build" to the global-ignores line in ~/.subversion/config. This removes user-specific settings in the project file as well as build files from svn status, etc.

After adding a repository, the initial checkout, opening the associated project, and configuring SCM, Xcode doesn't show the full SCM menu until Xcode is restarted.

After updating to Xcode 4, do the first commit from the command line so that you can permanently accept Google's SSL certificate. Actually it turns out that after upgrading to Lion (and maybe before, but it started causing trouble in Xcode 3.2 after the upgrade) ~/.subversion is owned by root, causing endless "Do you accept this SSL certificate?" messages. Running "sudo chown -R your\_user\_name:staff .subversion" in the home directory fixed this problem. Here's the [relevant link](http://chipsandtv.com/articles/svn-invalid-certificates).

# OpenCL #

clGetDeviceInfo often returns incorrect CPU and GPU details, such as CPU count & GPU memory stats.

# Xcode #

C source in a separate bundle/plugin target blows up by default. For now we're including Divvy\_Prefix.pch in the DivvyPlugin framework and using that as the precompiled header for all bundles. Alternatively one can mark the c file as objc as described in [this thread](http://lists.apple.com/archives/xcode-users/2009/Mar/msg00199.html).

Xcode 4 apparently has a bug where every time you click on a data model it modifies it (becomes unsaved and once saved wants to be recommitted to SVN).