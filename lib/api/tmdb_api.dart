import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:movies_streams/models/movie_genres_list.dart';
import 'package:movies_streams/models/movie_page_result.dart';
import 'package:movies_streams/models/movie_error.dart';

///
/// TMDB API
///
/// To get an API key, it is FREE => go to "https://www.themoviedb.org/"
///

class TmdbApi {
  static const String TMDB_API_KEY = "5f9ac4618584b870dcfbc7b8820bfcf7";
  static const String baseUrl = 'api.themoviedb.org';
  final String imageBaseUrl = 'http://image.tmdb.org/t/p/w185/';

  ///
  /// Returns the list of movies/tv-show, based on criteria:
  /// [type]: movie or tv (show)
  /// [pageIndex]: page
  /// [minYear, maxYear]: release dates range
  /// [genre]: genre
  ///
  Future<MoviePageResult> pagedList(
      {String type: "movie",
      int pageIndex: 1,
      int minYear: 2016,
      int maxYear: 2017,
      int genre: 28}) async {
    var uri = Uri.https(
      baseUrl,
      '3/discovser/$type',
      <String, String>{
        'api_key': TMDB_API_KEY,
        'language': 'en-US',
        'sort_by': 'popularity.desc',
        'include_adult': 'false',
        'include_video': 'false',
        'page': '$pageIndex',
        'release_date.gte': '$minYear',
        'release_date.lte': '$maxYear',
        'with_genres': '$genre',
      },
    );

    var response = await _getRequest(uri);
    MoviePageResult list = MoviePageResult.fromJSON(json.decode(response));

    // Give some additional delay to simulate slow network
    await Future.delayed(const Duration(seconds: 1));

    return list;
  }

  ///
  /// Returns the list of all genres
  ///
  Future<MovieGenresList> movieGenres({String type: "movie"}) async {
    var uri = Uri.https(
      baseUrl,
      '3/genre/$type/list',
      <String, String>{
        'api_key': TMDB_API_KEY,
        'language': 'en-US',
      },
    );

    var response = await _getRequest(uri);
    MovieGenresList list = MovieGenresList.fromJSON(json.decode(response));

    return list;
  }

  ///
  /// Routine to invoke the TMDB Web Server to get answers
  ///
  Future<String> _getRequest(Uri uri) async {
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      var movieErr = MovieError.fromJSON(json.decode(response.body));
      throw MovieException(code: 99, cause: movieErr.message);
    }

    return response.body;
  }
}

class MovieException implements Exception {
  int code = 100;
  String cause;
  MovieException({this.code, this.cause});

  @override
  String toString() {
    return cause;
  }
}

TmdbApi api = TmdbApi();
