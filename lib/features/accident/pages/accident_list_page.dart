import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/accident_provider.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';

class AccidentListPage extends ConsumerWidget {
  const AccidentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accidentProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accidents')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/accidents/new'),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(accidentProvider.notifier).fetch(),
        ),
        data: (accidents) => accidents.isEmpty
            ? const EmptyView(message: 'No accidents yet')
            : ListView.builder(
          itemCount: accidents.length,
          itemBuilder: (context, index) {
            final accident = accidents[index];
            return ListTile(
              leading: accident.images.isNotEmpty
                  ? CircleAvatar(
                backgroundImage: NetworkImage(
                    accident.images.first.image),
              )
                  : const CircleAvatar(
                  child: Icon(Icons.car_crash)),
              title: Text(accident.name),
              subtitle: Text(
                  accident.vehicle?.vehicleNo ?? 'No vehicle'),
              trailing: Text(
                  accident.accidentDate?.substring(0, 10) ?? ''),
              onTap: () => context.push(
                '/accidents/${accident.id}',
                extra: accident,
              ),
            );
          },
        ),
      ),
    );
  }
}