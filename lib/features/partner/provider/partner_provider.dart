import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samiti_mobile_app/features/partner/data/partner_model.dart';
import 'package:samiti_mobile_app/features/partner/data/partner_repository.dart';


final partnerRepositoryProvider = Provider((ref)=>PartnerRepository());//creates a singleton instance of PartnerRepository, makes repository available to PartnerNotifier, you'd need to create new instance everywhere without it, see deepseek for more

class PartnerNotifier extends StateNotifier<AsyncValue<List<Partner>>>{
  final PartnerRepository _repo;

  PartnerNotifier(this._repo) : super(const AsyncLoading()){
    fetch();

  }
  Future<void> fetch() async {
    state = const AsyncLoading();
    try{
      final partners = await _repo.getPartners();
      state = AsyncData(partners);
    } catch(e, st){
      state= AsyncError(e, st);
    }
  }
  Future<void> create(FormData data) async{
    await _repo.createPartner(data);   //we can alternatively: do-> add locally first, then sync with backend, then refresh if needed
    await fetch();
  }
  Future<void> update(int id, FormData data) async{
    await _repo.updatePartner(id, data);
    await fetch();
  }
}
  final partnerProvider =
      StateNotifierProvider<PartnerNotifier, AsyncValue<List<Partner>>>(
          (ref)=> PartnerNotifier(ref.read(partnerRepositoryProvider)),
      );
