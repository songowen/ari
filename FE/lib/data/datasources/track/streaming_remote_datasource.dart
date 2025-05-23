import 'package:ari/core/exceptions/failure.dart';
import 'package:ari/data/models/api_response.dart';
import 'package:ari/data/models/streaming_log_model.dart';
import 'package:dio/dio.dart';

abstract class StreamingDataSource {
  Future<ApiResponse<List<StreamingLogModel>>> getStreamingLogByTrackId(int albumId, int trackId);
}

class StreamingDataSourceImpl implements StreamingDataSource {
  final Dio dio;
  final String baseUrl;

  StreamingDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<ApiResponse<List<StreamingLogModel>>> getStreamingLogByTrackId(int albumId, int trackId) async {
    final url = '$baseUrl/api/v1/albums/$albumId/tracks/$trackId/logs';
    try {
      // Dio를 사용하여 GET 요청 보내기
      final response = await dio.get(url);

      // ApiResponse 객체로 변환
      final apiResponse = ApiResponse.fromJson(
        response.data, 
        (json) => (json as List)
          .map((item) => StreamingLogModel.fromJson(item))
          .toList()
      );

      if (apiResponse.status == 200) {
        return apiResponse;
      } else {
        throw Failure(message: "에러가 났음요");
      }
      
    } catch (e) {
      // DioError 또는 기타 예외 처리
      if (e is DioException) {
        // Dio 에러 정보를 사용하여 에러 응답 생성
        throw Failure(message: "에러가 났음요");
      } else {
        // 기타 예외 처리
        throw Failure(message: "에러가 났음요");
      }
    }
  }
}

class MockStreamingDataSourceImpl implements StreamingDataSource {

  final Dio dio;
  final String baseUrl;

  MockStreamingDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<ApiResponse<List<StreamingLogModel>>> getStreamingLogByTrackId(int albumId, int trackId) async {
    // 목 데이터
    final Map<String, dynamic> mockData = {
      "status": 200,
      "message": "Success",
      "data": {
        "streamings": [
          {
            "nickname": "jinlal",
            "datetime": "2025-03-17 13:01:00"
          },
          {
            "nickname": "dogkyuhyeon",
            "datetime": "2025-03-17 13:01:42"
          },
          // 추가 데이터...
        ],
      },
      "error": null
    };
    
    // 지연 시간 추가 (네트워크 시뮬레이션)
    await Future.delayed(Duration(milliseconds: 300));
    
    return ApiResponse.fromJson(
      mockData, 
      (json) => (json['streamings'] as List)
        .map((item) => StreamingLogModel.fromJson(item))
        .toList()
    );
  }
}
/*
더 나은 테스트 가능성:

DataSource는 단순히 데이터를 가져오는 로직만 테스트하면 됨
Repository는 에러 변환 로직과 모델 변환 로직을 테스트할 수 있음


더 깔끔한 도메인 코드:

UseCase나 ViewModel에서는 이미 변환된 Either를 사용하기만 하면 됨됨


에러 처리의 중앙화:

모든 에러 변환 로직이 Repository 계층에 모여있어 관리가 쉬움
 */