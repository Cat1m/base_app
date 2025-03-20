import 'package:base_app/src/features/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Theme Preview'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Typography'),
              Tab(text: 'Colors'),
              Tab(text: 'Buttons'),
              Tab(text: 'Inputs'),
              Tab(text: 'Components'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TypographySection(),
            _ColorsSection(),
            _ButtonsSection(),
            _InputsSection(),
            _ComponentsSection(),
          ],
        ),
      ),
    );
  }
}

class _TypographySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Typography', style: textTheme.headlineLarge),
          const SizedBox(height: 24),

          _TextShowcase(
            label: 'Display Large',
            style: textTheme.displayLarge!,
            sample: 'Display Large Text',
          ),
          _TextShowcase(
            label: 'Display Medium',
            style: textTheme.displayMedium!,
            sample: 'Display Medium Text',
          ),
          _TextShowcase(
            label: 'Display Small',
            style: textTheme.displaySmall!,
            sample: 'Display Small Text',
          ),

          const Divider(height: 32),

          _TextShowcase(
            label: 'Headline Large',
            style: textTheme.headlineLarge!,
            sample: 'Headline Large Text',
          ),
          _TextShowcase(
            label: 'Headline Medium',
            style: textTheme.headlineMedium!,
            sample: 'Headline Medium Text',
          ),
          _TextShowcase(
            label: 'Headline Small',
            style: textTheme.headlineSmall!,
            sample: 'Headline Small Text',
          ),

          const Divider(height: 32),

          _TextShowcase(
            label: 'Body Large',
            style: textTheme.bodyLarge!,
            sample:
                'Body Large Text - The quick brown fox jumps over the lazy dog.',
          ),
          _TextShowcase(
            label: 'Body Medium',
            style: textTheme.bodyMedium!,
            sample:
                'Body Medium Text - The quick brown fox jumps over the lazy dog.',
          ),
          _TextShowcase(
            label: 'Body Small',
            style: textTheme.bodySmall!,
            sample:
                'Body Small Text - The quick brown fox jumps over the lazy dog.',
          ),

          const Divider(height: 32),

          _TextShowcase(
            label: 'Label Large',
            style: textTheme.labelLarge!,
            sample: 'Label Large Text',
          ),
          _TextShowcase(
            label: 'Label Medium',
            style: textTheme.labelMedium!,
            sample: 'Label Medium Text',
          ),
          _TextShowcase(
            label: 'Label Small',
            style: textTheme.labelSmall!,
            sample: 'Label Small Text',
          ),
        ],
      ),
    );
  }
}

class _TextShowcase extends StatelessWidget {
  final String label;
  final TextStyle style;
  final String sample;

  const _TextShowcase({
    required this.label,
    required this.style,
    required this.sample,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(sample, style: style),
          const SizedBox(height: 4),
          Text(
            'Size: ${style.fontSize}px, Weight: ${style.fontWeight}, Color: ${_colorToHex(style.color)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _colorToHex(Color? color) {
    if (color == null) return 'null';
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}

class _ColorsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Colors', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 24),

          Text('Theme Colors', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _ColorSwatch(
                name: 'Primary',
                color: theme.colorScheme.primary,
                variants: {
                  'Light': AppColors.primaryLight,
                  'Dark': AppColors.primaryDark,
                },
              ),
              _ColorSwatch(
                name: 'Background',
                color: theme.colorScheme.background,
              ),
              _ColorSwatch(name: 'Surface', color: theme.colorScheme.surface),
              _ColorSwatch(name: 'Error', color: theme.colorScheme.error),
            ],
          ),

          const SizedBox(height: 32),
          Text('Text Colors', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _ColorSwatch(name: 'Text Primary', color: AppColors.textPrimary),
              _ColorSwatch(
                name: 'Text Secondary',
                color: AppColors.textSecondary,
              ),
              _ColorSwatch(
                name: 'Text Disabled',
                color: AppColors.textDisabled,
              ),
            ],
          ),

