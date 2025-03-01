//
//  Notes.swift
//  Brief
//
//  Created by Rachel Radford on 2/12/25.
//

//MARK: Notes
/*
    Had to remove CoreML model from project. I realized I was using distilBERT which is
    a classification model. I tried to use distilBART, Pegasus, and others with varying difficulties.
    I am thinking about try to use Tabular Data and convert to a mlpackage from there. I am not sure
    if this will be easier or not but I think it's worth a shot.

    While removing the model and commiting to GitHub I encountered issues trying to push those
    changes. For some reason, the deleted files were still being tracked. This caused challenges in
    fixing the issue and somewehre a long the way my info.plist files in the main & share ext were broken/corrupted.
    Thankfully, I was able to recover. However, it delayed my progress by days.
 
 ✓ Also having display issues with the iPhone simulator. The views look fine in previews and iPad simulator but
    not on iPhone simulator.
 
   Removed voice summary functionality. I hope to have Siri do this.
 
   Instead of Siri opening article in the web every time, Siri opens article in
   app. The only drawback is you cant open article outside of app. From what I
   understand, Apple makes this a more complicated for security reason. I
   figured user could open app with Siri and then open article.
 
  I want to improve the Siri request string for opening article.
  Right now, you have to say " Hey Siri, Can you open my article in Brief"
  However, to open article by title, you can just say the first few words of the
  title.
*/

