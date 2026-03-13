import 'package:equatable/equatable.dart';
import 'package:salhly/app.dart';

import '../utils/enums.dart';

class ParamsModel extends Equatable {
  final int? page;
  final int? rowCount;
  final String? keyword;
  final int? subCategoryID;
  final int? cityID;
  final ObjectType? objectType;
  final bool isEnd;

  const ParamsModel(
      {this.page,
      this.rowCount = App.rowCountHttp,
      this.keyword,
      this.subCategoryID,
      this.cityID,
      this.objectType,
      required this.isEnd});

  ParamsModel copyWith({
    int? page,
    int? rowCount,
    String? keyword,
    int? subCategoryID,
    int? cityID,
    ObjectType? objectType,
    bool? isEnd,
  }) {
    return ParamsModel(
      page: page ?? this.page,
      rowCount: rowCount ?? this.rowCount,
      keyword: keyword ?? this.keyword,
      subCategoryID: subCategoryID ?? this.subCategoryID,
      cityID: cityID ?? this.cityID,
      objectType: objectType ?? this.objectType,
      isEnd: isEnd ?? this.isEnd,
    );
  }

  String? _objectType() {
    switch (objectType) {
      case null:
        return null;
      case ObjectType.property:
        return '1';
      case ObjectType.salon:
        return '3';
      case ObjectType.transport:
        return '';
      case ObjectType.cars:
        return '';
      case ObjectType.healthcare:
        return '';
    }
  }

  Map<String, String> toJson() {
    final Map<String, String> data = {};
    if (page != null) {
      data['page'] = page.toString();
    }
    if (rowCount != null) {
      data['rowCount'] = rowCount.toString();
    }
    if (objectType != null) {
      data['category_id'] = _objectType()!;
    }
    if (keyword != null) {
      if (keyword!.isNotEmpty) {
        data['keyword'] = keyword!;
      }
    }
    if (cityID != null) {
      data['city_id'] = cityID.toString();
    }
    if (subCategoryID != null) {
      data['subCategory_id'] = subCategoryID.toString();
    }
    return data;
  }

  @override
  List<Object?> get props =>
      [page, rowCount, objectType, keyword, cityID, subCategoryID, isEnd];
}
