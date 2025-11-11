Mobile Application Report — Meme Saver App
1. Real World Problem Identification
In today’s world, memes are one of the most common forms of entertainment and expression shared online. However, users often find it difficult to save their favorite memes for later viewing or to organize them in one place without using complex social media tools or manually saving images.
This lack of an easy-to-use meme-saving solution makes it inconvenient to store and view memes efficiently.
________________________________________

2. Proposed Solution
The proposed solution is the Meme Saver App, a Flutter-based mobile application that allows users to:
•	View and browse memes from different sources.
•	Save their favorite memes locally on the device.
•	View their saved memes anytime — even offline.
•	Delete saved memes when no longer needed.
The app focuses on simplicity, speed, and cross-platform usability, working equally well on Android and iOS.
________________________________________

3. Responsive User Interfaces
The Meme Saver app uses Flutter’s responsive layout system, ensuring proper scaling and display on different screen sizes and devices (phones and tablets).
All UI components adjust automatically based on device dimensions using widgets like Expanded, GridView, and MediaQuery.

________________________________________

4. Data Storage
The app uses Hive, a lightweight and high-performance local database for Flutter.
Justification for using Hive:
•	Works fully offline (no internet required).
•	Extremely fast and optimized for Flutter.
•	Easy to integrate and maintain.
•	Stores data in binary form, making it memory-efficient.
•	Ideal for small- to medium-sized local data storage (like saving memes).
Hive stores memes as serialized objects of the SavedMeme model, ensuring persistence across app restarts.
________________________________________

5. APIs / Packages / Plug-ins (Optional Section)
The project utilizes several Flutter packages:
Package	Purpose	Justification
hive	Local database	To store saved memes persistently and offline
hive_flutter	Flutter integration for Hive	To simplify initialization and access in Flutter
path_provider	Directory management	Used to find a suitable location for storing Hive data files
These packages ensure the app remains lightweight yet powerful.
________________________________________

6. Issues and Bugs Encountered and Resolved
Issue	Description	Resolution
Data not persisting after app restart	Saved memes disappeared after closing the app	Integrated Hive for local persistent storage
Hive adapter not generating	Errors during build process	Added build_runner and hive_generator as dependencies and fixed file structure
Hive “integer key out of range” error	Used invalid integer key for Hive storage	Changed storage logic to use put(key, value) with proper keys
Build runner not running	Missing dependency	Installed and ran using dart run build_runner build
Import dependency warning	Hive package not recognized	Added Hive to dependencies in pubspec.yaml

________________________________________

6. Issues and Bugs Encountered and Resolved
Issue	Description	Resolution
Data not persisting after restart	Saved memes disappeared when the app was closed and reopened.	Implemented Hive local storage to persist data offline.
Hive adapter not generating	Running build_runner gave an error: “Import directives must precede part directives.”	Fixed file structure by placing part 'saved_meme.g.dart'; after imports and re-ran dart run build_runner build.
Build runner command not working	The old command flutter pub run build_runner build failed.	Used the updated command: dart run build_runner build.
Hive initialization error	Error: “Box not found. Did you forget to call Hive.openBox()?”	Opened the box inside _getBox() method before accessing data.
Integer key out of range	Error: “HiveError: integer key needs to be in range 0–0xffffffff.”	Updated the saving logic to use box.add(meme) instead of manually assigning invalid integer keys.
