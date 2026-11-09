import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodDonor {
  const BloodDonor({
    required this.name,
    required this.mobile,
    required this.bloodGroup,
    required this.zone,
  });

  final String name;
  final String mobile;
  final String bloodGroup;
  final String zone;
}

class BloodDonorView extends StatefulWidget {
  const BloodDonorView({super.key});

  @override
  State<BloodDonorView> createState() => _BloodDonorViewState();
}

class _BloodDonorViewState extends State<BloodDonorView> {
  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];

  static const List<String> zones = [
    'Andheri',
    'Bandra',
    'Borivali',
    'Chembur',
    'Dadar',
    'Ghatkopar',
    'Goregaon',
    'Kandivali',
    'Malad',
    'Mulund',
    'Thane',
    'Vile Parle',
  ];

  final List<BloodDonor> _donors = [
    const BloodDonor(name: 'Rahul Maheshwari', mobile: '9820011122', bloodGroup: 'O+', zone: 'Andheri'),
    const BloodDonor(name: 'Priya Somani', mobile: '9876543210', bloodGroup: 'B+', zone: 'Ghatkopar'),
    const BloodDonor(name: 'Amit Rathi', mobile: '9811122233', bloodGroup: 'A+', zone: 'Borivali'),
    const BloodDonor(name: 'Neha Kabra', mobile: '9765432109', bloodGroup: 'AB+', zone: 'Dadar'),
    const BloodDonor(name: 'Vikas Lohia', mobile: '9898989898', bloodGroup: 'O-', zone: 'Malad'),
    const BloodDonor(name: 'Sneha Bang', mobile: '9700012345', bloodGroup: 'A-', zone: 'Mulund'),
    const BloodDonor(name: 'Karan Jaju', mobile: '9922334455', bloodGroup: 'B-', zone: 'Thane'),
    const BloodDonor(name: 'Anjali Daga', mobile: '9810098765', bloodGroup: 'AB-', zone: 'Chembur'),
    const BloodDonor(name: 'Rohit Mohta', mobile: '9887766554', bloodGroup: 'O+', zone: 'Kandivali'),
    const BloodDonor(name: 'Pooja Heda', mobile: '9755566677', bloodGroup: 'B+', zone: 'Vile Parle'),
    const BloodDonor(name: 'Suresh Ladha', mobile: '9833344455', bloodGroup: 'A+', zone: 'Goregaon'),
    const BloodDonor(name: 'Meera Soni', mobile: '9900011223', bloodGroup: 'O+', zone: 'Bandra'),
  ];

  _DonorScreen _screen = _DonorScreen.options;

  void _openList() => setState(() => _screen = _DonorScreen.list);

  void _openAdd() => setState(() => _screen = _DonorScreen.add);

  void _backToOptions() => setState(() => _screen = _DonorScreen.options);

  void _addDonor(BloodDonor donor) {
    setState(() {
      _donors.insert(0, donor);
      _screen = _DonorScreen.list;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added as a blood donor'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoColor = ColorHelperClass.getColorFromHex(ColorResources.logo_color);

    return PopScope(
      canPop: _screen == _DonorScreen.options,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToOptions();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          backgroundColor: logoColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            _screen == _DonorScreen.add
                ? 'Add as a donor'
                : _screen == _DonorScreen.list
                    ? 'Blood donors'
                    : 'Blood Donor',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_screen == _DonorScreen.options) {
                Navigator.pop(context);
              } else {
                _backToOptions();
              }
            },
          ),
        ),
        body: switch (_screen) {
          _DonorScreen.options => _DonorOptions(
              donorCount: _donors.length,
              onList: _openList,
              onAdd: _openAdd,
            ),
          _DonorScreen.list => _DonorList(
              donors: _donors,
              zones: zones,
              bloodGroups: bloodGroups,
              onAdd: _openAdd,
            ),
          _DonorScreen.add => _AddDonorForm(
              zones: zones,
              bloodGroups: bloodGroups,
              onSave: _addDonor,
            ),
        },
      ),
    );
  }
}

enum _DonorScreen { options, list, add }

class _DonorOptions extends StatelessWidget {
  const _DonorOptions({
    required this.donorCount,
    required this.onList,
    required this.onAdd,
  });

