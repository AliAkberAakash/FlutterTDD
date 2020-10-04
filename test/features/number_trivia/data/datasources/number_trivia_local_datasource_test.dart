import 'dart:convert';

import 'package:flutter_tdd/core/error/exceptions.dart';
import 'package:flutter_tdd/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:flutter_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matcher/matcher.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {

  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(preferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {

    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test('should return numberTrivia from SharedPreferences when there is one in the cache', () async {
      //arrange
      when(mockSharedPreferences.getString(any)).thenReturn(fixture('trivia_cached.json'));
      //act
      final result = await dataSource.getLastNumberTrivia();
      //assert
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, tNumberTriviaModel);

    });

    test('should return CacheException from SharedPreferences when there none in the cache', () async {
      //arrange
      when(mockSharedPreferences.getString(any)).thenReturn(null);
      //act
      final call = dataSource.getLastNumberTrivia;
      //assert
      expect(() => call(), throwsA(isA<CacheException>()));

    });

  });

  group('cacheNumberTrivia', () {

    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: "test trivia");

    test('should call sharedPreferences to cache the data', () async{
      //act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      //assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, expectedJsonString));
    });

  });

}