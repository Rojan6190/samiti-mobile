import 'package:dio/dio.dart';
import '../../../core/network/base_repository.dart';
import '../../../core/constants/api_constants.dart';
import 'partner_model.dart';

class PartnerRepository extends BaseRepository {
  Future<List<Partner>> getPartners() =>
      getList(ApiConstants.partners, Partner.fromJson);

  Future<Partner> createPartner(FormData data) async {
    final response = await dio.post(
      ApiConstants.partners,
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Partner.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Partner> updatePartner(int id, FormData data) async {
    final response = await dio.patch(
      '${ApiConstants.partners}$id/',
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Partner.fromJson(response.data as Map<String, dynamic>);
  }
}