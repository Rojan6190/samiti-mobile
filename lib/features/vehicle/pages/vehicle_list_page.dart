import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/vehicle_provider.dart';
import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';

class VehicleListPage extends ConsumerWidget {
  const VehicleListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicles')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/vehicles/new'),
        child: const Icon(Icons.add),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.read(vehicleProvider.notifier).fetch(),
        ),
        data: (vehicles) => vehicles.isEmpty
            ? const EmptyView(message: 'No vehicles yet')
            : ListView.builder(
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return ListTile(
              leading: vehicle.vehicleImage != null
                  ? CircleAvatar(
                backgroundImage:
                NetworkImage(vehicle.vehicleImage!),
              )
                  : const CircleAvatar(
                  child: Icon(Icons.directions_car)),
              title: Text(vehicle.vehicleNo),
              subtitle: Text(vehicle.partner?.name ?? ''),
              trailing: Text(vehicle.fuelType ?? ''),
              onTap: () => context.push(
                '/vehicles/${vehicle.id}',
                extra: vehicle,
              ),
            );
          },
        ),
      ),
    );
  }
}