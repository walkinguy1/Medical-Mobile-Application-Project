import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ambulance.dart';

class AmbulanceCard extends StatelessWidget {
  final AmbulanceProvider ambulance;
  final VoidCallback? onTap;

  const AmbulanceCard({
    super.key,
    required this.ambulance,
    this.onTap,
  });

  Future<void> _makeCall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number.replaceAll(RegExp(r'\s+'), ''));
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ambulance.hospitalName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ambulance.address,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _makeCall(ambulance.contactNumber),
                    icon: const Icon(Icons.call_outlined),
                    tooltip: 'Call Ambulance',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCapabilityChip(context, '24/7 Service', ambulance.is24h, Icons.access_time_filled, Colors.teal),
                  _buildCapabilityChip(context, 'ICU Care', ambulance.hasIcu, Icons.ac_unit, Colors.blue),
                  _buildCapabilityChip(context, 'Oxygen', ambulance.hasOxygen, Icons.air, Colors.indigo),
                ],
              ),
              if (ambulance.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  ambulance.notes,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapabilityChip(BuildContext context, String label, bool isAvailable, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable ? color.withValues(alpha: 0.08) : Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: isAvailable ? color.withValues(alpha: 0.3) : Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isAvailable ? color : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isAvailable ? color : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
