import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/partner_provider.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';

class PartnerListPage extends ConsumerWidget {
  const PartnerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(partnerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Partners')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/partners/new'),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(partnerProvider.notifier).fetch(),
        ),
        data: (partners) => partners.isEmpty
            ? const EmptyView(message: 'No partners yet')
            : ListView.builder(
          itemCount: partners.length,
          itemBuilder: (context, index) {
            final partner = partners[index];
            return ListTile(
              leading: partner.photoImage != null
                  ? CircleAvatar(
                backgroundImage:
                NetworkImage(partner.photoImage!),
              )
                  : const CircleAvatar(
                  child: Icon(Icons.person)),
              title: Text(partner.name),
              subtitle: Text(partner.email),
              trailing: Text(partner.partnerType ?? ''),
              onTap: () => context.push(
                '/partners/${partner.id}',
                extra: partner,
              ),
            );
          },
        ),
      ),
    );
  }
}