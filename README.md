# Filmz

Keeping track of my films and series. The ones I saw as well as the ones I want to see. And wether I liked them, so that I can recommend them to friends.



The main user flows are:

* User open the app and sees a list of his films (i.e. MyFilm entries).
* User can add a new film to the list: He can search for a film by title and then add it to his list. This is also where he enters his data about the film.
* User can see & edit the details of a film: He can see the details of a film from his list. This includes the data he entered as well as the data from IMDB.

Some key services & protocols I have:

* ImdbFilmService: Fetches the data from IMDB about a film.
  * searchFilms(query: String)  
  * fetchMovieDetails(imdbId: String) -> ImdbFilm
* MyFilmRepository: A protocol with basic functions:
  * fetchAllMyFilms()
  * addMyFilm(myFilm: MyFilm)
  * updateMyFilm(myFilm: MyFilm)
  * deleteMyFilm(myFilm: MyFilm)
* CKMyFilmRepository: A concrete implementation of MyFilmRepository that uses iCloudKit to store the data.
* MyFilmStore: A class that manages the data in the app. It uses CKMyFilmRepository to store the data.

The basic views that make up my app are:

* MyFilmListView: Shows a list of films. It uses MyFilmStore to fetch the data.
* MyFilmDetailView: Shows the details of a film. 
* ImdbFilmDetailView: Shows the details of a film from IMDB. It uses ImdbFilmService to fetch the data.

## Filmz structure

The Film class contains both data from IMDB as well as my own data about it:

![Film](FilmStructure.drawio.png)

## Storing Filmz

In order to store filmz in iCloudKit and to maintain them in the app, these are the involved classes:

![Film Storage](FilmStorage.drawio.png)

## Searching Filmz

We have one class in charge of searching:

![Film Search](FilmSearch.drawio.png)

### Retrieving from OMDB

Since I use the [Open Movie Database API](https://www.omdbapi.com/), here are some test search requests:

```bash
curl -X GET "http://www.omdbapi.com/?apikey=1b5a29bf&s=batman" -H  "accept: application/json"
```

A sample result:
```json
{"Title":"Batman Begins",
"Year":"2005",
"Rated":"PG-13",
"Released":"15 Jun 2005",
"Runtime":"140 min",
"Genre":"Action, Drama",
"Director":"Christopher Nolan",
"Writer":"Bob Kane, David S. Goyer, Christopher Nolan","Actors":"Christian Bale, Michael Caine, Ken Watanabe",
"Plot":"When his parents are killed, billionaire playboy Bruce Wayne relocates to Asia, where he is mentored by Henri Ducard and Ra's Al Ghul in how to fight evil. When learning about the plan to wipe out evil in Gotham City by Ducard, Bruce prevents this plan from getting any further and heads back to his home. Back in his original surroundings, Bruce adopts the image of a bat to strike fear into the criminals and the corrupt as the icon known as \"Batman\". But it doesn't stay quiet for long.",
"Language":"English, Mandarin",
"Country":"United States, United Kingdom",
"Awards":"Nominated for 1 Oscar. 15 wins & 79 nominations total","Poster":"https://m.media-amazon.com/images/M/MV5BODIyMDdhNTgtNDlmOC00MjUxLWE2NDItODA5MTdkNzY3ZTdhXkEyXkFqcGc@._V1_SX300.jpg",
"Ratings":[{"Source":"Internet Movie Database","Value":"8.2/10"},{"Source":"Rotten Tomatoes","Value":"85%"},{"Source":"Metacritic","Value":"70/100"}],
"Metascore":"70",
"imdbRating":"8.2",
"imdbVotes":"1,626,251",
"imdbID":"tt0372784",
"Type":"movie",
"DVD":"N/A",
"BoxOffice":"$206,863,479",
"Production":"N/A",
"Website":"N/A",
"Response":"True"}
```

### Movie databases 

I need a movie database to query in the background. Here are some options I found:

* [Open Movie Database API](https://www.omdbapi.com/): I think it's a download of the [Open Movie Database](https://www.omdb.org/) (OMDB) and makes the content available via API. Free, but limited to 1000 requests per day. 
* [The Movie Database](https://www.themoviedb.org/): To get a commercial license I need to email them.
* ~~[IMDB](https://www.imdb.com/): The API is crazyyy expensive ($150,000 plus metered costs 😀)~~

Other services to look at:

* [Rotten Tomatoes](https://www.rottentomatoes.com/)
* [Metacritic](https://www.metacritic.com/)
* [Letterboxd](https://letterboxd.com/)
* [Flixster](https://www.flixster.com/)
* [JustWatch](https://www.justwatch.com/)
* [Filmweb](https://www.filmweb.pl/)
* [Film-Rezensionen](https://www.film-rezensionen.de/)