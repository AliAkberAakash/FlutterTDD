import 'package:dartz/dartz.dart';
import 'package:flutter_tdd/core/error/exceptions.dart';
import 'package:flutter_tdd/core/error/failures.dart';
import 'package:flutter_tdd/core/platform/network_info.dart';
import 'package:flutter_tdd/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:flutter_tdd/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:flutter_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_tdd/features/number_trivia/data/repositoryImpl/number_trivia_repository_impl.dart';
import 'package:flutter_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource{}

class MockLocalDataSource extends Mock
    implements NumberTriviaLocalDataSource{}

class MockNetworkInfo extends Mock
    implements NetworkInfo{}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = NumberTriviaRepositoryImpl(
      remoteDataSource : mockRemoteDataSource,
      localDataSource : mockLocalDataSource,
      networkInfo : mockNetworkInfo
    );

  });

  void runTestOnline(Function body){
    group('device is online', ()
    {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((
            realInvocation) async => true);
      });

      body();

    });
  }

  void runTestOffline(Function body){
    group('device is offline', ()
    {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((
            realInvocation) async => false);
      });

      body();

    });
  }

  group('GetConcreteNumberTrivia', () {

    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(
      number: tNumber,
      text: "test trivia"
    );
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online',
      () async{
        //arrange
        when(mockNetworkInfo.isConnected).thenAnswer((realInvocation) async => true);
        //act
        repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(mockNetworkInfo.isConnected);
    });
    runTestOnline(
            () {
      test('should return remote data when the call to remote data source is success.',
        () async {
            //arrange
            when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                .thenAnswer((realInvocation) async => tNumberTriviaModel);
            //act
            final result = await repository.getConcreteNumberTrivia(tNumber);
            //assert
            verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            expect(result, equals(Right(tNumberTrivia)));
      });

      test('should cache the data locally when the call to remote data source is success.',
              () async {
            //arrange
            when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                .thenAnswer((realInvocation) async => tNumberTriviaModel);
            //act
            await repository.getConcreteNumberTrivia(tNumber);
            //assert
            verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
          });

      test('should return server failure when the call to remote data source is unsuccessful.',
              () async {
            //arrange
            when(mockRemoteDataSource.getConcreteNumberTrivia(any))
                .thenThrow(ServerException());
            //act
            final result = await repository.getConcreteNumberTrivia(tNumber);
            //assert
            verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            verifyZeroInteractions(mockLocalDataSource);
            expect(result, equals(Left(ServerFailure())));
          });

    });

    runTestOffline(
            () {

      test('should return last locally cached data when cache data is present',
              () async {
              //arrange
              when(mockLocalDataSource.getLastNumberTrivia())
                  .thenAnswer((realInvocation) async => tNumberTriviaModel);
              //act
              final result = await repository.getConcreteNumberTrivia(tNumber);
              //assert
              verifyZeroInteractions(mockRemoteDataSource);
              verify(mockLocalDataSource.getLastNumberTrivia());
              expect(result, Right(tNumberTriviaModel));
          });

      test('should return CacheFailure when no cache data is present',
              () async {
            //arrange
            when(mockLocalDataSource.getLastNumberTrivia())
                .thenThrow(CacheException());
            //act
            final result = await repository.getConcreteNumberTrivia(tNumber);
            //assert
            verifyZeroInteractions(mockRemoteDataSource);
            verify(mockLocalDataSource.getLastNumberTrivia());
            expect(result, Left(CacheFailure()));
          });

    });

  });

  group('GetRandomNumberTrivia', () {

    final tNumberTriviaModel = NumberTriviaModel(
        number: 123,
        text: "test trivia"
    );
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online',
            () async{
          //arrange
          when(mockNetworkInfo.isConnected).thenAnswer((realInvocation) async => true);
          //act
          repository.getRandomNumberTrivia();
          //assert
          verify(mockNetworkInfo.isConnected);
        });
    runTestOnline(
            () {
          test('should return remote data when the call to remote data source is success.',
                  () async {
                //arrange
                when(mockRemoteDataSource.getRandomNumberTrivia())
                    .thenAnswer((realInvocation) async => tNumberTriviaModel);
                //act
                final result = await repository.getRandomNumberTrivia();
                //assert
                verify(mockRemoteDataSource.getRandomNumberTrivia());
                expect(result, equals(Right(tNumberTrivia)));
              });

          test('should cache the data locally when the call to remote data source is success.',
                  () async {
                //arrange
                when(mockRemoteDataSource.getRandomNumberTrivia())
                    .thenAnswer((realInvocation) async => tNumberTriviaModel);
                //act
                await repository.getRandomNumberTrivia();
                //assert
                verify(mockRemoteDataSource.getRandomNumberTrivia());
                verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
              });

          test('should return server failure when the call to remote data source is unsuccessful.',
                  () async {
                //arrange
                when(mockRemoteDataSource.getRandomNumberTrivia())
                    .thenThrow(ServerException());
                //act
                final result = await repository.getRandomNumberTrivia();
                //assert
                verify(mockRemoteDataSource.getRandomNumberTrivia());
                verifyZeroInteractions(mockLocalDataSource);
                expect(result, equals(Left(ServerFailure())));
              });

        });

    runTestOffline(
            () {

          test('should return last locally cached data when cache data is present',
                  () async {
                //arrange
                when(mockLocalDataSource.getLastNumberTrivia())
                    .thenAnswer((realInvocation) async => tNumberTriviaModel);
                //act
                final result = await repository.getRandomNumberTrivia();
                //assert
                verifyZeroInteractions(mockRemoteDataSource);
                verify(mockLocalDataSource.getLastNumberTrivia());
                expect(result, Right(tNumberTriviaModel));
              });

          test('should return CacheFailure when no cache data is present',
                  () async {
                //arrange
                when(mockLocalDataSource.getLastNumberTrivia())
                    .thenThrow(CacheException());
                //act
                final result = await repository.getRandomNumberTrivia();
                //assert
                verifyZeroInteractions(mockRemoteDataSource);
                verify(mockLocalDataSource.getLastNumberTrivia());
                expect(result, Left(CacheFailure()));
              });

        });

  });

}
