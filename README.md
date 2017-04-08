# ON-THE-MAP
## udacity.com student submission

[![Udacity Course Id](https://img.shields.io/badge/course-ND003-37C6EE.svg)](COURSE)
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![System Version](https://img.shields.io/badge/version-1.0.2-blue.svg)](VERSION)
[![Language](https://img.shields.io/badge/swift-3.0-orange.svg)](http://swift.org)

*This repository will hold my project submission for udacity.com project works on app "OnTheMap" during my iOS developer certification program.*

„On The Map“ (OTM) is an iOS 10.3 mobile app that shows information posted by other students on a map. The map will contain pins that show the location where other students have reported studying. By tapping on the pin users can see a URL for something the student finds interesting. The user will be able to add their own data by posting a string that can be reverse geocoded to a location, and a URL.

## Specifications

OTM will be compile using the latest XCode 8.3 (8E162) Version and will run under iOS 9.n up to the latest iOS Version 10.3.
 
OTM using 4 API EndPoints by iOS native session methods:

- udacity.com
- parse.com (udacity clone)
- facebook.com
- google maps

OTM using 3rd Party Libraries for better UX/UI behavior. A complete list can be found inside projects [COPYRIGHT.md](COPYRIGHT.md) file.

## Structure

### Login
*all users of this app must be authenticated against the udacity.com network using their student credentials or their bound facebook login using oauth2*

Splash Screen             |  Login-View
:-------------------------:|:-------------------------:
![splash screen](github/media/otm_splash_01.png)  |  ![login view](github/media/otm_login_01.png)

### MapView
*each student location will marked by a specific pin, own locations will by colored blue, foreign locations will by toned black*

MapView Normal             |  MapView ZoomOut
:-------------------------:|:-------------------------:
![zoom in](github/media/otm_map_01.png)  |  ![zoom out](github/media/otm_map_01_zo.jpg)

### Map Annotation
*you can click on the annotation pins to bring up a detailed student meta view. You can control your location by delete or edit them. Foreign Student locations will be linked to the provided student url*

Own Annotation             |  Foreign Annotation
:-------------------------:|:-------------------------:
![student owned location](github/media/otm_map_01_detail.png)  |  ![foreign student location](github/media/otm_map_02.png)

### ListView
*to take a better view, you can also switch to listView of all locations or your locations. At the top of the listView you can see a statistic row containing information about the number of locations found, your locations, the largest distance between your device and another student and the numbers of countries identified*

ListView of Locations             |  ListView of own Locations
:-------------------------:|:-------------------------:
![all locations](github/media/otm_list_01.png)  |  ![your locations](github/media/otm_list_02.png)

### ListView Controls
*behind each slidable row you can fin a special menu to control your own location by edit or delete them or jump to a foreign student location profile*

ShortMenu to student             |  ShortMenu to your location
:-------------------------:|:-------------------------:
![cell menu 1](github/media/otm_list_01_m2_v2.png)  |  ![cell menu 2](github/media/otm_list_01_m1_v2.png)

### App/Map/ListMenu
*you can control the app using corresponding menu definition callable in map- and listView to add new locations, filter your list results or logOut from the OTM app*

Map Menu             |  List Menu
:-------------------------:|:-------------------------:
![map menu](github/media/otm_map_01_menu_v2.png)  |  ![list menu](github/media/otm_list_01_menu_v2.png)


## Keywords

swift, udacity, extension, uikit, foundation, app

## License-Term

Copyright (c) 2016-2017 Patrick Paechnatz <patrick.paechnatz@gmail.com>
                                                                           
Permission is hereby granted,  free of charge,  to any  person obtaining a  copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction,  including without limitation the rights to use,  copy, modify, merge, publish,  distribute, sublicense, and/or sell copies  of the  Software,  and to permit  persons to whom  the Software is furnished to do so, subject to the following conditions:       
                                                                           
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
                                                                           
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING  BUT NOT  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR  PURPOSE AND  NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,  WHETHER IN AN ACTION OF CONTRACT,  TORT OR OTHERWISE,  ARISING FROM,  OUT OF  OR IN CONNECTION  WITH THE  SOFTWARE  OR THE  USE OR  OTHER DEALINGS IN THE SOFTWARE.