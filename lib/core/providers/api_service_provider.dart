import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zavimart/core/network/api/base_api_imple.dart';

final apiServiceProvider = Provider<BaseApiServiceImpl>((ref) {
  return BaseApiServiceImpl();
});
