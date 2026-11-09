import 'package:flutter/material.dart';
import 'package:mpm/model/AddDoctor/AddDoctorModel.dart';
import 'package:mpm/model/search/SearchData.dart';
import 'package:mpm/repository/add_doctor_repository/add_doctor_repo.dart';
import 'package:mpm/repository/register_repository/register_repo.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/urls.dart';

class AddDoctorChoiceView extends StatefulWidget {
  final void Function(SearchData? member, AddDoctorRepository repository) onAddDoctor;

  const AddDoctorChoiceView({super.key, required this.onAddDoctor});

  @override
  State<AddDoctorChoiceView> createState() => _AddDoctorChoiceViewState();
}

class _AddDoctorChoiceViewState extends State<AddDoctorChoiceView> {
  final TextEditingController _searchController = TextEditingController();
  final RegisterRepository _registerRepo = RegisterRepository();
  final AddDoctorRepository _addDoctorRepository = AddDoctorRepository();

  bool _searchingMember = false;
  bool _isLoading = false;
  String? _error;
  List<SearchData> _results = [];
  SearchData? _selectedMember;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMember() async {
    final query = _searchController.text.trim();
    if (query.length < 4) {
      setState(() {
        _error = 'Enter at least 4 characters of the membership code or mobile number';
        _results = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
      _selectedMember = null;
    });

    try {
      final response = await _registerRepo.userCheckLMCodeApi(Uri.encodeComponent(query));
      if (!mounted) return;
      final matches = (response.data ?? []).where((member) => _matchesQuery(member, query)).toList();
      setState(() {
        _isLoading = false;
        _results = matches;
        _error = matches.isEmpty ? 'No member found' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Unable to search members';
      });
    }
  }

  bool _matchesQuery(SearchData member, String query) {
    final normalized = query.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');
    final code = (member.memberCode ?? '').toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final mobile = (member.mobile ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final codeMatch = code.isNotEmpty && code.contains(normalized);
    final mobileMatch = digits.isNotEmpty && mobile.contains(digits);
    return codeMatch || mobileMatch;
  }

  String _fullName(SearchData member) {
    return [member.firstName, member.middleName, member.lastName]
        .where((part) => part != null && part.trim().isNotEmpty && part.trim() != 'null')
        .map((part) => part!.trim())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorHelperClass.getColorFromHex(ColorResources.red_color);
    final logoColor = ColorHelperClass.getColorFromHex(ColorResources.logo_color);

    return PopScope(
      canPop: !_searchingMember,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _searchingMember) {
          setState(() => _searchingMember = false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        appBar: AppBar(
          backgroundColor: logoColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            _searchingMember ? 'Add existing member' : 'Add Doctor',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_searchingMember) {
                setState(() {
                  _searchingMember = false;
                  _selectedMember = null;
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: _searchingMember
            ? _buildMemberSearch(themeColor)
            : _buildOptions(themeColor),
        bottomNavigationBar: _searchingMember && _selectedMember != null
            ? _buildAddDoctorBar(themeColor)
            : null,
      ),
    );
  }

  Widget _buildOptions(Color themeColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Select an option',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2430),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Add a doctor from an existing member, or enter a new doctor.',
          style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF6D7278)),
        ),
        const SizedBox(height: 16),
        _OptionCard(
          icon: Icons.person_search_outlined,
          title: 'Already existing mandal member',
          subtitle: 'Search by membership code or mobile number',
          themeColor: themeColor,
          onTap: () => setState(() {
            _searchingMember = true;
            _selectedMember = null;
          }),
        ),
        const SizedBox(height: 12),
        _OptionCard(
          icon: Icons.medical_services_outlined,
          title: 'To become mandal member',
          subtitle: 'Fill the doctor details form',
          themeColor: themeColor,
          onTap: () => widget.onAddDoctor(null, _addDoctorRepository),
        ),
      ],
    );
  }

  Widget _buildMemberSearch(Color themeColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchMember(),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1F2430)),
                  decoration: InputDecoration(
                    hintText: 'Membership code or mobile number',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9AA0A8)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF8A9099)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: const BorderSide(color: Color(0xFFE6E8EC)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide(color: themeColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _searchMember,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Search', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildSearchBody(themeColor)),
      ],
    );
  }

  Widget _buildSearchBody(Color themeColor) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: themeColor));
    }
    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _error ?? 'Search a member by membership code or mobile number',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8A9099),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final member = _results[index];
        final selected = _isSameMember(member, _selectedMember);
        return _MemberResultCard(
          member: member,
          fullName: _fullName(member),
          selected: selected,
          themeColor: themeColor,
          onTap: () => setState(() => _selectedMember = member),
        );
      },
    );
  }

  void _continueWithMember() {
    final member = _selectedMember;
    if (member == null) return;

    final memberId = AddDoctorRequest.parseId(member.memberId);
    if (memberId == null || memberId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected member is missing a member id')),
      );
      return;
    }

    widget.onAddDoctor(member, _addDoctorRepository);
  }

  bool _isSameMember(SearchData member, SearchData? selected) {
    if (selected == null) return false;
    final memberId = member.memberId ?? '';
    final selectedId = selected.memberId ?? '';
    if (memberId.isNotEmpty && memberId == selectedId) return true;
    return member.memberCode == selected.memberCode && member.mobile == selected.mobile;
  }

  Widget _buildAddDoctorBar(Color themeColor) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E6E6))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _continueWithMember,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Add Doctor',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color themeColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6E8EC)),
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: themeColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2430),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12.5, height: 1.3, color: Color(0xFF6D7278)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF8A9099)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberResultCard extends StatelessWidget {
  final SearchData member;
  final String fullName;
  final bool selected;
  final Color themeColor;
  final VoidCallback onTap;

  const _MemberResultCard({
    required this.member,
    required this.fullName,
    required this.selected,
    required this.themeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = (member.profileImage ?? '').trim();
    final isDeceased = member.memberStatusId == '4';

    return Material(
      color: selected ? themeColor.withValues(alpha: 0.06) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? themeColor : const Color(0xFFE6E8EC), width: selected ? 1.5 : 1),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              height: 52,
              width: 52,
              child: image.isEmpty
                  ? Image.asset('assets/images/user3.png', fit: BoxFit.cover)
                  : Image.network(
                      image.startsWith('http') ? image : '${Urls.imagePathUrl}$image',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Image.asset('assets/images/user3.png', fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isEmpty ? 'Member' : fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2430),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.memberCode ?? '',
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF4B5160)),
                ),
                const SizedBox(height: 2),
                Text(
                  member.mobile ?? '',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E9E5B),
                  ),
                ),
              ],
            ),
          ),
          if (isDeceased)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Deceased',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE61428),
                ),
              ),
            )
          else if (selected)
            Icon(Icons.check_circle, color: themeColor, size: 22),
        ],
      ),
        ),
      ),
    );
  }
}
