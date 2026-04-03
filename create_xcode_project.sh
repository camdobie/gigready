#!/bin/bash

# Create GigReady.xcodeproj directory structure
mkdir -p GigReady.xcodeproj/project.xcworkspace/xcshareddata
mkdir -p GigReady.xcodeproj/xcuserdata

# Create a basic xcworkspace
cat > GigReady.xcodeproj/project.xcworkspace/contents.xcworkspacedata << 'WORKSPACE'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace version = "1.0">
   <FileRef location = "group:GigReady.xcodeproj">
   </FileRef>
</Workspace>
WORKSPACE

# Create IDEWorkspaceChecks
cat > GigReady.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>IDEDidComputeMac32BitWarningInWorkspace</key>
    <true/>
</dict>
</plist>
PLIST

echo "Xcode project structure created!"
