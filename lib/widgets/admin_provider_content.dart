import 'package:fintech_bridge/screens/admin/admin_provider_details_screen.dart';
import 'package:fintech_bridge/screens/loading_screen.dart';
import 'package:fintech_bridge/services/database_service.dart';
import 'package:fintech_bridge/widgets/admin_provider_item_card.dart';
import 'package:fintech_bridge/widgets/admin_provider_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_bridge/utils/constants.dart';
import 'package:fintech_bridge/models/provider_model.dart' as provider_model;

class AdminProviderContent extends StatefulWidget {
  final provider_model.Provider? provider;

  const AdminProviderContent({super.key, this.provider});

  @override
  State<AdminProviderContent> createState() => _AdminProviderContentState();
}

class _AdminProviderContentState extends State<AdminProviderContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  List<provider_model.Provider>? _allProviders;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProvidersData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProvidersData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      // You'll need to implement getAllProviders() in your DatabaseService
      final result = await dbService.getAllProviders();

      if (result['success']) {
        setState(() {
          _allProviders = result['data'] as List<provider_model.Provider>?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load providers';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading providers: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadProvidersData();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while data is being fetched
    if (_isLoading) {
      return const LoadingScreen(
        message: 'Loading providers...',
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
        AdminProvidersTabBar(controller: _tabController),

        const SizedBox(height: 16), // Space between tab bar and content

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProvidersTab('ALL'),
              _buildProvidersTab('PENDING'),
              _buildProvidersTab('VERIFIED'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProvidersTab(String filter) {
    final filteredProviders = _filterProviders(_allProviders ?? [], filter);

    if (filteredProviders.isEmpty) {
      return _buildEmptyState(filter);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Adjusted padding
        itemCount: filteredProviders.length,
        itemBuilder: (context, index) => AdminProviderItemCard(
          provider: filteredProviders[index],
          onTap: () => _navigateToProviderDetails(filteredProviders[index]),
        ),
      ),
    );
  }

  List<provider_model.Provider> _filterProviders(
      List<provider_model.Provider> providers, String filter) {
    if (filter == 'ALL') {
      return providers;
    } else if (filter == 'VERIFIED') {
      return providers.where((provider) => provider.verified == true).toList();
    } else if (filter == 'PENDING') {
      return providers.where((provider) => provider.verified == false).toList();
    }
    return providers;
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
                    Icons.business_outlined,
                    size: 56,
                    color: AppConstants.textSecondaryColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  filter == 'ALL'
                      ? 'No providers yet'
                      : 'No ${filter.toLowerCase()} providers',
                  style: AppConstants.headlineSmall.copyWith(
                    color: AppConstants.textColor,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  filter == 'ALL'
                      ? 'Providers will appear here once they register'
                      : 'You don\'t have any ${filter.toLowerCase()} providers at the moment',
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

  void _navigateToProviderDetails(provider_model.Provider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProviderDetailsScreen(
          providerId: provider.id,
        ),
      ),
    ).then((_) => _refreshData());
  }
}