          const SizedBox(height: 32),
          Text('State Colors', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _ColorSwatch(name: 'Success', color: AppColors.success),
              _ColorSwatch(name: 'Error', color: AppColors.error),
              _ColorSwatch(name: 'Warning', color: AppColors.warning),
              _ColorSwatch(name: 'Info', color: AppColors.info),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String name;
  final Color color;
  final Map<String, Color>? variants;

  const _ColorSwatch({required this.name, required this.color, this.variants});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardTheme.color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  _colorToHex(color),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),

                if (variants != null) ...[
                  const SizedBox(height: 8),
                  ...variants!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: entry.value,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}

class _ButtonsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buttons', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),

          _ButtonGroup(
            title: 'Filled Buttons',
            buttons: [
              _ButtonInfo(
                name: 'Default',
                button: FilledButton(
                  onPressed: () {},
                  child: const Text('Button'),
                ),
              ),
              _ButtonInfo(
                name: 'Disabled',
                button: FilledButton(
                  onPressed: null,
                  child: const Text('Button'),
                ),
              ),
              _ButtonInfo(
                name: 'With Icon',
                button: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Button'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _ButtonGroup(
            title: 'Outlined Buttons',
            buttons: [
              _ButtonInfo(
                name: 'Default',
                button: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Button'),
                ),
              ),
              _ButtonInfo(
                name: 'Disabled',
                button: OutlinedButton(
                  onPressed: null,
                  child: const Text('Button'),
                ),
              ),
              _ButtonInfo(
                name: 'With Icon',
                button: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Button'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _ButtonGroup(
            title: 'Text Buttons',
            buttons: [
              _ButtonInfo(
                name: 'Default',
                button: TextButton(
                  onPressed: () {},
                  child: const Text('Button'),
                ),
              ),
              _ButtonInfo(
                name: 'Disabled',
                button: TextButton(
                  onPressed: null,
                  child: const Text('Button'),
                ),
              ),
              _ButtonInfo(
                name: 'With Icon',
                button: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Button'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _ButtonGroup(
            title: 'Icon Buttons',
            buttons: [
              _ButtonInfo(
                name: 'Default',
                button: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite),
                ),
              ),
              _ButtonInfo(
                name: 'Disabled',
                button: IconButton(
                  onPressed: null,
                  icon: const Icon(Icons.favorite),
                ),
              ),
              _ButtonInfo(
                name: 'Filled',
                button: IconButton.filled(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Themed Button Variants',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Để demo extension theme
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 120, child: Text('Default Theme:')),
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Primary Button'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 120, child: Text('Warning Theme:')),
                    Theme(
                      data: Theme.of(context).warningButtonTheme,
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('Warning Button'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ButtonGroup extends StatelessWidget {
  final String title;
  final List<_ButtonInfo> buttons;

  const _ButtonGroup({required this.title, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...buttons.map((info) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    info.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                info.button,
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

class _ButtonInfo {
  final String name;
  final Widget button;

  const _ButtonInfo({required this.name, required this.button});
}

class _InputsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inputs', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),

          _InputExample(
            label: 'Default TextField',
            input: const TextField(
              decoration: InputDecoration(hintText: 'Enter text'),
            ),
          ),

          _InputExample(
            label: 'With Label',
            input: const TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Enter your username',
              ),
            ),
          ),

          _InputExample(
            label: 'With Prefix Icon',
            input: const TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search for something',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          _InputExample(
            label: 'With Suffix Icon',
            input: const TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                suffixIcon: Icon(Icons.visibility_off),
              ),
            ),
          ),

          _InputExample(
            label: 'With Helper Text',
            input: const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'user@example.com',
                helperText: 'Enter a valid email address',
              ),
            ),
          ),

          _InputExample(
            label: 'With Error',
            input: const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'user@example.com',
                errorText: 'Please enter a valid email',
              ),
            ),
          ),

          _InputExample(
            label: 'Disabled',
            input: const TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Disabled Input',
                hintText: 'Cannot edit this field',
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Selection Inputs',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          _SelectionInputsExample(),
        ],
      ),
    );
  }
}

class _InputExample extends StatelessWidget {
  final String label;
  final Widget input;

