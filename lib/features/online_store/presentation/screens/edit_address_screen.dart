import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/app_dropdown.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/custom_text_field.dart';
import 'package:onepos_admin_app/core/utils/validators.dart';

/// Screen for editing the address
class EditAddressScreen extends HookConsumerWidget {
  const EditAddressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final streetController = useTextEditingController(
      text: 'No 23 Cactus Jack St',
    );
    final selectedCountry = useState<String?>('Nigeria');
    final selectedState = useState<String?>('Lagos');
    final selectedCity = useState<String?>('City'); // from design

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Edit Address',
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppDropdown<String>(
                  hint: 'Country',
                  value: selectedCountry.value,
                  items: const [
                    DropdownMenuItem(value: 'Nigeria', child: Text('Nigeria')),
                    DropdownMenuItem(value: 'USA', child: Text('USA')),
                    DropdownMenuItem(value: 'UK', child: Text('UK')),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedCountry.value = val;
                  },
                  validator: (val) =>
                      Validators.validateRequired(val, 'Country'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                AppDropdown<String>(
                  hint: 'State',
                  value: selectedState.value,
                  items: const [
                    DropdownMenuItem(value: 'Lagos', child: Text('Lagos')),
                    DropdownMenuItem(value: 'Abuja', child: Text('Abuja')),
                    DropdownMenuItem(value: 'Kano', child: Text('Kano')),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedState.value = val;
                  },
                  validator: (val) => Validators.validateRequired(val, 'State'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                AppDropdown<String>(
                  hint: 'City',
                  value: selectedCity.value,
                  items: const [
                    DropdownMenuItem(
                      value: 'City',
                      child: Text('City'),
                    ), // using 'City' per design
                    DropdownMenuItem(value: 'Ikeja', child: Text('Ikeja')),
                    DropdownMenuItem(
                      value: 'Victoria Island',
                      child: Text('Victoria Island'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedCity.value = val;
                  },
                  validator: (val) => Validators.validateRequired(val, 'City'),
                ),
                const SizedBox(height: AppTheme.spacingMedium),

                CustomTextField(
                  hint: 'Street Address',
                  controller: streetController,
                  validator: (val) =>
                      Validators.validateRequired(val, 'Street Address'),
                ),

                const Spacer(),

                CustomButton(
                  text: 'Save',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                    }
                  },
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
