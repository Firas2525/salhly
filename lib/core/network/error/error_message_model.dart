import 'package:equatable/equatable.dart';

class ErrorMessageModel extends Equatable {
  final String statusMessage;

  const ErrorMessageModel({required this.statusMessage});

  factory ErrorMessageModel.fromJson(Map<String, dynamic> json,
      {String? errorMsg}) {
    return ErrorMessageModel(
        statusMessage: errorMsg ??
            (json['data'] is Map
                ? (json['data'] as Map).values.toList().firstOrNull.first
                : (json.containsKey('errors')
                    ? json['errors'][0]
                    : json.containsKey('message')
                        ? json['message']
                        : json.containsKey('error')
                            ? json['error']
                            : '')));
  }

  @override
  List<Object> get props => [statusMessage];
}
