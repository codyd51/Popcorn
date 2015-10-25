Popcorn
===============

This tweak extends iOS 9's 'Quick Actions' functionality by also allowing you to 'pop' on icons at the home screen by force touching harder.

Swipe up to invoke on non-force touch devices.

This tweak works best when the app is already live in the background, however, it will still work if it is not. Popcorn will take care of launching the app and polling for the context host view until it has launched.
Because of this polling technique (as the app launch simply takes time), apps which were not alive in the background will take about 0.5 seconds to invoke.

For apps in which retrieving a context host view is not possible (as with strange system applications installed through tweaks, such as DisplayRecorder and BatteryLife), Popcorn will automatically time out if polling was not successful for a given amount of time, ensuring you never lose control of your device, even when invoking on unconventional application icons.

Basically, GPL v3. I'd love for you to learn from this code, but please provide attribution if you use it in your own product, and please don't redistribute and call it your own. 
Thanks!

Screenshot 1 | Screenshot 2 | Screenshot 3
:-------------------------:|:-------------------------:|:---------------------------:
![Preview](/screen1.PNG)  | ![Preview](/screen2.PNG) |  ![Preview](/screen3.PNG)
