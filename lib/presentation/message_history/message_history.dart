import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import './widgets/conversation_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/multi_select_action_bar_widget.dart';
import './widgets/search_bar_widget.dart';

class MessageHistory extends StatefulWidget {
  const MessageHistory({super.key});

  @override
  State<MessageHistory> createState() => _MessageHistoryState();
}

class _MessageHistoryState extends State<MessageHistory>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // State variables
  List<Map<String, dynamic>> _allConversations = [];
  List<Map<String, dynamic>> _filteredConversations = [];
  Set<String> _selectedConversations = {};
  bool _isMultiSelectMode = false;
  String _searchQuery = '';
  String _selectedSortOption = 'recent';
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    setState(() {
      _isLoading = true;
    });

    // Mock conversation data
    _allConversations = [
      {
        "id": "conv_001",
        "deviceName": "ESP32-Rescue-01",
        "lastMessage":
            "Emergency beacon activated. Location: 40.7128° N, 74.0060° W. Battery at 85%. All team members accounted for.",
        "timestamp": DateTime.now().subtract(const Duration(minutes: 15)),
        "unreadCount": 3,
        "isOnline": true,
        "messageCount": 47,
        "isArchived": false,
      },
      {
        "id": "conv_002",
        "deviceName": "Arduino-Field-02",
        "lastMessage":
            "Weather update: Temperature 22°C, humidity 65%, wind speed 12 km/h. Visibility good for operations.",
        "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
        "unreadCount": 0,
        "isOnline": false,
        "messageCount": 23,
        "isArchived": false,
      },
      {
        "id": "conv_003",
        "deviceName": "HC-05-Mobile-03",
        "lastMessage":
            "Base camp established. Coordinates shared with all units. Supply drop scheduled for 14:00 hours.",
        "timestamp": DateTime.now().subtract(const Duration(hours: 4)),
        "unreadCount": 1,
        "isOnline": true,
        "messageCount": 89,
        "isArchived": false,
      },
      {
        "id": "conv_004",
        "deviceName": "ESP32-Tactical-04",
        "lastMessage":
            "Perimeter secured. Motion sensors active. Night vision operational. Standing by for further instructions.",
        "timestamp": DateTime.now().subtract(const Duration(days: 1)),
        "unreadCount": 0,
        "isOnline": false,
        "messageCount": 156,
        "isArchived": false,
      },
      {
        "id": "conv_005",
        "deviceName": "Arduino-Sensor-05",
        "lastMessage":
            "Environmental readings normal. Air quality index: 45. Radiation levels within safe parameters.",
        "timestamp": DateTime.now().subtract(const Duration(days: 2)),
        "unreadCount": 2,
        "isOnline": true,
        "messageCount": 34,
        "isArchived": false,
      },
      {
        "id": "conv_006",
        "deviceName": "HC-05-Backup-06",
        "lastMessage":
            "Backup communication link established. Primary channel restored. All systems operational.",
        "timestamp": DateTime.now().subtract(const Duration(days: 3)),
        "unreadCount": 0,
        "isOnline": false,
        "messageCount": 12,
        "isArchived": true,
      },
      {
        "id": "conv_007",
        "deviceName": "ESP32-Remote-07",
        "lastMessage":
            "Signal strength optimal. Data transmission complete. Awaiting next scheduled check-in at 18:00.",
        "timestamp": DateTime.now().subtract(const Duration(days: 5)),
        "unreadCount": 0,
        "isOnline": false,
        "messageCount": 67,
        "isArchived": true,
      },
    ];

    _applyFilters();

    setState(() {
      _isLoading = false;
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allConversations);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((conv) {
        final deviceName = (conv['deviceName'] as String).toLowerCase();
        final lastMessage = (conv['lastMessage'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return deviceName.contains(query) || lastMessage.contains(query);
      }).toList();
    }

    // Apply date range filter
    if (_selectedDateRange != null) {
      filtered = filtered.where((conv) {
        final timestamp = conv['timestamp'] as DateTime;
        return timestamp.isAfter(_selectedDateRange!.start) &&
            timestamp
                .isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply archive filter based on current tab
    final currentTab = _tabController.index;
    if (currentTab == 0) {
      // History tab - show non-archived
      filtered =
          filtered.where((conv) => !(conv['isArchived'] as bool)).toList();
    } else {
      // Archived tab - show archived
      filtered =
          filtered.where((conv) => (conv['isArchived'] as bool)).toList();
    }

    // Apply sorting
    switch (_selectedSortOption) {
      case 'recent':
        filtered.sort((a, b) =>
            (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
        break;
      case 'alphabetical':
        filtered.sort((a, b) =>
            (a['deviceName'] as String).compareTo(b['deviceName'] as String));
        break;
      case 'most_active':
        filtered.sort((a, b) =>
            (b['messageCount'] as int).compareTo(a['messageCount'] as int));
        break;
      case 'unread_first':
        filtered.sort((a, b) {
          final aUnread = a['unreadCount'] as int;
          final bUnread = b['unreadCount'] as int;
          if (aUnread == 0 && bUnread == 0) {
            return (b['timestamp'] as DateTime)
                .compareTo(a['timestamp'] as DateTime);
          }
          return bUnread.compareTo(aUnread);
        });
        break;
    }

    setState(() {
      _filteredConversations = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedSortOption: _selectedSortOption,
        selectedDateRange: _selectedDateRange,
        onSortChanged: (sort) {
          setState(() {
            _selectedSortOption = sort;
          });
        },
        onDateRangeChanged: (dateRange) {
          setState(() {
            _selectedDateRange = dateRange;
          });
        },
        onApplyFilters: _applyFilters,
        onClearFilters: () {
          setState(() {
            _selectedSortOption = 'recent';
            _selectedDateRange = null;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _onConversationTap(Map<String, dynamic> conversation) {
    if (_isMultiSelectMode) {
      _toggleSelection(conversation['id'] as String);
    } else {
      Navigator.pushNamed(context, '/chat-interface', arguments: conversation);
    }
  }

  void _toggleSelection(String conversationId) {
    setState(() {
      if (_selectedConversations.contains(conversationId)) {
        _selectedConversations.remove(conversationId);
        if (_selectedConversations.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedConversations.add(conversationId);
      }
    });
  }

  void _enterMultiSelectMode(String conversationId) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedConversations.add(conversationId);
    });
  }

  void _clearSelection() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedConversations.clear();
    });
  }

  void _markAsRead(String conversationId) {
    setState(() {
      final index =
          _allConversations.indexWhere((conv) => conv['id'] == conversationId);
      if (index != -1) {
        _allConversations[index]['unreadCount'] = 0;
      }
    });
    _applyFilters();
    Fluttertoast.showToast(msg: 'Conversation marked as read');
  }

  void _deleteConversation(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Conversation'),
        content: Text(
            'Are you sure you want to delete this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allConversations
                    .removeWhere((conv) => conv['id'] == conversationId);
              });
              _applyFilters();
              Navigator.pop(context);
              Fluttertoast.showToast(msg: 'Conversation deleted');
            },
            child: Text('Delete',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _archiveConversation(String conversationId) {
    setState(() {
      final index =
          _allConversations.indexWhere((conv) => conv['id'] == conversationId);
      if (index != -1) {
        _allConversations[index]['isArchived'] =
            !(_allConversations[index]['isArchived'] as bool);
      }
    });
    _applyFilters();
    Fluttertoast.showToast(msg: 'Conversation archived');
  }

  Future<void> _exportConversation(String conversationId) async {
    final conversation =
        _allConversations.firstWhere((conv) => conv['id'] == conversationId);
    final deviceName = conversation['deviceName'] as String;
    final timestamp = DateTime.now();

    final exportData = {
      'device_name': deviceName,
      'export_date': timestamp.toIso8601String(),
      'message_count': conversation['messageCount'],
      'last_message': conversation['lastMessage'],
      'conversation_history': [
        {
          'timestamp': conversation['timestamp'].toIso8601String(),
          'message': conversation['lastMessage'],
          'sender': deviceName,
          'type': 'received'
        }
      ]
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    final filename =
        'conversation_${deviceName}_${timestamp.millisecondsSinceEpoch}.json';

    try {
      if (kIsWeb) {
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(jsonString);
      }

      Fluttertoast.showToast(msg: 'Conversation exported successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Export failed. Please try again.');
    }
  }

  void _deleteSelectedConversations() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Conversations'),
        content: Text(
            'Are you sure you want to delete ${_selectedConversations.length} conversations? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allConversations.removeWhere(
                    (conv) => _selectedConversations.contains(conv['id']));
              });
              _clearSelection();
              _applyFilters();
              Navigator.pop(context);
              Fluttertoast.showToast(
                  msg:
                      '${_selectedConversations.length} conversations deleted');
            },
            child: Text('Delete',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _archiveSelectedConversations() {
    setState(() {
      for (final conversationId in _selectedConversations) {
        final index = _allConversations
            .indexWhere((conv) => conv['id'] == conversationId);
        if (index != -1) {
          _allConversations[index]['isArchived'] = true;
        }
      }
    });
    _clearSelection();
    _applyFilters();
    Fluttertoast.showToast(
        msg: '${_selectedConversations.length} conversations archived');
  }

  Future<void> _exportSelectedConversations() async {
    final selectedConvs = _allConversations
        .where((conv) => _selectedConversations.contains(conv['id']))
        .toList();
    final timestamp = DateTime.now();

    final exportData = {
      'export_date': timestamp.toIso8601String(),
      'total_conversations': selectedConvs.length,
      'conversations': selectedConvs
          .map((conv) => {
                'device_name': conv['deviceName'],
                'message_count': conv['messageCount'],
                'last_message': conv['lastMessage'],
                'timestamp': (conv['timestamp'] as DateTime).toIso8601String(),
                'unread_count': conv['unreadCount'],
                'is_online': conv['isOnline'],
              })
          .toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
    final filename =
        'conversations_export_${timestamp.millisecondsSinceEpoch}.json';

    try {
      if (kIsWeb) {
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(jsonString);
      }

      _clearSelection();
      Fluttertoast.showToast(
          msg: '${selectedConvs.length} conversations exported successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Export failed. Please try again.');
    }
  }

  Future<void> _refreshConversations() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 1));

    _loadMockData();
    Fluttertoast.showToast(msg: 'Conversations refreshed');
  }

  void _startNewConversation() {
    Navigator.pushNamed(context, '/device-discovery');
  }

  bool get _hasActiveFilters =>
      _selectedSortOption != 'recent' || _selectedDateRange != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'history',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 7.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Message History',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/connection-status'),
                    icon: CustomIconWidget(
                      iconName: 'settings',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: AppTheme.lightTheme.colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                onTap: (index) => _applyFilters(),
                tabs: const [
                  Tab(text: 'History'),
                  Tab(text: 'Archived'),
                ],
              ),
            ),

            // Search Bar
            if (!_isMultiSelectMode)
              SearchBarWidget(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onFilterTap: _showFilterBottomSheet,
                hasActiveFilters: _hasActiveFilters,
              ),

            // Multi-select Action Bar
            if (_isMultiSelectMode)
              MultiSelectActionBarWidget(
                selectedCount: _selectedConversations.length,
                onClearSelection: _clearSelection,
                onDeleteSelected: _deleteSelectedConversations,
                onArchiveSelected: _archiveSelectedConversations,
                onExportSelected: _exportSelectedConversations,
              ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildConversationsList(),
                  _buildConversationsList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton(
              onPressed: _startNewConversation,
              child: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 6.w,
              ),
            ),
    );
  }

  Widget _buildConversationsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredConversations.isEmpty) {
      final currentTab = _tabController.index;
      return EmptyStateWidget(
        title: currentTab == 0
            ? 'No conversations yet'
            : 'No archived conversations',
        subtitle: currentTab == 0
            ? 'Start messaging by connecting to nearby Bluetooth devices and begin your first conversation.'
            : 'Archived conversations will appear here when you archive them from the main history.',
        buttonText: currentTab == 0 ? 'Start Messaging' : 'Go to History',
        onButtonPressed: currentTab == 0
            ? _startNewConversation
            : () => _tabController.animateTo(0),
        illustrationUrl:
            'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400&h=300&fit=crop',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshConversations,
      color: AppTheme.lightTheme.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 10.h),
        itemCount: _filteredConversations.length,
        itemBuilder: (context, index) {
          final conversation = _filteredConversations[index];
          final conversationId = conversation['id'] as String;

          return ConversationCardWidget(
            conversation: conversation,
            onTap: () => _onConversationTap(conversation),
            onMarkRead: () => _markAsRead(conversationId),
            onDelete: () => _deleteConversation(conversationId),
            onArchive: () => _archiveConversation(conversationId),
            onExport: () => _exportConversation(conversationId),
            isSelected: _selectedConversations.contains(conversationId),
            isMultiSelectMode: _isMultiSelectMode,
            onSelectionChanged: (selected) {
              if (selected == true && !_isMultiSelectMode) {
                _enterMultiSelectMode(conversationId);
              } else {
                _toggleSelection(conversationId);
              }
            },
          );
        },
      ),
    );
  }
}
