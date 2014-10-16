Seismic
=======

This is a sample project which consumes and present Earthquake occurrence data from an API and various methods of visualizing that data.


## Components
* **SeismicAPI:** Consumes the feed of Earthquakes in an asynchronous manner and forwards the results to the database for processing
* **SeismicDB:** A Multi-threaded approach where all write events happen in a temporary context and changes are propogated to the master context use for all reads. The Database client also has a few convenience functions to obtain the data with specific 
* **Selection view:** A table used to present and select how to visualize the data. Cells are provided NSDictionary objects which must contain a few specific properties to know which class to load, how to transition to that class, and what the class might need to know to present itself.
* **List view:** A means of presenting the information about the Earthquake data. I've used a prototype-style method of presentation with UITableViewCell subclasses where the cell itself should know how to present it, thereby giving the Table View the responsiblity of only handing the cell the information it needs to make the decisions. There are also multiple different presentation styles and sorting methods which would be easy to expand later.
* **Map view:** Used to visualize the location of earthquake events. The map can be used in two different ways:
*1. To display a single earthquake event
*2. To display all earthquake events

## Goals
### Desired
### Achieved

## Approach
### Concepts

## Considerations
### User's perspective
### API
### Database
### Reusability
### Assertions & Unit testing
### Memory usage


## Documentation
### 3rd Party Libraries
### Resources 