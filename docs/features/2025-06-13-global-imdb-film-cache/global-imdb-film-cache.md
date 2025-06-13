Retrieving data from the OMDB API should be reduced to a minimum as it is limited (hit rate restrictions & costs). Therefore the cache system for IMDB films should become multilayered. When needing the data of a IMDB film, the following levels should be inspected:

1. Local storage, i.e. do I have the film data already locally (this is already implemented).
2. Filmz2 shared storage: Has any user in the past already retrieved that film's data? If so it will be stored in the global IMDB Film Cache
3. Retrieve it from OMDB by the IMDB ID.

Once the system retrieved the IMDB film, it should ensure that the lower level caches are updated.

In order to implement this, Filmz2 should get a global CloudKit data storage area in which IMDB film data is stored.