  final int donorCount;
  final VoidCallback onList;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final accent = ColorHelperClass.getColorFromHex(ColorResources.red_color);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.bloodtype, color: accent),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Reach a blood donor from any zone when blood is needed.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _OptionCard(
          icon: Icons.list_alt,
          title: 'List of blood donors',
          subtitle: '$donorCount donors across all zones',
          onTap: onList,
        ),
        const SizedBox(height: 12),
        _OptionCard(
          icon: Icons.person_add_alt_1,
          title: 'Add as a donor',
          subtitle: 'Share your name, mobile and blood group',
          onTap: onAdd,
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = ColorHelperClass.getColorFromHex(ColorResources.logo_color);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonorList extends StatefulWidget {
  const _DonorList({
    required this.donors,
    required this.zones,
    required this.bloodGroups,
    required this.onAdd,
  });

  final List<BloodDonor> donors;
  final List<String> zones;
  final List<String> bloodGroups;
  final VoidCallback onAdd;

  @override
  State<_DonorList> createState() => _DonorListState();
}

class _DonorListState extends State<_DonorList> {
  final TextEditingController _searchController = TextEditingController();
  String _zone = 'All zones';
  String _bloodGroup = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BloodDonor> get _visibleDonors {
    final query = _searchController.text.trim().toLowerCase();
    return widget.donors.where((donor) {
      final matchesZone = _zone == 'All zones' || donor.zone == _zone;
      final matchesGroup = _bloodGroup == 'All' || donor.bloodGroup == _bloodGroup;
      final matchesQuery = query.isEmpty ||
          donor.name.toLowerCase().contains(query) ||
          donor.mobile.contains(query) ||
          donor.zone.toLowerCase().contains(query);
      return matchesZone && matchesGroup && matchesQuery;
    }).toList();
  }

  Future<void> _callDonor(String mobile) async {
    final uri = Uri(scheme: 'tel', path: mobile);
    if (!await launchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the phone dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final donors = _visibleDonors;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search name, mobile or zone',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _FilterChip(
                label: 'All',
                selected: _bloodGroup == 'All',
                onTap: () => setState(() => _bloodGroup = 'All'),
              ),
              ...widget.bloodGroups.map(
                (group) => _FilterChip(
                  label: group,
                  selected: _bloodGroup == group,
                  onTap: () => setState(() => _bloodGroup = group),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: DropdownButtonFormField<String>(
            value: _zone,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: ['All zones', ...widget.zones]
                .map((zone) => DropdownMenuItem(value: zone, child: Text(zone)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _zone = value);
            },
          ),
        ),
        Expanded(
          child: donors.isEmpty
              ? Center(
                  child: Text(
                    'No donors for this filter',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                  itemCount: donors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final donor = donors[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 48,
                            width: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              donor.bloodGroup,
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donor.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  donor.mobile,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  donor.zone,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _callDonor(donor.mobile),
                            icon: const Icon(Icons.call, size: 18),
                            label: const Text('Call'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Add as a donor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = ColorHelperClass.getColorFromHex(ColorResources.logo_color);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: accent.withValues(alpha: 0.16),
        labelStyle: TextStyle(
          color: selected ? accent : Colors.black87,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _AddDonorForm extends StatefulWidget {
  const _AddDonorForm({
    required this.zones,
    required this.bloodGroups,
    required this.onSave,
  });

  final List<String> zones;
  final List<String> bloodGroups;
  final ValueChanged<BloodDonor> onSave;

  @override
  State<_AddDonorForm> createState() => _AddDonorFormState();
}

class _AddDonorFormState extends State<_AddDonorForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  String? _bloodGroup;
  String? _zone;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      BloodDonor(
        name: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        bloodGroup: _bloodGroup!,
        zone: _zone!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Members can call you when your blood group is needed.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          _field(
            controller: _nameController,
            label: 'Name',
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Enter the donor name';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _field(
            controller: _mobileController,
            label: 'Mobile number',
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            validator: (value) {
              if (value == null || value.trim().length != 10) return 'Enter a 10-digit mobile number';
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _bloodGroup,
            decoration: _decoration('Blood group'),
            items: widget.bloodGroups
                .map((group) => DropdownMenuItem(value: group, child: Text(group)))
                .toList(),
            onChanged: (value) => setState(() => _bloodGroup = value),
            validator: (value) => value == null ? 'Select a blood group' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _zone,
            decoration: _decoration('Zone'),
            items: widget.zones
                .map((zone) => DropdownMenuItem(value: zone, child: Text(zone)))
                .toList(),
            onChanged: (value) => setState(() => _zone = value),
            validator: (value) => value == null ? 'Select a zone' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorHelperClass.getColorFromHex(ColorResources.logo_color),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add as a donor'),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: _decoration(label),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
