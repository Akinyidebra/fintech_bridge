import 'package:fintech_bridge/screens/admin/admin_student_details_screen.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/widgets/admin_student_item_card.dart';
import 'package:fintech_bridge/widgets/admin_students_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/student_model.dart';

class AdminStudentContent extends StatefulWidget {
  const AdminStudentContent({super.key});

  @override
  State<AdminStudentContent> createState() => _AdminStudentContentState();
}

class _AdminStudentContentState extends State<AdminStudentContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  List<Student> _allStudents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStudentsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final result = await dbService.getAllStudents();

      if (result['success']) {
        setState(() {
          _allStudents = result['data'] as List<Student>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load students';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading students: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadStudentsData();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while data is being fetched
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading students...',
        isFullScreen: false,
      );
    }

    // Show error state with retry option
    if (_errorMessage != null) {
      return Padding(
        padding:
            const EdgeInsets.only(top: 24.0), // Add top spacing for error state
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppConstants.errorColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: AppConstants.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: AppConstants.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _refreshData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Tab Bar with improved spacing
        AdminStudentsTabBar(controller: _tabController),

        const SizedBox(height: 16), // Space between tab bar and content

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStudentsTab('ALL'),
              _buildStudentsTab('PENDING'),
              _buildStudentsTab('VERIFIED'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsTab(String filter) {
    final filteredStudents = _filterStudents(_allStudents, filter);

    if (filteredStudents.isEmpty) {
      return _buildEmptyState(filter);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Adjusted padding
        itemCount: filteredStudents.length,
        itemBuilder: (context, index) => AdminStudentItemCard(
          student: filteredStudents[index],
          onTap: () => _navigateToStudentDetails(filteredStudents[index]),
        ),
      ),
    );
  }

  List<Student> _filterStudents(List<Student> students, String filter) {
    if (filter == 'ALL') {
      return students;
    } else if (filter == 'VERIFIED') {
      return students.where((student) => student.verified == true).toList();
    } else if (filter == 'PENDING') {
      return students.where((student) => student.verified == false).toList();
    }
    return students;
  }

  Widget _buildEmptyState(String filter) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color:
                        AppConstants.backgroundSecondaryColor.withOpacity(0.8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: 56,
                    color: AppConstants.textSecondaryColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  filter == 'ALL'
                      ? 'No students yet'
                      : 'No ${filter.toLowerCase()} students',
                  style: AppConstants.headlineSmall.copyWith(
                    color: AppConstants.textColor,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  filter == 'ALL'
                      ? 'Students will appear here once they register'
                      : 'You don\'t have any ${filter.toLowerCase()} students at the moment',
                  style: AppConstants.bodyMedium.copyWith(
                    color: AppConstants.textSecondaryColor,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _refreshData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      shadowColor: AppConstants.primaryColor.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToStudentDetails(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminStudentDetailsScreen(
          studentId: student.id,
        ),
      ),
    ).then((_) => _refreshData());
  }
}
