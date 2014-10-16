Seismic
=======

This is a sample project which consumes and present Earthquake occurrence data from an API and various methods of visualizing that data.


## Components
* **SeismicAPI:** Consumes the feed of Earthquakes in an asynchronous manner and forwards the results to the database for processing
* **SeismicDB:** A Multi-threaded approach where all write events happen in a temporary context and changes are propogated to the master context use for all reads. The Database client also has a few convenience functions to obtain the data with specific 
* **Selection view:** A table used to present and select how to visualize the data. Cells are provided NSDictionary objects which must contain a few specific properties to know which class to load, how to transition to that class, and what the class might need to know to present itself.
* **List view:** A means of presenting the information about the Earthquake data. I've used a prototype-style method of presentation with UITableViewCell subclasses where the cell itself should know how to present it, thereby giving the Table View the responsiblity of only handing the cell the information it needs to make the decisions. There are also multiple different presentation styles and sorting methods which would be easy to expand later.
	1. By time - most recent first
	2. By magnitude - strongest first
	3. By location - closest to user first
* **Map view:** Used to visualize the location of earthquake events. The map can be used in two different ways:
	1. To display a single earthquake event
	2. To display all earthquake events


## Goals
### Desired
I had a few ideas initially of what I wanted to develop. I wanted to show a variety of different presentation methods and immediately went to UITableView and UICollectionView. 

I also wanted to build an API client which could easily consume and update the data with ease, potentially doing incremental updates.

The database needed to be extremely simple to insert into, so it would help if the data model very closely matched the API model.

Further, I wanted to turn the data inside out and derive some sort of knowledge from it. I wanted to examine the Earthquake events and create a coulple simple algorithms which would find and classify other Earthquake events with close proximity in distance and time and (and of a smaller magnitude) as Aftershocks and relate them to the initial Earthquake. This would make the Collection View (a.k.a. Grid) much more interesting.

Taking it one step further, I wanted to introduce another data store called [Realm](http://www.realm.io) which I am a big fan of. (So much so that I decided to integrate it into a fresh commercial product which will be running on a massive number of devices within a year). I didn't want to start with this, however, because CoreData is the standard approach and needed to demonstrate my familiarity with that.

I also wanted to spend about 4 hours on development, and add time for clean-up and testing.


### Achieved
* **API:** I smashed through this and was quite happy with the result. At this point however, I noticed that we're working with a bad data source -- the data is stale and is no longer maintained. Thus, there was no need for me to continue working on the API to do incremental updates.
* **DB:** It took a bit longer than I wanted to spend but I was also very happy with the outcome in terms of flexibility and stability.
* **List view:** I began presenting the information in the Table View and customized the UITableViewCell subclasses. I also tried a few fancy presentation methods to make the information a little more interesting to look at.
* **Selection list:** I dove back into the Storyboard to insert another UITableView before the list and customized it with a few options.
* **Map view:** When I realized having the region listed just not being sufficent, I decided to add the ability to view where the earthquake occurred on a map. Also, because I now had a map, I decided to add another way to visualize all of the Earthquakes by expanding the abilit of the Map View to display more than one event. (In fact, its the other way -- the single-Earthquake view is displaying an array of 1 Earthquake).
* **User location:** Because I had a method of filtering Earthquakes by distance from the user, I still needed to define this. I did this by extending the List view to request the User's location in a Privacy-friendly manner (on iOS8 it only asks for permission while in use) and handles when the user decides not to give permission by instructing them how to change it.
* **Memory management:** While testing my changes, I started noticing memory going crazy while visiting the map in the simulator so I did a round of fixes and heapshot analysis using Profiler for Allocations. When I plugged a device in, the memory growth and release appeared a lot more reasonable.

## Approach
I approached the task by trying to show a wide variety of concepts including:
* Singletons
* Cocoapods for 3rd party libraries
* Core Data multi-context
* Threading
* Categories
* Enumerations
* Static / shared variables
* MapKit usage
* User location permissions & error handling
* Battery usage management
* Subclassing
* Flexibility, reusability, modularity
* Commenting (especially comments when option-clicking on a method while in Xcode)
* Code conciseness

Because the API was so simple, I decided to bring the data in first, save it into my models and then work with the actual objects by building the UI around it. I extended the UI to a reasonable amount of functionality, then tried to polish it off with a bit of cleanup and memory management.


## Considerations
### User's perspective
The user's perspective heavily influenced how to visualize the data. We need to ask, "What would a user want to see?" The answers I gave were:
* The most recent Earthquakes
* The strongest Earthquakes
* How close are they to me?
* (Later) where was this earthquake?

### API
The API needed to be extremely simple to use and update.

### Database
The Database needed to follow the same pattern as the API -- it had to be extremely simple to use, and when sending data in it handles the multi-context threading for you.

### Reusability
I wanted to demonstrate the ability to reuse the relatively small number of classes in different ways. In most cases, this is handled by requesting the data in a different way, or by instantiating controllers and providing them information they need to make their decitions.

### Assertions & Unit testing
I started off by writing a lot of assertions. Towards the end, because I had done the majority of the logic I found I wasn't requiring them as much but there were a few cases where they caught errors for me.

I only performed functional testing as I went, so I have not written any unit tests. All things considered, however, I do have to admit that unit tests are not my strongest suit.

### Memory usage
I'ts been a long time since I've worked with a project with ARC disabled. It was interesting to find myself remembering how to do things the old way. In the end I feel like I have taken care of most of any potential memory leaks by profiling and static analysis. It was surprising to me just how often I use auto-released objects such as [NSArray arrayWithObjects:] without even thinking about it.

One thing I left myself wondering about however, was the use of the SharedDateFormatter and SharedNumberFormatter in SeismicListCell -- since they're static variables they're not cleared and might leak a bit of memory -- however since there's only two of them the impact would be very small.

## Documentation
Many complex functions have been documented to provide information about what they do, what parameters they require, what results they return and other functions to look at.

Some of the more complex bits of code have also been documented to explain what they're doing, provide sample API response objects, and add thoughts on better ways to achieve the desired outcomes.

### 3rd Party Libraries
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* **(Not used)** [Realm](http://www.realm.io) [Realm-GitHub](https://github.com/realm/realm-cocoa)

### Resources 
* [Multi-context Core Data](http://www.cocoanetics.com/2012/07/multi-context-coredata/) <-- One of my favourite Objective-C articles in the last few years
* [Allocations/Heapshot Analysis in Profiler](http://www.friday.com/bbum/2010/10/17/when-is-a-leak-not-a-leak-using-heapshot-analysis-to-find-undesirable-memory-growth/)
* [Apple iOS Developer Library](https://developer.apple.com/library/ios/navigation/)