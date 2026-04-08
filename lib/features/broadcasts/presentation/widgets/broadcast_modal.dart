import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/customers/presentation/providers/customers_provider.dart';
import 'package:onepos_admin_app/features/broadcasts/presentation/providers/broadcast_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';

class BroadcastModal extends HookConsumerWidget {
  const BroadcastModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // tabs
            TabBar(
              controller: tabController,
              labelColor: AppTheme.blue,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.blue,
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Send Broadcast'),
                Tab(text: 'History'),
              ],
            ),

            Flexible(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    const _SendBroadcastTab(),
                    const _BroadcastHistoryTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendBroadcastTab extends HookConsumerWidget {
  const _SendBroadcastTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = useTextEditingController();
    final htmlMode = useState(false);
    final selectedType = useState(
      'Send Now',
    ); // Send Now, Send Later, Recurring
    final selectedCustomerIds = useState<Set<int>>({});
    final customersAsync = ref.watch(customersProvider);
    final isSending = useState(false);
    final customerScrollController = useScrollController();

    // extra fields for scheduling
    final scheduledDate = useState<DateTime?>(null);
    final scheduledTime = useState<TimeOfDay?>(null);
    final recurringStartDate = useState<DateTime?>(null);
    final recurringFrequency = useState<String>('Weekly');

    void toggleAll(List customers) {
      if (selectedCustomerIds.value.length == customers.length) {
        selectedCustomerIds.value = {};
      } else {
        selectedCustomerIds.value = customers.map((c) => (c.id as int)).toSet();
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // message field
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Message *',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: htmlMode.value,
                    onChanged: (v) => htmlMode.value = v ?? false,
                    activeColor: AppTheme.blue,
                  ),
                  Text(
                    'HTML Mode',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: messageController,
            hint: 'Enter your message...',
            maxLines: 5,
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // customer selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Customers *',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              customersAsync.when(
                data: (state) => Row(
                  children: [
                    Checkbox(
                      value:
                          selectedCustomerIds.value.length ==
                              state.customers.length &&
                          state.customers.isNotEmpty,
                      onChanged: (_) => toggleAll(state.customers),
                      activeColor: AppTheme.blue,
                    ),
                    Text(
                      'Select All',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.grey300),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: customersAsync.when(
              data: (state) => Scrollbar(
                controller: customerScrollController,
                thumbVisibility: true,
                child: ListView.builder(
                  controller: customerScrollController,
                  itemCount: state.customers.length,
                  itemBuilder: (context, index) {
                    final customer = state.customers[index];
                    final isSelected = selectedCustomerIds.value.contains(
                      customer.id,
                    );

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (v) {
                        final newSet = Set<int>.from(selectedCustomerIds.value);
                        if (v == true) {
                          newSet.add(customer.id);
                        } else {
                          newSet.remove(customer.id);
                        }
                        selectedCustomerIds.value = newSet;
                      },
                      title: Text(
                        customer.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: customer.preference != null
                          ? Text(
                              customer.preference!,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            )
                          : null,
                      activeColor: AppTheme.blue,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
              loading: () => const Center(child: LoadingWidget()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // send broadcast radio options
          Text(
            'Send Broadcast *',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _RadioOption(
            label: 'Send Now',
            value: 'Send Now',
            groupValue: selectedType.value,
            onChanged: (v) => selectedType.value = v!,
          ),
          _RadioOption(
            label: 'Send Later',
            value: 'Send Later',
            groupValue: selectedType.value,
            onChanged: (v) => selectedType.value = v!,
          ),
          _RadioOption(
            label: 'Recurring',
            value: 'Recurring',
            groupValue: selectedType.value,
            onChanged: (v) => selectedType.value = v!,
          ),
          const SizedBox(height: 16),

          // dynamic scheduling fields
          if (selectedType.value == 'Send Later') ...[
            _ScheduleField(
              label: 'Scheduled Date *',
              value: scheduledDate.value != null
                  ? DateFormat('dd/MM/yyyy').format(scheduledDate.value!)
                  : 'dd/mm/yyyy',
              icon: Icons.calendar_today_outlined,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) scheduledDate.value = date;
              },
            ),
            const SizedBox(height: 12),
            _ScheduleField(
              label: 'Scheduled Time (Optional)',
              value: scheduledTime.value != null
                  ? scheduledTime.value!.format(context)
                  : '--:--',
              icon: Icons.access_time,
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) scheduledTime.value = time;
              },
            ),
          ] else if (selectedType.value == 'Recurring') ...[
            _ScheduleField(
              label: 'Start Date *',
              value: recurringStartDate.value != null
                  ? DateFormat('dd/MM/yyyy').format(recurringStartDate.value!)
                  : 'dd/mm/yyyy',
              icon: Icons.calendar_today_outlined,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) recurringStartDate.value = date;
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Frequency',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: recurringFrequency.value,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                ),
              ),
              items: ['Weekly', 'Monthly', 'Yearly']
                  .map(
                    (f) => DropdownMenuItem(
                      value: f,
                      child: Text(f, style: GoogleFonts.poppins(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => recurringFrequency.value = v!,
            ),
          ],
          const SizedBox(height: AppTheme.spacingLarge),

          // action buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: AppTheme.grey300,
                  textColor: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: CustomButton(
                  text: selectedType.value,
                  isLoading: isSending.value,
                  onPressed: () async {
                    if (messageController.text.trim().isEmpty) {
                      AppSnackbar.showError(context, 'Message is required');
                      return;
                    }
                    if (selectedCustomerIds.value.isEmpty) {
                      AppSnackbar.showError(
                        context,
                        'Please select at least one customer',
                      );
                      return;
                    }

                    // validation for scheduling
                    if (selectedType.value == 'Send Later' &&
                        scheduledDate.value == null) {
                      AppSnackbar.showError(
                        context,
                        'Please select a scheduled date',
                      );
                      return;
                    }
                    if (selectedType.value == 'Recurring' &&
                        recurringStartDate.value == null) {
                      AppSnackbar.showError(
                        context,
                        'Please select a start date',
                      );
                      return;
                    }

                    isSending.value = true;
                    final body = {
                      'message': messageController.text.trim(),
                      'message_type': htmlMode.value ? 'html' : 'plain',
                      'customer_ids': selectedCustomerIds.value
                          .map((id) => id.toString())
                          .toList(),
                      'send_option': selectedType.value == 'Send Now'
                          ? 'now'
                          : (selectedType.value == 'Send Later'
                                ? 'later'
                                : 'recurring'),
                      if (selectedType.value == 'Send Later') ...{
                        'scheduled_date': DateFormat(
                          'yyyy-MM-dd',
                        ).format(scheduledDate.value!),
                        'scheduled_time': scheduledTime.value != null
                            ? '${scheduledTime.value!.hour.toString().padLeft(2, '0')}:${scheduledTime.value!.minute.toString().padLeft(2, '0')}'
                            : DateFormat('HH:mm').format(DateTime.now()),
                      },
                      if (selectedType.value == 'Recurring') ...{
                        'scheduled_date': DateFormat(
                          'yyyy-MM-dd',
                        ).format(recurringStartDate.value!),
                        'scheduled_time': DateFormat(
                          'HH:mm',
                        ).format(DateTime.now()),
                        'recurring_frequency': recurringFrequency.value
                            .toLowerCase(),
                      },
                    };
                    final error = await ref
                        .read(broadcastProvider.notifier)
                        .sendBroadcast(body);
                    isSending.value = false;

                    if (!context.mounted) return;
                    if (error != null) {
                      AppSnackbar.showError(context, error);
                    } else {
                      AppSnackbar.showSuccess(
                        context,
                        'Broadcast sent successfully',
                      );
                      Navigator.pop(context);
                    }
                  },
                  backgroundColor: AppTheme.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BroadcastHistoryTab extends HookConsumerWidget {
  const _BroadcastHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(broadcastProvider);

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return Center(
            child: Text(
              'No broadcast history',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          itemCount: history.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = history[index];
            return ListTile(
              title: Text(
                item.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item.recipientCount} recipients',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM dd, yyyy HH:mm').format(item.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingWidget()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }
}

class _ScheduleField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _ScheduleField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.grey300),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: value.contains('/') || value.contains(':')
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
                Icon(icon, size: 18, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textPrimary),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: Color(0xFF9C27B0), // Purple color from the UI image
    );
  }
}
