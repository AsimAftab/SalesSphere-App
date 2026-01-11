import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sales_sphere/core/constants/app_colors.dart';
import 'package:sales_sphere/features/notes/vm/notes.vm.dart';
import 'package:sales_sphere/features/notes/models/notes.model.dart';

/// Enum for filtering notes by entity type
enum NoteFilter { all, party, prospect, site }

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  NoteFilter _activeFilter = NoteFilter.all;

  void _navigateToAddNote() {
    context.push('/add-notes');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date).toLocal();
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  List<NoteListItem> _applyFilter(List<NoteListItem> notes, String query) {
    return notes.where((note) {
      final matchesSearch =
          note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.name.toLowerCase().contains(query.toLowerCase());

      bool matchesCategory = true;

      switch (_activeFilter) {
        case NoteFilter.party:
          matchesCategory = note.entityType == 'party';
          break;
        case NoteFilter.prospect:
          matchesCategory = note.entityType == 'prospect';
          break;
        case NoteFilter.site:
          matchesCategory = note.entityType == 'site';
          break;
        case NoteFilter.all:
          matchesCategory = true;
      }
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(searchedNotesProvider);
    final searchQuery = ref.watch(noteSearchQueryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.textdark),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notes',
          style: TextStyle(
            color: AppColors.textdark,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/corner_bubble.svg',
              fit: BoxFit.cover,
              height: 180.h,
            ),
          ),
          Column(
            children: [
              Container(height: 120.h, color: Colors.transparent),
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => ref
                      .read(noteSearchQueryProvider.notifier)
                      .updateQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search notes',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14.sp,
                      fontFamily: 'Poppins',
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 20.sp,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
              _buildFilterDropdown(),
              SizedBox(height: 12.h),
              Expanded(
                child: notesAsync.when(
                  data: (notes) {
                    final filteredList = _applyFilter(notes, searchQuery);
                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(notesViewModelProvider.notifier).refresh(),
                      color: AppColors.primary,
                      child: filteredList.isEmpty
                          ? _buildEmptyState(searchQuery)
                          : ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                8.h,
                                16.w,
                                80.h,
                              ),
                              itemCount: filteredList.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final note = filteredList[index];
                                return GestureDetector(
                                  onTap: () {
                                    context.push('/edit-notes/${note.id}');
                                  },
                                  child: _buildNoteCard(note),
                                );
                              },
                            ),
                    );
                  },
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
                      itemCount: 5,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (_, __) => Container(
                        height: 120.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddNote,
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Notes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 12.w),
          Text(
            'Filter:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textdark,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<NoteFilter>(
                value: _activeFilter,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  fontFamily: 'Poppins',
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                items: [
                  _buildFilterItem(
                    NoteFilter.all,
                    'All Notes',
                    Icons.list,
                    AppColors.textdark,
                  ),
                  _buildFilterItem(
                    NoteFilter.party,
                    'Parties',
                    Icons.store_outlined,
                    Colors.blue,
                  ),
                  _buildFilterItem(
                    NoteFilter.prospect,
                    'Prospects',
                    Icons.person_search_outlined,
                    Colors.orange,
                  ),
                  _buildFilterItem(
                    NoteFilter.site,
                    'Sites',
                    Icons.location_city_outlined,
                    Colors.green,
                  ),
                ],
                onChanged: (newValue) {
                  if (newValue != null)
                    setState(() => _activeFilter = newValue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<NoteFilter> _buildFilterItem(
    NoteFilter value,
    String text,
    IconData icon,
    Color iconColor,
  ) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: iconColor),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textdark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(NoteListItem note) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textdark,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 12.h),
          _InfoRow(icon: Icons.person_outline, text: note.name),
          SizedBox(height: 8.h),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: _formatDate(note.date),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String searchQuery) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
      children: [
        SizedBox(height: 100.h),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.notes_rounded,
                size: 64.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16.h),
              Text(
                searchQuery.isEmpty
                    ? 'No notes found'
                    : 'No results for "$searchQuery"',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade400),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade500,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
