OpenTweet
=========

Hi Frank! Welcome to your iOS coding excercise.

This is a very simple twitter like client. You'll find a json file under Data/ with a short tweet timeline. You are asked to write the app that will display the tweets, similar to what a Twitter client would do.

A tweet has at the minimum:

* An id
* An author
* A content (e.g. the actual tweet)
* A date (text format, in the standard ISO-8601 format)

Additionally, a tweet may have:

* A reference to the tweet ID it's replying to
* A URL to the user's avatar
* A list of image URLs

The timeline is a chronologically ordered (ascending order) list of tweets.

Since the topic is very simple, yet offers so many possibilities at the same time, there is a minimum requirement, and bonuses.

Minimum requirement
-------------------

* Fork the repo
* Parse the json file included in the project
* Display the tweets in the order the json file defines them. The app should display the author, the tweet and the date it was tweeted at. Tweets are variable length, so the cells must be properly sized to the content
* When done, send a pull request to this project (e.g don't email me your project :))

Bonuses (in no particular order)
--------------------------------

* Highlight the mentions (@username) and/or links in a different font/color
* Display a tweet's thread when tapping on a giving tweet. Due to the very simplistic data model made available to you, it's probably best to simplify this: if the user taps on the first tweet of a thread, display all the replies in ascending chronological order, if the user taps on a reply to another tweet, only show the tapped tweet and the tweet it's replying to.
* Display attached images (networking calls are somewhat off topic though)
* Display the user's avatar (this one is quite hard, because of text reflowing)
* Animate/highlight a tweet when it is selected (e.g. make it "bigger", in an animated fashion)
* Anything else you might think of that showcases a UIKit feature: UIDynamics, parallax effect, the list is endless.

What the assignment will be judged on
-------------------------------------

* Accuracy of the result (e.g. is the cell sizing pixel perfect, dates are properly formatted, the app doesn't crash, project builds and runs with no extra step, etc.)
* Proper usage of UIKit apis (e.g. are cells properly reused, a back button must have a proper title, how well does it scale to 3.5/4/4.7 inch devices, etc.)
* Overall code quality: clarity, conciseness, quality of comments. Robustness matters more than clever one liners.
* If you end up short on time and/or can't fix a specific bug or finish a given feature, update this readme with what the bug is, and how you think you can fix had you more time.
* Bonuses are exactly that, bonuses. If you can complete one or more, good. Otherwise, don't sweat it
* If you can't complete something, explain why, how you reached that conclusion and potential options to complete it.
* The project is setup for swift 3. If you feel like using swift 2.3 or objective-c, that's fine (but you'll have to update the project settings yourself).

What the assignment will NOT be judged on
-----------------------------------------

* Visual design. This is a UI coding excercise, not a visual design excercise. Feel free to use Comic Sans 48 pts with green on red text if you feel like it (just warn me if you do so, so I can put sunglasses on before running the app :))
* UI performance (e.g. framerate), as long as it's reasonable. Feel free to indicate in the code if/why something would affect the framerate, and a potential solution to it.
* If you try to complete a bonus and can't finish it, that's fine. I'd recommend using git commits/tags to indicate where the bonuses start in the history, so we can easily reset the branch at that commit and validate the minimum requirement.

Happy coding!

![All the things](http://cdn.meme.am/instances/500x/57104950.jpg)

Bug and Potential Enhancement
1) Improve cell enlarge animation.  
The avatar image disappear during tap animation. This is likely due to multiple:(a) Cell's prepareForReuse, (b) background loading of avatar image and (c) CGAffineTransformMakeScale which enlarge the cell frame and autoLayout took over to scaleDown to CGAffineTransformIdentity.  I attempted to implement imageCache to improve it but it is not satisfactory.  I would probably implement a different animation (shake the cell on user tap for example).
2) Recursive search of tweets/replies
Tweet#7 is a reply to tweet#4 which is a reply to tweet#42. Need to implement a recursive search.  A brute-force is to do span all threads for each recursive pass ( Order O(2^n) ). The time complexity can be improved by tracking and skipping prior thread for each recursion.  As I thought more, for a large tweet threads, this could get ugly since there can be n-reply to k-reply to ... the list goes on.  Need more time to figure out a better algo that can still perform well on a phone device without draining battery or overheating.
