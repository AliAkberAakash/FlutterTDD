import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_tdd/core/error/exceptions.dart';
import 'package:flutter_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NumberTriviaLocalDataSource {
  /// Gets the last [NumberTriviaModel] which was gotten last time
  /// the user had an internet connection.
  ///
  /// Throws [CachedException] if no cached data is present.
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void> cacheNumberTrivia(NumberTriviaModel triviaModel);
}

const CACHED_NUMBER_TRIVIA = 'CACHED_NUMBER_TRIVIA';

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource{

  final SharedPreferences preferences;

  NumberTriviaLocalDataSourceImpl({ @required this.preferences });

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final jsonString = preferences.getString(CACHED_NUMBER_TRIVIA);

    if(jsonString != null)
      return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString)));
    else
      throw CacheException();
  }

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaModel) {
    return preferences.setString(CACHED_NUMBER_TRIVIA,
        json.encode(
            triviaModel.toJson()
        )
    );
  }

}