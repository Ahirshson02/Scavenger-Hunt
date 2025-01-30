
# Scavenger-Hunt
Codepath IOS102 Unit 1 Project: Scavenger Hunt
=======
# Project 1 - Scavenger Hunt

Submitted by: Adam Hirshson

Scavenger Hunt is an app that allows users to pick something to find, and attach a photo of that thing 

Time spent: 23 hours spent in total

<div style="position: relative; padding-bottom: 62.5%; height: 0;"><iframe src="https://www.loom.com/embed/9c9b06d1550a43dfb3ac08aa14c1f9e5?sid=5810ac98-a8e3-4cf3-a984-f51147ea8164" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe></div>



## Required Features

The following **required** functionality is completed:

- [x] App displays list of hard-coded tasks
- [x] When a task is tapped it navigates the user to a task detail view
- [x] When user adds photo to complete the tasks, it marks the task as complete
- [x] When adding photo of task, the location is added
- [x] User returns to home page (list of tasks) and the status of your task is updated to complete
 
The following **optional** features are implemented:

- [ ] User can launch camera to snap a picture    

The following **additional** features are implemented:

- [ ] List anything else that you can get done to improve the app functionality!

## Video Walkthrough

Here is a reminder on how to embed Loom videos on GitHub. Feel free to remove this reminder once you upload your README. 

[Guide]](https://www.youtube.com/watch?v=GA92eKlYio4) .

## Notes

Describe any challenges encountered while building the app.

I had a lot of trouble setting up the constraints and photo permissions, which caused my mapview to not appear. Learning to deal with and experimenting with the constraints, and prompting for photo access without directing the user to settings took up a lot of time.

I also encountered issues trying to provide limited photo access. I was able to have the user specify what photos to access, but that would not be reflected in the image picker. After much experimentation and some research, I found an Apple forum post of someone with the same issue saying it ended up being am emulator issue, found here: https://forums.developer.apple.com/forums/thread/661997

## License

    Copyright [2025] [Adam Hirshson]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