  const _InputExample({required this.label, required this.input});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          input,
        ],
      ),
    );
  }
}

class _SelectionInputsExample extends StatefulWidget {
  @override
  _SelectionInputsExampleState createState() => _SelectionInputsExampleState();
}

class _SelectionInputsExampleState extends State<_SelectionInputsExample> {
  bool checkboxValue1 = true;
  bool checkboxValue2 = false;
  bool switchValue1 = true;
  bool switchValue2 = false;
  int radioValue = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Checkboxes', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 16),
            Checkbox(
              value: checkboxValue1,
              onChanged: (value) {
                setState(() {
                  checkboxValue1 = value!;
                });
              },
            ),
            const SizedBox(width: 8),
            Checkbox(
              value: checkboxValue2,
              onChanged: (value) {
                setState(() {
                  checkboxValue2 = value!;
                });
              },
            ),
            const SizedBox(width: 8),
            Checkbox(value: false, onChanged: null),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Switches', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(width: 16),
            Switch(
              value: switchValue1,
              onChanged: (value) {
                setState(() {
                  switchValue1 = value;
                });
              },
            ),
            const SizedBox(width: 8),
            Switch(
              value: switchValue2,
              onChanged: (value) {
                setState(() {
                  switchValue2 = value;
                });
              },
            ),
            const SizedBox(width: 8),
            Switch(value: false, onChanged: null),
          ],
        ),
        const SizedBox(height: 16),
        Text('Radio Buttons', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Radio<int>(
              value: 1,
              groupValue: radioValue,
              onChanged: (value) {
                setState(() {
                  radioValue = value!;
                });
              },
            ),
            const Text('Option 1'),
            const SizedBox(width: 16),
            Radio<int>(
              value: 2,
              groupValue: radioValue,
              onChanged: (value) {
                setState(() {
                  radioValue = value!;
                });
              },
            ),
            const Text('Option 2'),
            const SizedBox(width: 16),
            Radio<int>(value: 3, groupValue: radioValue, onChanged: null),
            const Text('Disabled'),
          ],
        ),
      ],
    );
  }
}

class _ComponentsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Components', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),

          // Cards
          Text('Cards', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Card',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is a simple card component with default styling from your theme.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.album),
                  title: const Text('Card with List Tile'),
                  subtitle: const Text('Secondary text'),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'A card can contain list tiles and other widgets to create more complex layouts.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () {}, child: const Text('CANCEL')),
                    FilledButton(onPressed: () {}, child: const Text('ACTION')),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Dialogs
          Text('Dialogs', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Alert Dialog'),
                          content: const Text(
                            'This is an example of an alert dialog with buttons.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('CANCEL'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  );
                },
                child: const Text('Show Alert Dialog'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (context) => SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Modal Bottom Sheet',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'This is an example of a modal bottom sheet.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('CLOSE'),
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                },
                child: const Text('Show Bottom Sheet'),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Chips
          Text('Chips', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const Chip(
                label: Text('Basic Chip'),
                avatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person, size: 16),
                ),
              ),
              const Chip(
                label: Text('With Delete'),
                deleteIcon: Icon(Icons.cancel, size: 16),
                onDeleted: null,
              ),
              InputChip(
                label: const Text('Input Chip'),
                onPressed: () {},
                avatar: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.tag, size: 16),
                ),
              ),
              FilterChip(
                label: const Text('Filter Chip'),
                selected: true,
                onSelected: (bool value) {},
              ),
              ActionChip(
                label: const Text('Action Chip'),
                avatar: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.play_arrow, size: 16),
                ),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 32),

          // List
          Text('Lists', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('User Name'),
                  subtitle: Text('user@example.com'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Phone Number'),
                  subtitle: Text('+1 (555) 123-4567'),
                  trailing: Icon(Icons.edit, size: 16),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('Address'),
                  subtitle: Text('1234 Main St, Anytown, USA'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Progress Indicators
          Text(
            'Progress Indicators',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: 0.3),
                    SizedBox(height: 16),
                    LinearProgressIndicator(value: 0.7),
                    SizedBox(height: 16),
                    LinearProgressIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
