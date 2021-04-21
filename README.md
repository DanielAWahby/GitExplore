## GitExplore


#### Challenges I Faced:
* Slow Scrolling in TableView
  * Addressed by adding images a separate array of UIImage in advance, while fetching data from API Endpoint.
* API Limit Constraints 
  * Addressed by generating tokens and sending them as a parameter in the HTTP header of each Request
* Getting the right amount of table cells / repositories
  * Solved using by utilitzing delays in the  DispathQueue Async After function
