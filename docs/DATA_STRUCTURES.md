The key data entities.

## MyFilm

The data about a film that I maintain. Some fields of it:

- id: UUID
- imdbFilmId: The film id from IMDB
- myRating: Int 0..10
- dateAdded: Date
- watched: Bool
- dateWatched: Date
- audience: Enum AudienceType("Me alone", "Me and partner", "Family")
- recommendedBy: String

TODO:

- Shows & Series: At a later stateg I will have to properly deal with shows, seasons, episodes... Currently a show is just one film.

## ImdbFilm

The data from IMDB about a film.

- imdbId: String
- title: String
- year: String
- genres: [String]
- imdbRating: Double
- poster: URL
- plot: String
